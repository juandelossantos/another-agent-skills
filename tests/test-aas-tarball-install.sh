#!/usr/bin/env bash
# test-aas-tarball-install.sh — unit tests for the shared tarball install path
# added to scripts/lib/aas.sh for Phase 9 / P9.5: aas_version_from_tarball,
# aas_install_release_from_files, and aas_activate_release. Hermetic: a local
# fake release, zero network.
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
# Unreachable base: a successful install proves the local path never used it.
export AAS_RELEASE_BASE_URL="http://127.0.0.1:9/never"
unset AAS_LATEST_VERSION AAS_AGENTS

# shellcheck source=scripts/lib/aas.sh
source "$REPO_ROOT/scripts/lib/aas.sh"

# ── Build a fake pinned release (local dir, zero network) ────────────────────
VERSION="3.4.5"
ASSET="another-agent-skills-v${VERSION}.tar.gz"
REL="$TMP/rel"; mkdir -p "$REL"
SRC="$TMP/src"; mkdir -p "$SRC/bin"
printf '%s\n' "$VERSION" > "$SRC/VERSION"
printf '#!/usr/bin/env bash\necho fake-aas\n' > "$SRC/bin/aas"; chmod +x "$SRC/bin/aas"
tar -czf "$REL/$ASSET" -C "$SRC" .
printf '%s  %s\n' "$(_sha256 "$REL/$ASSET")" "$ASSET" > "$REL/checksums.txt"

# ── 1. aas_version_from_tarball reads the release's own VERSION ──────────────
OUT="$(aas_version_from_tarball "$REL/$ASSET")"; RC=$?
[ "$RC" -eq 0 ] && [ "$OUT" = "$VERSION" ]; check $? "aas_version_from_tarball reads ./VERSION (got '$OUT')"

# ── 2. aas_install_release_from_files verifies + activates ───────────────────
aas_install_release_from_files "$VERSION" "$REL/$ASSET" "$REL/checksums.txt" > "$TMP/install.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "aas_install_release_from_files exits 0 (got $RC)"
[ -f "$AAS_HOME/$VERSION/VERSION" ]; check $? "installs into \$AAS_HOME/<version>"
[ -L "$AAS_BIN_DIR/aas" ]; check $? "links \$AAS_BIN_DIR/aas"

# ── 3. FAILS CLOSED on checksum mismatch ─────────────────────────────────────
rm -rf "$AAS_HOME" "$AAS_BIN_DIR"
printf 'tamper-bytes' >> "$REL/$ASSET"
aas_install_release_from_files "$VERSION" "$REL/$ASSET" "$REL/checksums.txt" > "$TMP/bad.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "checksum mismatch returns non-zero (got $RC)"
[ ! -e "$AAS_HOME/$VERSION" ]; check $? "tampered release not installed"
grep -qi "checksum" "$TMP/bad.log"; check $? "mismatch reports checksum"

# ── 4. Missing inputs are rejected ───────────────────────────────────────────
aas_install_release_from_files "$VERSION" "$TMP/nope.tar.gz" "$REL/checksums.txt" >/dev/null 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "missing tarball returns non-zero (got $RC)"
aas_install_release_from_files "$VERSION" "$REL/$ASSET" "$TMP/nope.txt" >/dev/null 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "missing checksums returns non-zero (got $RC)"

exit "$fail"
