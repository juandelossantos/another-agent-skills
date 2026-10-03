#!/usr/bin/env bash
# test-build-brew-formula.sh — hermetic tests for scripts/build-brew-formula.sh
# (Phase 9 / P9.6). Builds a real pinned release locally with
# scripts/build-release.sh, generates the Homebrew formula from its
# checksums.txt, and asserts the formula is pinned (never `main`), carries the
# exact sha256, and exposes `aas` on PATH. No network.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEN="$REPO_ROOT/scripts/build-brew-formula.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

VERSION="9.9.9"
ASSET="another-agent-skills-v${VERSION}.tar.gz"
URL="https://github.com/juandelossantos/another-agent-skills/releases/download/v${VERSION}/${ASSET}"

echo ""
echo "build-brew-formula.sh — pinned Homebrew formula"
echo "───────────────────────────────────────────────"

# ── Build a real release locally (zero network) ──────────────────────────────
OUT="$TMP/dist"
( cd "$REPO_ROOT" && bash scripts/build-release.sh "v$VERSION" "$OUT" ) >/dev/null 2>&1
[ -f "$OUT/checksums.txt" ]; check $? "local release built (checksums.txt present)"

# ── Generate the formula ─────────────────────────────────────────────────────
bash "$GEN" "v$VERSION" "$OUT/checksums.txt" "$OUT" > "$TMP/gen.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "generator exits 0 (got $RC)"

FORMULA="$OUT/another-agent-skills.rb"
[ -f "$FORMULA" ]; check $? "emits <outdir>/another-agent-skills.rb"

# ── Formula identity + metadata ──────────────────────────────────────────────
grep -q 'class AnotherAgentSkills < Formula' "$FORMULA"; check $? "class AnotherAgentSkills < Formula"
grep -q 'desc "' "$FORMULA"; check $? "has a desc"
grep -q 'homepage "https://github.com/juandelossantos/another-agent-skills"' "$FORMULA"; check $? "homepage points at the repo"
grep -q 'license "MIT"' "$FORMULA"; check $? 'license "MIT"'
grep -q "version \"$VERSION\"" "$FORMULA"; check $? "version pinned to ${VERSION}"

# ── Pinned, immutable source (never a mutable branch) ────────────────────────
grep -qF "$URL" "$FORMULA"; check $? "url is the pinned release tarball"
! grep -qE 'releases/download/main|/main/' "$FORMULA"; check $? "url never references main"

# ── sha256 comes from checksums.txt (fail closed) ────────────────────────────
EXPECTED="$(awk -v a="$ASSET" '$2==a || $2=="./"a {print $1; exit}' "$OUT/checksums.txt")"
[ -n "$EXPECTED" ]; check $? "checksums.txt carries the asset hash"
grep -qF "sha256 \"$EXPECTED\"" "$FORMULA"; check $? "sha256 matches checksums.txt"

# ── install block: tree into libexec, bin/aas symlinked into bin ─────────────
grep -q 'def install' "$FORMULA"; check $? "has an install block"
grep -q 'libexec.install buildpath.children' "$FORMULA"; check $? "installs the full tree (incl. dot-dirs) into libexec"
grep -qE 'bin\.install_symlink .*libexec.*bin/aas' "$FORMULA"; check $? "symlinks bin/aas into bin"

# ── test block ───────────────────────────────────────────────────────────────
grep -q 'test do' "$FORMULA"; check $? "has a test block"
grep -qE 'system .*aas.*--version|system .*--version.*aas' "$FORMULA"; check $? "test runs aas --version"

# ── Version may be passed without the leading `v` ────────────────────────────
bash "$GEN" "$VERSION" "$OUT/checksums.txt" "$TMP/normalized" >/dev/null 2>&1; RC=$?
[ "$RC" -eq 0 ] && grep -q "version \"$VERSION\"" "$TMP/normalized/another-agent-skills.rb"; check $? "accepts X.Y.Z (normalizes the tag)"

# ── Defaults: dist/checksums.txt + outdir dist/ (run from a temp cwd) ────────
DEF="$TMP/def"; mkdir -p "$DEF/dist"
cp "$OUT/checksums.txt" "$DEF/dist/checksums.txt"
( cd "$DEF" && bash "$GEN" "v$VERSION" ) >/dev/null 2>&1; RC=$?
[ "$RC" -eq 0 ] && [ -f "$DEF/dist/another-agent-skills.rb" ]; check $? "defaults to dist/checksums.txt + outdir dist/"

# ── Failure modes ────────────────────────────────────────────────────────────
BAD="$TMP/bad"; mkdir -p "$BAD"
printf '%s  %s\n' "0000000000000000000000000000000000000000000000000000000000000000" "some-other-asset.tar.gz" > "$BAD/checksums.txt"
bash "$GEN" "v$VERSION" "$BAD/checksums.txt" "$BAD" > "$TMP/bad.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "missing checksum entry fails closed (got rc=$RC)"
grep -qi 'checksum' "$TMP/bad.log"; check $? "missing-entry failure explains why"
[ ! -f "$BAD/another-agent-skills.rb" ]; check $? "no formula emitted when the checksum is missing"

bash "$GEN" "v$VERSION" "$TMP/does-not-exist.txt" "$TMP" > "$TMP/nofile.log" 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "missing checksums file fails (got rc=$RC)"

bash "$GEN" >/dev/null 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "no version argument fails with usage (got rc=$RC)"

bash "$GEN" "not-a-version" "$OUT/checksums.txt" "$OUT" >/dev/null 2>&1; RC=$?
[ "$RC" -ne 0 ]; check $? "invalid version is rejected (got rc=$RC)"

echo ""
echo "Results: ${fail} failed"
[ "$fail" -gt 0 ] && exit 1
exit 0
