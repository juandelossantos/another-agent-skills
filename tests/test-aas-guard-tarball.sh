#!/usr/bin/env bash
# test-aas-guard-tarball.sh — hermetic security tests for aas_guard_tarball
# (scripts/lib/aas.sh, Phase 9). The guard must refuse a release tarball whose
# members could escape the extraction root, including via SYMLINK TARGETS — a
# symlink member name is always safe-looking, so the old name-only check let
# `link -> /etc/passwd` and `link -> ../../../etc` through. A legitimate release
# (the repo ships relative, in-root symlinks like `.opencode/skills/*`) must
# still install.
#
# No network: everything is built under a temp dir.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

export HOME="$TMP/home"; mkdir -p "$HOME"
export AAS_HOME="$TMP/data" AAS_BIN_DIR="$TMP/bin"
unset AAS_LATEST_VERSION AAS_AGENTS 2>/dev/null || true
# shellcheck source=../scripts/lib/aas.sh
source "$REPO_ROOT/scripts/lib/aas.sh"

# A minimal release tree with a real bin/aas + VERSION.
make_tree() {
  local d="$1"
  mkdir -p "$d/bin"
  printf '%s\n' "5.5.5" > "$d/VERSION"
  printf '#!/usr/bin/env bash\necho fake-aas\n' > "$d/bin/aas"; chmod +x "$d/bin/aas"
}

# ── 1. Safe tarball: a legitimate relative, in-root symlink (repo-style) ──────
SAFE="$TMP/safe"; make_tree "$SAFE"
mkdir -p "$SAFE/.opencode/skills" "$SAFE/skills/foo"
: > "$SAFE/skills/foo/SKILL.md"
ln -s ../../skills/foo "$SAFE/.opencode/skills/foo"      # resolves to ./skills/foo (in root)
mkdir -p "$SAFE/scripts"
ln -s universal-audit.sh "$SAFE/scripts/audit-project.sh" # relative, same dir
tar -czf "$TMP/safe.tar.gz" -C "$SAFE" .
aas_guard_tarball "$TMP/safe.tar.gz"; check $? "accepts a legitimate in-root relative symlink"

# ── 2. Absolute symlink target must be refused ───────────────────────────────
ABS="$TMP/abs"; make_tree "$ABS"
ln -s /etc/passwd "$ABS/leak"
tar -czf "$TMP/abs.tar.gz" -C "$ABS" .
aas_guard_tarball "$TMP/abs.tar.gz"; RC=$?
[ "$RC" -ne 0 ]; check $? "refuses a symlink with an absolute target (got rc=$RC)"

# ── 3. Relative symlink target that escapes the extraction root ──────────────
ESC="$TMP/esc"; make_tree "$ESC"
mkdir -p "$ESC/sub"
ln -s ../../../etc "$ESC/sub/escape"
tar -czf "$TMP/esc.tar.gz" -C "$ESC" .
aas_guard_tarball "$TMP/esc.tar.gz"; RC=$?
[ "$RC" -ne 0 ]; check $? "refuses a symlink that escapes the extraction root (got rc=$RC)"

# ── 4. `..` member name (name-based traversal) ───────────────────────────────
EVIL="$TMP/evil-src"; make_tree "$EVIL"
if ( cd "$EVIL" && tar -czf "$TMP/name.tar.gz" --transform='s|^VERSION|../outside|' VERSION ) 2>/dev/null \
   && tar -tzf "$TMP/name.tar.gz" 2>/dev/null | grep -q '\.\./'; then
  aas_guard_tarball "$TMP/name.tar.gz"; RC=$?
  [ "$RC" -ne 0 ]; check $? "refuses a '..' member name (got rc=$RC)"
else
  check 0 "refuses a '..' member name (skipped: tar lacks --transform)"
fi

# ── 5. Regression: the safe tarball still installs through the real path ─────
REL="$TMP/rel"; mkdir -p "$REL"
cp "$TMP/safe.tar.gz" "$REL/another-agent-skills-v5.5.5.tar.gz"
( cd "$REL" && printf '%s  %s\n' "$(_sha256 another-agent-skills-v5.5.5.tar.gz)" another-agent-skills-v5.5.5.tar.gz > checksums.txt )
aas_install_release_from_files 5.5.5 "$REL/another-agent-skills-v5.5.5.tar.gz" "$REL/checksums.txt" > "$TMP/install.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "installs a release that contains a legitimate symlink (got rc=$RC)"
[ -x "$AAS_HOME/5.5.5/bin/aas" ]; check $? "installed bin/aas is executable"

# ── 6. Mutable-ref URL guard (cheap parity nit) ──────────────────────────────
aas_guard_url "https://github.com/o/r/archive/main/x.tar.gz"; RC=$?
[ "$RC" -ne 0 ]; check $? "aas_guard_url refuses a /main/ path (got rc=$RC)"
aas_guard_url "https://github.com/o/r/archive/refs/heads/main"; RC=$?
[ "$RC" -ne 0 ]; check $? "aas_guard_url refuses a refs/heads path (got rc=$RC)"
aas_guard_url "https://github.com/o/r/raw/main"; RC=$?
[ "$RC" -ne 0 ]; check $? "aas_guard_url refuses a trailing /main (got rc=$RC)"
aas_guard_url "https://github.com/o/r/releases/download/v1.2.3/x.tar.gz"; RC=$?
[ "$RC" -eq 0 ]; check $? "aas_guard_url accepts a pinned release URL (got rc=$RC)"

exit "$fail"
