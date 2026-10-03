#!/usr/bin/env bash
# test-build-release.sh — the release tarball + checksums match what bootstrap.sh
# expects, and the release workflow is wired correctly (P9.1).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$REPO_ROOT/scripts/build-release.sh"
WF="$REPO_ROOT/.github/workflows/release.yml"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

# --- Build a release locally ---
OUT=$(mktemp -d)
( cd "$REPO_ROOT" && bash "$BUILD" v9.9.9 "$OUT" ) >/dev/null 2>&1
RC=$?
assert "build-release exits 0" "[ $RC -eq 0 ]"

ASSET="$OUT/another-agent-skills-v9.9.9.tar.gz"
assert "tarball name matches aas_asset_name" "[ -f '$ASSET' ]"
assert "checksums.txt written" "[ -f '$OUT/checksums.txt' ]"

# --- Tarball carries the framework source at its root ---
tar -tzf "$ASSET" > "$OUT/list.txt" 2>/dev/null || true
LISTF="$OUT/list.txt"
assert "contains bin/aas at root" "grep -qE '^\./bin/aas\$' '$LISTF'"
assert "contains install.sh at root" "grep -qE '^\./install\.sh\$' '$LISTF'"
assert "contains scripts/tdd-gate.sh" "grep -qE '^\./scripts/tdd-gate\.sh\$' '$LISTF'"
assert "contains scripts/aas-resolve.sh" "grep -qE '^\./scripts/aas-resolve\.sh\$' '$LISTF'"
assert "contains templates/gates.yml" "grep -qE '^\./templates/gates\.yml\$' '$LISTF'"
assert "contains VERSION" "grep -qE '^\./VERSION\$' '$LISTF'"
assert "excludes .git" "! grep -qE '^\./\.git/' '$LISTF'"
assert "excludes node_modules" "! grep -qE '^\./node_modules/' '$LISTF'"

# --- Checksum format + verification via the framework's own verifier ---
assert "checksums.txt has the asset" "grep -q 'another-agent-skills-v9.9.9.tar.gz' '$OUT/checksums.txt'"
assert "checksum verifies (aas_verify_checksum)" "( cd '$REPO_ROOT' && . scripts/lib/aas.sh && aas_verify_checksum '$ASSET' '$OUT/checksums.txt' 'another-agent-skills-v9.9.9.tar.gz' ) >/dev/null 2>&1"

# --- Extracted tree is usable ---
EX=$(mktemp -d)
tar -xzf "$ASSET" -C "$EX" 2>/dev/null
assert "extracted bin/aas is executable" "[ -x '$EX/bin/aas' ]"
assert "extracted tree has a VERSION" "[ -f '$EX/VERSION' ]"
rm -rf "$EX" "$OUT"

# --- Workflow wiring ---
assert "release.yml exists" "[ -f '$WF' ]"
assert "triggers on v* tags" "grep -q \"tags: \\['v\\*'\\]\" '$WF'"
assert "requests contents/id-token/attestations write" "grep -q 'attestations: write' '$WF' && grep -q 'id-token: write' '$WF' && grep -q 'contents: write' '$WF'"
assert "attests the tarball" "grep -q 'attest-build-provenance' '$WF'"
assert "publishes via gh release create" "grep -q 'gh release create' '$WF'"
assert "never fetches from main" "! grep -qE 'releases/download/main|/main/' '$WF'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
