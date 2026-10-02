#!/usr/bin/env bash
# test-health-check-sync.sh — Content check for HEALTH-CHECK.md: the
# Recommendations note reflect the post-v6.2.0 state (Phase 7 released,
# Phase 8 P8.1–P8.3 active, P8.5–P8.7 remaining), not a stale "start Phase 7"
# pointer.

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

assert "notes Phase 7 is released as v6.2.0" "grep -q 'Phase 7 released as v6.2.0' '$FILE'"
assert "notes Phase 8 is in progress" "grep -q 'Phase 8 in progress' '$FILE'"
assert "lists P8.5 as remaining" "grep -q 'P8.5' '$FILE'"
assert "lists P8.7 as remaining" "grep -q 'P8.7' '$FILE'"
assert "documents the test cadence" "grep -q 'Test cadence' '$FILE'"
assert "version header is 6.2.0" "grep -q '\*\*Version:\*\* 6.2.0' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
