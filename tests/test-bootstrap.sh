#!/usr/bin/env bash
# test-bootstrap.sh — hermetic tests for bootstrap.sh (Phase 9, P9.2).
#
# No network: a fake pinned release (tarball + checksums.txt) is built under a
# temp dir and AAS_RELEASE_BASE_URL points at it. `gh`/`curl` are mocked.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# ── 0. The usage example tracks VERSION ──────────────────────────────────────
REPO_VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"
grep -q -- "--version v${REPO_VERSION}" "$REPO_ROOT/bootstrap.sh"
check $? "usage example uses the current VERSION (v${REPO_VERSION})"

# Portable sha256 (GNU coreutils sha256sum, or macOS/BSD shasum -a 256).
_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# ── Build a fake pinned release (local dir, zero network) ────────────────────
REL="$TMP/releases"
ASSET_VERSION="1.2.3"
ASSET="another-agent-skills-v${ASSET_VERSION}.tar.gz"
REL_DIR="$REL/v${ASSET_VERSION}"
mkdir -p "$REL_DIR"

SRC="$TMP/src"
mkdir -p "$SRC/bin" "$SRC/scripts/lib"
printf '%s\n' "$ASSET_VERSION" > "$SRC/VERSION"
printf '#!/usr/bin/env bash\necho fake-aas\n' > "$SRC/bin/aas"
chmod +x "$SRC/bin/aas"
tar -czf "$REL_DIR/$ASSET" -C "$SRC" .
( cd "$REL_DIR" && printf '%s  %s\n' "$(_sha256 "$ASSET")" "$ASSET" > checksums.txt )

export HOME="$TMP/home"; mkdir -p "$HOME"
export AAS_HOME="$TMP/data"
export AAS_BIN_DIR="$TMP/bin"
export AAS_RELEASE_BASE_URL="$REL"

# ── 1. Version pinning: dry-run uses the pinned release URL, never main ──────
OUT="$(AAS_RELEASE_BASE_URL="https://github.com/juandelossantos/another-agent-skills/releases/download" \
  bash "$REPO_ROOT/bootstrap.sh" --version "$ASSET_VERSION" --dry-run 2>&1)"
RC=$?
[ "$RC" -eq 0 ]; check $? "dry-run (default base) exits 0 (got $RC)"
echo "$OUT" | grep -q "releases/download/v${ASSET_VERSION}/${ASSET}"; check $? "dry-run URL is pinned to v${ASSET_VERSION}"
echo "$OUT" | grep -q "main"; check $([ $? -ne 0 ] && echo 0 || echo 1) "dry-run URL never references main"

# ── 2. dry-run mutates nothing ───────────────────────────────────────────────
bash "$REPO_ROOT/bootstrap.sh" --version "$ASSET_VERSION" --dry-run >/dev/null 2>&1
[ ! -e "$AAS_HOME/$ASSET_VERSION" ]; check $? "dry-run: no install dir created"
[ ! -e "$AAS_BIN_DIR/aas" ] && [ ! -L "$AAS_BIN_DIR/aas" ]; check $? "dry-run: no symlink created"
[ ! -e "$HOME/.profile" ] && [ ! -e "$HOME/.zshrc" ] && [ ! -e "$HOME/.bashrc" ]; check $? "dry-run: no shell rc mutated"

# ── 3. Install: version dir + symlink + PATH ─────────────────────────────────
bash "$REPO_ROOT/bootstrap.sh" --version "$ASSET_VERSION" > "$TMP/install.log" 2>&1
RC=$?
[ "$RC" -eq 0 ]; check $? "install exits 0 (got $RC)"
[ -f "$AAS_HOME/$ASSET_VERSION/bin/aas" ]; check $? "version dir installed at \$AAS_HOME/<version>"
[ -L "$AAS_BIN_DIR/aas" ]; check $? "symlink \$AAS_BIN_DIR/aas created"
[ "$(readlink "$AAS_BIN_DIR/aas")" = "$AAS_HOME/$ASSET_VERSION/bin/aas" ]; check $? "symlink points at installed CLI"
[ -x "$AAS_HOME/$ASSET_VERSION/bin/aas" ]; check $? "installed CLI is executable"
grep -rqF "$AAS_BIN_DIR" "$HOME/.profile" "$HOME/.zshrc" "$HOME/.bashrc" 2>/dev/null; check $? "PATH entry added for \$AAS_BIN_DIR"

