#!/usr/bin/env bash
# test-health-check-sync.sh — Content check for HEALTH-CHECK.md: the
# Recommendations note reflects that Task 7.1's skills+hooks portion is done,
# not a stale "start Task 7.1" pointer.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/HEALTH-CHECK.md"

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

assert "notes the skills+hooks portion of Task 7.1 is done" "grep -q 'skills + hooks portion is done' '$FILE'"
assert "notes the agents/commands mirror is still open" "grep -q 'agents/.*commands/.*mirror' '$FILE'"
assert "version header is 6.2.0" "grep -q '\\*\\*Version:\\*\\* 6.2.0' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
