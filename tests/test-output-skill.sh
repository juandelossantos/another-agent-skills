#!/usr/bin/env bash
# test-output-skill.sh — Verifies output-skill is complete
# Task 2.13: stub (48 lines) → complete (≤120 lines, 1 guide)
#
# Usage: bash tests/test-output-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="output-skill"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Output Skill Test Suite${NC}"
echo "─────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has workflow phases or process" "grep -qi 'phase\|scope\|output\|self-audit\|cross-check' '$DIR/SKILL.md'"
assert "has placeholder detection patterns" "grep -qi 'pattern\|detect\|truncat\|TODO\|ellipsis\|for brevity' '$DIR/SKILL.md'"
assert "has truncation or clean breakpoint protocol" "grep -qi 'truncat\|breakpoint\|continue\|remaining' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 120 lines (got $LINES)" "[ $LINES -le 120 ]"

mkdir -p "$DIR/guides"
assert "guides/OUTPUT-CHECKLIST.md exists" "[ -f '$DIR/guides/OUTPUT-CHECKLIST.md' ]"
if [ -f "$DIR/guides/OUTPUT-CHECKLIST.md" ]; then
  OC=$(wc -l < "$DIR/guides/OUTPUT-CHECKLIST.md")
  assert "OUTPUT-CHECKLIST.md ≥ 50 lines (got $OC)" "[ $OC -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "─────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