# ── 4. Checksum verification FAILS CLOSED on tampering ───────────────────────
TAMPER_VERSION="1.2.4"
TAMPER_DIR="$REL/v${TAMPER_VERSION}"
mkdir -p "$TAMPER_DIR"
cp "$REL_DIR/$ASSET" "$TAMPER_DIR/another-agent-skills-v${TAMPER_VERSION}.tar.gz"
( cd "$TAMPER_DIR" && printf '%s  %s\n' "$(_sha256 "another-agent-skills-v${TAMPER_VERSION}.tar.gz")" "another-agent-skills-v${TAMPER_VERSION}.tar.gz" > checksums.txt )
printf 'tamper-bytes' >> "$TAMPER_DIR/another-agent-skills-v${TAMPER_VERSION}.tar.gz"
bash "$REPO_ROOT/bootstrap.sh" --version "$TAMPER_VERSION" > "$TMP/tamper.log" 2>&1
RC=$?
[ "$RC" -ne 0 ]; check $? "checksum mismatch fails closed (got rc=$RC)"
[ ! -e "$AAS_HOME/$TAMPER_VERSION" ]; check $? "tampered release is not installed"
grep -qi "checksum" "$TMP/tamper.log"; check $? "failure message mentions checksum"

# ── 5. Uninstall removes install root + symlink ──────────────────────────────
bash "$REPO_ROOT/bootstrap.sh" --uninstall > "$TMP/uninstall.log" 2>&1
RC=$?
[ "$RC" -eq 0 ]; check $? "uninstall exits 0 (got $RC)"
[ ! -e "$AAS_HOME" ]; check $? "uninstall removes install root"
[ ! -e "$AAS_BIN_DIR/aas" ] && [ ! -L "$AAS_BIN_DIR/aas" ]; check $? "uninstall removes symlink"

# ── 6. Latest-version resolution ─────────────────────────────────────────────
MOCKBIN="$TMP/mockbin"; mkdir -p "$MOCKBIN"
printf '#!/usr/bin/env bash\necho v%s\n' "$ASSET_VERSION" > "$MOCKBIN/gh"
printf '#!/usr/bin/env bash\nexit 1\n' > "$MOCKBIN/curl"
chmod +x "$MOCKBIN/gh" "$MOCKBIN/curl"
OUT="$(PATH="$MOCKBIN:$PATH" bash "$REPO_ROOT/bootstrap.sh" --dry-run 2>&1)"
echo "$OUT" | grep -q "$ASSET_VERSION"; check $? "resolves latest version via gh api"

# When neither gh nor curl can resolve, fail clearly (never guess).
printf '#!/usr/bin/env bash\nexit 1\n' > "$MOCKBIN/gh"
PATH="$MOCKBIN:$PATH" bash "$REPO_ROOT/bootstrap.sh" --dry-run > "$TMP/noresolve.log" 2>&1
RC=$?
[ "$RC" -ne 0 ]; check $? "unresolvable version fails clearly (got rc=$RC)"
grep -qi "version" "$TMP/noresolve.log"; check $? "failure message mentions version"

# Invalid explicit version is rejected before any download.
bash "$REPO_ROOT/bootstrap.sh" --version "not-a-version" >/dev/null 2>&1
RC=$?
[ "$RC" -ne 0 ]; check $? "invalid --version rejected (got rc=$RC)"

exit "$fail"
