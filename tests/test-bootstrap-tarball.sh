#!/usr/bin/env bash
# test-bootstrap-tarball.sh — bootstrap.sh --tarball/--checksums (Phase 9 /
# P9.5). Installs from already-downloaded local files without any network,
# reusing the existing verify/activate logic, and fails closed on a checksum
# mismatch. The release base URL points at an unreachable host: a successful
# install proves the local path never touched the network.
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
export AAS_RELEASE_BASE_URL="http://127.0.0.1:9/never"
unset AAS_LATEST_VERSION AAS_AGENTS

# ── Build a fake pinned release (local dir, zero network) ────────────────────
VERSION="2.3.4"
ASSET="another-agent-skills-v${VERSION}.tar.gz"
REL="$TMP/rel"; mkdir -p "$REL"
SRC="$TMP/src"; mkdir -p "$SRC/bin" "$SRC/scripts/lib"
printf '%s\n' "$VERSION" > "$SRC/VERSION"
printf '#!/usr/bin/env bash\necho fake-aas\n' > "$SRC/bin/aas"; chmod +x "$SRC/bin/aas"
cp "$REPO_ROOT/bootstrap.sh" "$SRC/bootstrap.sh"; chmod +x "$SRC/bootstrap.sh"
cp "$REPO_ROOT/scripts/lib/aas.sh" "$SRC/scripts/lib/aas.sh"
tar -czf "$REL/$ASSET" -C "$SRC" .
printf '%s  %s\n' "$(_sha256 "$REL/$ASSET")" "$ASSET" > "$REL/checksums.txt"

# ── 1. Help documents the new flags (existing flags keep working) ────────────
OUT="$(bash "$REPO_ROOT/bootstrap.sh" --help 2>&1)"
echo "$OUT" | grep -q -- "--tarball"; check $? "--help documents --tarball"
echo "$OUT" | grep -q -- "--checksums"; check $? "--help documents --checksums"
echo "$OUT" | grep -q -- "--dry-run"; check $? "--help still documents --dry-run"
echo "$OUT" | grep -q -- "--uninstall"; check $? "--help still documents --uninstall"

# ── 2. Install from local files, no network ──────────────────────────────────
bash "$REPO_ROOT/bootstrap.sh" --version "$VERSION" --tarball "$REL/$ASSET" --checksums "$REL/checksums.txt" > "$TMP/install.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "--tarball install exits 0 without network (got $RC)"
[ -f "$AAS_HOME/$VERSION/VERSION" ]; check $? "--tarball install created \$AAS_HOME/<version>"
[ -L "$AAS_BIN_DIR/aas" ]; check $? "--tarball install linked \$AAS_BIN_DIR/aas"
[ "$(cat "$AAS_HOME/$VERSION/VERSION")" = "$VERSION" ]; check $? "--tarball install is the requested version"

# ── 3. Version derived from the tarball when --version is omitted ────────────
rm -rf "$AAS_HOME" "$AAS_BIN_DIR"
bash "$REPO_ROOT/bootstrap.sh" --tarball "$REL/$ASSET" --checksums "$REL/checksums.txt" > "$TMP/derive.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "--tarball without --version derives VERSION (got $RC)"
[ -f "$AAS_HOME/$VERSION/VERSION" ]; check $? "derived version installed"

# ── 4. Checksum verification FAILS CLOSED on tampering ───────────────────────
rm -rf "$AAS_HOME" "$AAS_BIN_DIR"
printf 'tamper-bytes' >> "$REL/$ASSET"
bash "$REPO_ROOT/bootstrap.sh" --version "$VERSION" --tarball "$REL/$ASSET" --checksums "$REL/checksums.txt" > "$TMP/bad.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "checksum mismatch fails closed (got rc=$RC)"
[ ! -e "$AAS_HOME/$VERSION" ]; check $? "tampered release is not installed"
grep -qi "checksum" "$TMP/bad.log"; check $? "failure message mentions checksum"

# ── 5. --tarball requires --checksums ────────────────────────────────────────
bash "$REPO_ROOT/bootstrap.sh" --version "$VERSION" --tarball "$REL/$ASSET" > "$TMP/nock.log" 2>&1; RC=$?
[ "$RC" -eq 2 ]; check $? "--tarball without --checksums exits 2 (got $RC)"
grep -qi "checksums" "$TMP/nock.log"; check $? "missing --checksums reports an error"

# ── 6. --tarball with a missing file is rejected ─────────────────────────────
bash "$REPO_ROOT/bootstrap.sh" --version "$VERSION" --tarball "$TMP/nope.tar.gz" --checksums "$REL/checksums.txt" > "$TMP/nofile.log" 2>&1; RC=$?
[ "$RC" -eq 2 ]; check $? "--tarball missing file exits 2 (got $RC)"

# ── 7. --dry-run with --tarball mutates nothing ──────────────────────────────
rm -rf "$AAS_HOME" "$AAS_BIN_DIR"
bash "$REPO_ROOT/bootstrap.sh" --version "$VERSION" --tarball "$REL/$ASSET" --checksums "$REL/checksums.txt" --dry-run > "$TMP/dry.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "--tarball --dry-run exits 0 (got $RC)"
[ ! -e "$AAS_HOME" ]; check $? "--tarball --dry-run created no install root"

exit "$fail"
