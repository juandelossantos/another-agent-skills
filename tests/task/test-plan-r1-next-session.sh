#!/usr/bin/env bash
# test-plan-r1-next-session.sh — PLAN.md records R1 (courtside rollout + the
# B7/B5 follow-ups) as the FIRST task for the next session.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1))
  fi
}

assert "has the R1 first-task section" "grep -q '### R1 — Courtside rollout' '$PLAN'"
assert "R1 is marked FIRST, next session" "grep -q 'FIRST, next session' '$PLAN'"
assert "the Next tasks intro points at R1 first" "grep -q '\*\*R1\*\* (courtside rollout) is \*\*FIRST' '$PLAN'"
assert "R1 documents the courtside install (init-agents --repair)" "grep -q 'init-agents.sh --repair' '$PLAN'"
assert "R1 documents the plugin restart step" "grep -q 'restart OpenCode' '$PLAN'"
assert "R1 documents the release→upgrade channel" "grep -q 'aas upgrade' '$PLAN'"
assert "R1 notes B10/B11 are fixed" "grep -q '\*\*B10\*\*' '$PLAN' && grep -q '\*\*B11\*\*' '$PLAN'"
assert "backlog index lists B10" "grep -q '^| B10 |' '$PLAN'"
assert "backlog index lists B11" "grep -q '^| B11 |' '$PLAN'"
assert "backlog marks B10 done" "grep -q '^| B10 |.*✅ Done' '$PLAN'"
assert "backlog marks B11 done" "grep -q '^| B11 |.*✅ Done' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
