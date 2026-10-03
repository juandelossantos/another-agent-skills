#!/usr/bin/env bash
# test-npm-cli.sh — hermetic tests for the npm wrapper (npm/cli.js, Phase 9 /
# P9.5). No network: a fake pinned release is built under a temp dir and
# AAS_RELEASE_BASE_URL points at it. The wrapper downloads (copies), verifies
# sha256, extracts, and delegates to the release's own bootstrap.sh.
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
export AAS_HOME="$TMP/data"
export AAS_BIN_DIR="$TMP/bin"
unset AAS_LATEST_VERSION AAS_AGENTS
CLI="$REPO_ROOT/npm/cli.js"
REPO_VERSION="$(cat "$REPO_ROOT/VERSION")"

# ── Build a fake pinned release (local dir, zero network) ────────────────────
# The release carries the REAL bootstrap.sh + scripts/lib/aas.sh so the wrapper
# delegates to the single source of truth for install logic.
VERSION="1.2.3"
ASSET="another-agent-skills-v${VERSION}.tar.gz"
REL="$TMP/releases"; REL_DIR="$REL/v${VERSION}"; mkdir -p "$REL_DIR"
SRC="$TMP/src"; mkdir -p "$SRC/bin" "$SRC/scripts/lib"
printf '%s\n' "$VERSION" > "$SRC/VERSION"
printf '#!/usr/bin/env bash\necho fake-aas\n' > "$SRC/bin/aas"; chmod +x "$SRC/bin/aas"
cp "$REPO_ROOT/bootstrap.sh" "$SRC/bootstrap.sh"; chmod +x "$SRC/bootstrap.sh"
cp "$REPO_ROOT/scripts/lib/aas.sh" "$SRC/scripts/lib/aas.sh"
tar -czf "$REL_DIR/$ASSET" -C "$SRC" .
( cd "$REL_DIR" && printf '%s  %s\n' "$(_sha256 "$ASSET")" "$ASSET" > checksums.txt )
export AAS_RELEASE_BASE_URL="$REL"

# ── 1. Syntax + --version / --help ───────────────────────────────────────────
node --check "$CLI" >/dev/null 2>&1; check $? "node --check npm/cli.js passes"

OUT="$(node "$CLI" --version 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "npm cli --version exits 0 (got $RC)"
[ "$OUT" = "$REPO_VERSION" ]; check $? "npm cli --version prints repo VERSION ($REPO_VERSION)"

OUT="$(node "$CLI" --help 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "npm cli --help exits 0 (got $RC)"
echo "$OUT" | grep -qi "install"; check $? "npm cli --help documents install"

# ── 2. --dry-run mutates nothing ─────────────────────────────────────────────
OUT="$(node "$CLI" install --version "$VERSION" --dry-run 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "npm cli install --dry-run exits 0 (got $RC)"
[ ! -e "$AAS_HOME/$VERSION" ]; check $? "--dry-run: no install dir created"
[ ! -e "$AAS_BIN_DIR/aas" ] && [ ! -L "$AAS_BIN_DIR/aas" ]; check $? "--dry-run: no symlink created"

# ── 3. install: download + verify + extract + delegate ───────────────────────
node "$CLI" install --version "$VERSION" > "$TMP/install.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "npm cli install exits 0 (got $RC)"
[ -f "$AAS_HOME/$VERSION/VERSION" ]; check $? "install created \$AAS_HOME/<version>"
[ -L "$AAS_BIN_DIR/aas" ]; check $? "install linked \$AAS_BIN_DIR/aas"
[ "$(cat "$AAS_HOME/$VERSION/VERSION")" = "$VERSION" ]; check $? "installed the requested pinned version"

# ── 4. Checksum verification FAILS CLOSED on tampering ───────────────────────
BAD="1.2.4"; BAD_ASSET="another-agent-skills-v${BAD}.tar.gz"
BAD_DIR="$REL/v${BAD}"; mkdir -p "$BAD_DIR"
cp "$REL_DIR/$ASSET" "$BAD_DIR/$BAD_ASSET"
( cd "$BAD_DIR" && printf '%s  %s\n' "$(_sha256 "$BAD_ASSET")" "$BAD_ASSET" > checksums.txt )
printf 'tamper-bytes' >> "$BAD_DIR/$BAD_ASSET"
node "$CLI" install --version "$BAD" > "$TMP/bad.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "checksum mismatch fails closed (got rc=$RC)"
[ ! -e "$AAS_HOME/$BAD" ]; check $? "tampered release is not installed"
grep -qi "checksum" "$TMP/bad.log"; check $? "failure message mentions checksum"

# ── 5. Mutable refs are refused (never fetch from main) ──────────────────────
AAS_RELEASE_BASE_URL="https://github.com/x/y/raw/main" node "$CLI" install --version "$VERSION" > "$TMP/mutable.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "mutable-ref base URL is refused (got rc=$RC)"
grep -qi "mutable" "$TMP/mutable.log"; check $? "mutable-ref failure explains why"

exit "$fail"
