#!/usr/bin/env bash
# test-interview-me-skill.sh — Verifies interview-me is complete
# Task 2.11: stub (36 lines) → complete (≤120 lines, 2 guides)
#
# Usage: bash tests/test-interview-me-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="interview-me"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Interview Me Test Suite${NC}"
echo "─────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has protocol or step-based process" "grep -qi 'step\|protocol\|phase\|stage' '$DIR/SKILL.md'"
assert "has question templates section" "grep -qi 'question template\|opener\|prober\|confirmer' '$DIR/SKILL.md'"
assert "has confidence heuristics" "grep -qi 'confiden\|0-100\|threshold\|≥80\|score' '$DIR/SKILL.md'"
assert "has Output Contract section" "grep -q '## Output Contract' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"
assert "mentions INTENT.md" "grep -qi 'INTENT.md\|intent' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 120 lines (got $LINES)" "[ $LINES -le 120 ]"

mkdir -p "$DIR/guides"
assert "guides/INTERVIEW-PROTOCOL.md exists" "[ -f '$DIR/guides/INTERVIEW-PROTOCOL.md' ]"
if [ -f "$DIR/guides/INTERVIEW-PROTOCOL.md" ]; then
  IP=$(wc -l < "$DIR/guides/INTERVIEW-PROTOCOL.md")
  assert "INTERVIEW-PROTOCOL.md ≥ 50 lines (got $IP)" "[ $IP -ge 50 ]"
fi

assert "guides/MOM-TEST-GUIDE.md exists" "[ -f '$DIR/guides/MOM-TEST-GUIDE.md' ]"
if [ -f "$DIR/guides/MOM-TEST-GUIDE.md" ]; then
  MT=$(wc -l < "$DIR/guides/MOM-TEST-GUIDE.md")
  assert "MOM-TEST-GUIDE.md ≥ 30 lines (got $MT)" "[ $MT -ge 30 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "─────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
