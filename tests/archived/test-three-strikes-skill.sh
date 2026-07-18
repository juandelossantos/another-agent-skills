#!/usr/bin/env bash
# test-three-strikes-skill.sh — Verifies debugging-three-strikes is complete
# Task 2.14: stub (20 lines + GUIDE.md) → complete (≤85 lines, integrated, contracts)
#
# Usage: bash tests/test-three-strikes-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="debugging-three-strikes"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Three Strikes Test Suite${NC}"
echo "─────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has 3-strikes protocol documented" "grep -qi 'strike.*1\|strike.*2\|strike.*3\|3.*strike\|three.*strike' '$DIR/SKILL.md'"
assert "has escalation workflow" "grep -qi 'escalat\|root cause\|systemic\|route\|trigger.*review' '$DIR/SKILL.md'"
assert "mentions strike log or test tracking" "grep -qi 'strike.*log\|test.*name\|fail.*track\|STRIKES_LOG' '$DIR/SKILL.md'"
assert "mentions diagnosis before fix" "grep -qi 'diagnos\|inspect\|root cause\|evidence' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 85 lines (got $LINES)" "[ $LINES -le 85 ]"

assert "GUIDE.md no longer exists" "[ ! -f '$DIR/GUIDE.md' ]"

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "─────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
