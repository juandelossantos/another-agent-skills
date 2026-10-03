#!/usr/bin/env bash
# test-npm-cli-guard.sh — hermetic security tests for npm/cli.js (Phase 9/P9.5).
#
# The wrapper extracts a release tarball into a temp dir BEFORE delegating to
# the release's bootstrap.sh. It must refuse a tarball whose members escape the
# extraction root (absolute path, `..` name, or a symlink target outside the
# root) even when the checksum matches — the checksum proves authenticity of the
# asset, not the safety of its layout. Also: HTTP redirects must be re-guarded
# so a trusted URL cannot bounce to a mutable ref.
#
# No network: AAS_RELEASE_BASE_URL points at a local fake release.
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
CLI="$REPO_ROOT/npm/cli.js"

# Build a fake release whose tarball has the given extra symlink target.
# usage: build_release <version> <symlink-target|-> <asset>
build_release() {
  local v="$1" link="$2" asset="another-agent-skills-v${1}.tar.gz"
  local dir="$TMP/rel/v${v}"; mkdir -p "$dir" "$TMP/src${v}/bin" "$TMP/src${v}/scripts/lib"
  printf '%s\n' "$v" > "$TMP/src${v}/VERSION"
  printf '#!/usr/bin/env bash\necho fake-aas\n' > "$TMP/src${v}/bin/aas"; chmod +x "$TMP/src${v}/bin/aas"
  cp "$REPO_ROOT/bootstrap.sh" "$TMP/src${v}/bootstrap.sh"
  cp "$REPO_ROOT/scripts/lib/aas.sh" "$TMP/src${v}/scripts/lib/aas.sh"
  [ "$link" != "-" ] && ln -s "$link" "$TMP/src${v}/leak"
  tar -czf "$dir/$asset" -C "$TMP/src${v}" .
  ( cd "$dir" && printf '%s  %s\n' "$(_sha256 "$asset")" "$asset" > checksums.txt )
}

# ── 1. A safe release installs (control) ─────────────────────────────────────
build_release 4.4.4 -
export AAS_RELEASE_BASE_URL="$TMP/rel"
node "$CLI" install --version 4.4.4 > "$TMP/ok.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "safe release installs (got rc=$RC)"
[ -x "$AAS_HOME/4.4.4/bin/aas" ]; check $? "safe release materialized bin/aas"

# ── 2. Symlink escaping the extraction root is refused BEFORE extraction ─────
rm -rf "$AAS_HOME" "$AAS_BIN_DIR"
build_release 4.4.5 "../../../etc"
node "$CLI" install --version 4.4.5 > "$TMP/esc.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "refuses an escaping symlink even with a valid checksum (got rc=$RC)"
[ ! -e "$AAS_HOME/4.4.5" ]; check $? "escaping release is not installed"
grep -qiE "unsafe|refus" "$TMP/esc.log"; check $? "failure explains the unsafe member"

# ── 3. Absolute symlink target is refused ────────────────────────────────────
build_release 4.4.6 "/etc/passwd"
node "$CLI" install --version 4.4.6 > "$TMP/abs.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "refuses an absolute symlink target (got rc=$RC)"
[ ! -e "$AAS_HOME/4.4.6" ]; check $? "absolute-symlink release is not installed"

# ── 4. Redirect targets are re-guarded (static: no unguarded recursion) ──────
grep -q 'guardUrl(next)' "$CLI"; check $? "httpGet re-guards the redirect target before following it"

exit "$fail"
