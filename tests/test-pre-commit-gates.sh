#!/usr/bin/env bash
# test-pre-commit-gates.sh — Test suite for pre-commit gate numbering (Phase 0, Task 0.6)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Verifies that pre-commit hook gates are numbered sequentially 0-14
# with consistent format and no duplicates or gaps.
#
# Usage: bash tests/test-pre-commit-gates.sh
# Exit: 0 if all tests pass, 1 if any fail

set -uo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"

PASSED=0
FAILED=0
TOTAL=0

assert() {
  local test_name="$1"
  local condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $test_name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $test_name"
    FAILED=$((FAILED + 1))
  fi
}

echo -e "${YELLOW}Pre-Commit Gate Numbering Test Suite${NC}"
echo "──────────────────────────────────────────"

# ─── Test 1: File exists ───
echo ""
echo "Test 1: File exists"
assert "pre-commit hook exists" "[ -f '$HOOK' ]"

# ─── Test 2: Syntax valid ───
echo ""
echo "Test 2: Syntax valid"
bash -n "$HOOK" 2>/dev/null
assert "bash -n passes" "[ $? -eq 0 ]"

# ─── Test 3: Version is v11 ───
echo ""
echo "Test 3: Version is v11"
assert "version v11 in header" "head -3 '$HOOK' | grep -q 'v11'"

# ─── Test 4: Exactly 15 gate comments ───
echo ""
echo "Test 4: Exactly 15 gate comments (includes Gate 0)"
HOOK="${REPO_ROOT}/.git/hooks/pre-commit"
GATE_COUNT=$(grep -cP '^# Gate \d+:' "$HOOK" 2>/dev/null || echo 0)
assert "15 gate comments (got $GATE_COUNT)" "[ '$GATE_COUNT' -eq 15 ]"

# ─── Test 5: Sequential 0-14, no gaps ───
echo ""
echo "Test 5: Sequential 0-14, no gaps or duplicates"
grep "^# Gate" "$HOOK" | awk '{print $3}' | sed 's/://' | sort -n > /tmp/gates_actual.txt
seq 0 14 > /tmp/gates_expected.txt
diff /tmp/gates_expected.txt /tmp/gates_actual.txt > /dev/null 2>&1
assert "sequential 0-14" "[ $? -eq 0 ]"

# ─── Test 6: No duplicate gate numbers ───
echo ""
echo "Test 6: No duplicate gate numbers"
DUPES=$(grep "^# Gate" "$HOOK" | awk '{print $3}' | sort | uniq -d | wc -l)
assert "0 duplicates (got $DUPES)" "[ '$DUPES' -eq 0 ]"

# ─── Test 7: Consistent comment format ───
echo ""
echo "Test 7: Consistent comment format (# Gate N: Name)"
FORMAT_ERRORS=$(grep "^# Gate" "$HOOK" | grep -cv "^# Gate [0-9]*: " 2>/dev/null || echo 0)
FORMAT_ERRORS=$(echo "$FORMAT_ERRORS" | tr -d '[:space:]')
assert "all gates use '# Gate N: Name' format (got $FORMAT_ERRORS errors)" "[ '$FORMAT_ERRORS' -eq 0 ]"

# ─── Summary ───
echo ""
echo "──────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""

rm -f /tmp/gates_actual.txt /tmp/gates_expected.txt

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
