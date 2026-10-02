#!/usr/bin/env bash
# test-hooks-readme-v6.sh — scripts/git-hooks/README.md reflects v6 reality (Phase 8, P8.5).
#
# The README must: (1) state the real gate count (15, incl. Gate 0), (2) not frame
# `--no-verify` as a way to bypass enforcement (it only skips L1 feedback; the
# remote `gates` check still decides), and (3) point at the L1/L2/L3 model.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/scripts/git-hooks/README.md"

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

# --- Gate count reflects v11 reality ---
assert "states 15 gates" "grep -q '15 gates' '$FILE'"
assert "counts Gate 0 (DECISION_APPROVED)" "grep -q 'Gate 0 (DECISION_APPROVED)' '$FILE'"
assert "no longer claims 14 gates" "! grep -q '14 gates' '$FILE'"

# --- --no-verify is honest about the authority layer ---
assert "mentions --no-verify" "grep -q -- '--no-verify' '$FILE'"
assert "explains it does not bypass the remote gate" "grep -qi 'not bypass the remote gate' '$FILE'"
assert "does not present --no-verify as an intentional violation" "! grep -qi 'intentional violation' '$FILE'"
assert "does not tell users to rm the hooks as a fix" "! grep -q 'Remove permanently' '$FILE'"

# --- L1/L2/L3 model is linked ---
assert "labels the hooks as L1 feedback" "grep -q 'L1' '$FILE'"
assert "names L2 as the authority" "grep -qi 'L2' '$FILE'"
assert "links docs/BRANCH-PROTECTION.md" "grep -q 'BRANCH-PROTECTION.md' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
