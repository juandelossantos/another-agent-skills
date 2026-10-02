#!/usr/bin/env bash
# test-aas-hardening.sh — security/correctness hardening for the distribution
# logic (scripts/lib/aas.sh) and the `aas` CLI (bin/aas).
#
# Regression coverage for review findings:
#   - --agents validation must reject regex metacharacters (the old
#     `grep -qx` treated the id as a pattern, so `.*` was accepted)
#   - uninstall must remove the PATH block it added (complete + idempotent)
#   - tarballs with `..`/absolute members are refused before extraction
#   - installing over an existing version replaces it (no stale dir)
#   - a missing --agents value is rejected (rc 2), never a silent abort
#
# Hermetic: local fake release only; no network.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# Portable sha256 (GNU coreutils sha256sum, or macOS/BSD shasum -a 256).
_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

export HOME="$TMP/home"; mkdir -p "$HOME"
export AAS_HOME="$TMP/data"
export AAS_BIN_DIR="$TMP/bin"
unset AAS_AGENTS AAS_LATEST_VERSION AAS_RELEASE_BASE_URL 2>/dev/null || true

# shellcheck source=../scripts/lib/aas.sh
source "$REPO_ROOT/scripts/lib/aas.sh"
# shellcheck source=../scripts/agent-detect.sh
source "$REPO_ROOT/scripts/agent-detect.sh"

# ── 1. --agents validation rejects regex metacharacters ──────────────────────
OUT="$(aas_parse_agent_list '.*' 2>&1)"; RC=$?
[ "$RC" -ne 0 ]; check $? "aas_parse_agent_list rejects '.*' (got rc=$RC)"
OUT="$(aas_parse_agent_list 'open.*' 2>&1)"; RC=$?
[ "$RC" -ne 0 ]; check $? "aas_parse_agent_list rejects 'open.*' (got rc=$RC)"
OUT="$(aas_parse_agent_list 'claude,opencode' 2>&1)"; RC=$?
[ "$RC" -eq 0 ] && [ "$OUT" = "claude,opencode" ]; check $? "aas_parse_agent_list accepts a valid list"
OUT="$(aas_parse_agent_list 'claude, bogus' 2>&1)"; RC=$?
[ "$RC" -ne 0 ]; check $? "aas_parse_agent_list rejects an unknown id"

# ── 2. CLI rejects a missing --agents value (rc 2, not a silent set -e abort) ─
( cd "$TMP" && bash "$REPO_ROOT/bin/aas" install --agents </dev/null >"$TMP/agents.log" 2>&1 ); RC=$?
[ "$RC" -eq 2 ]; check $? "bin/aas install --agents (no value) exits 2 (got $RC)"
grep -qi "agents" "$TMP/agents.log"; check $? "missing --agents value is reported"

# ── 3. tarball traversal guard ───────────────────────────────────────────────
EVIL="$TMP/evil.tar.gz"
mkdir -p "$TMP/evil-src"
( cd "$TMP/evil-src" && tar -czf "$EVIL" --transform='s|^|../|' . 2>/dev/null ) || true
if tar -tzf "$EVIL" 2>/dev/null | grep -q '\.\./'; then
  aas_guard_tarball "$EVIL"; RC=$?
  [ "$RC" -ne 0 ]; check $? "aas_guard_tarball refuses a '..' member (got rc=$RC)"
else
  check 0 "aas_guard_tarball refuses a '..' member (skipped: tar lacks --transform)"
fi
GOOD="$TMP/good.tar.gz"
mkdir -p "$TMP/good-src/bin"; : > "$TMP/good-src/bin/aas"
( cd "$TMP/good-src" && tar -czf "$GOOD" . )
aas_guard_tarball "$GOOD"; RC=$?
[ "$RC" -eq 0 ]; check $? "aas_guard_tarball accepts a safe tarball (got rc=$RC)"

# ── 4. uninstall removes the PATH block it added ─────────────────────────────
printf '%s\n' 'export KEEP_ME=1' > "$HOME/.profile"
aas_ensure_path
grep -qF "another-agent-skills-path" "$HOME/.profile"; check $? "aas_ensure_path adds the PATH block"
aas_uninstall
grep -qF "another-agent-skills-path" "$HOME/.profile"; check $([ $? -ne 0 ] && echo 0 || echo 1) "aas_uninstall removes the PATH block"
grep -qF "KEEP_ME=1" "$HOME/.profile"; check $? "aas_uninstall preserves unrelated rc content"

# ── 5. install over an existing version replaces it ──────────────────────────
V="1.2.3"; A="another-agent-skills-v$V.tar.gz"; REL="$TMP/releases"; D="$REL/v$V"
mkdir -p "$D" "$TMP/src/bin" "$TMP/src/scripts/lib"
printf '%s\n' "$V" > "$TMP/src/VERSION"
printf '#!/usr/bin/env bash\necho fake\n' > "$TMP/src/bin/aas"; chmod +x "$TMP/src/bin/aas"
cp "$REPO_ROOT/scripts/lib/aas.sh" "$TMP/src/scripts/lib/aas.sh"
tar -czf "$D/$A" -C "$TMP/src" .
( cd "$D" && printf '%s  %s\n' "$(_sha256 "$A")" "$A" > checksums.txt )
export AAS_RELEASE_BASE_URL="$REL"
# Plant a stale marker inside the target dir, then install: it must be replaced.
mkdir -p "$AAS_HOME/$V"; : > "$AAS_HOME/$V/STALE"
aas_install_release "$V"; RC=$?
[ "$RC" -eq 0 ]; check $? "aas_install_release over an existing version exits 0 (got $RC)"
[ -x "$AAS_HOME/$V/bin/aas" ]; check $? "install materialized the new bin/aas"
[ ! -e "$AAS_HOME/$V/STALE" ]; check $? "install replaced the stale version dir (no leftover STALE)"
[ -L "$AAS_BIN_DIR/aas" ]; check $? "install created the symlink"

exit "$fail"
