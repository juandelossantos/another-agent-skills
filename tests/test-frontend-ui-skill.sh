#!/usr/bin/env bash
# test-frontend-ui-skill.sh — Verifies frontend-ui-engineering is complete
# Task 2.6: stub (44 lines) → complete (≤250 lines, 2 guides)
#
# Usage: bash tests/test-frontend-ui-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
SKILL="frontend-ui-engineering"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Frontend UI Skill Test Suite${NC}"
echo "───────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Component Architecture section" "grep -qi 'Component\|composition' '$DIR/SKILL.md'"
assert "has State Management section" "grep -qi 'State\|context\|lift' '$DIR/SKILL.md'"
assert "has Layout section" "grep -qi 'Layout\|grid\|flexbox\|responsive' '$DIR/SKILL.md'"
assert "has Accessibility section" "grep -qi 'Accessibility\|contrast\|focus\|ARIA' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 250 lines (got $LINES)" "[ $LINES -le 250 ]"

mkdir -p "$DIR/guides"
assert "guides/COMPONENT-ARCHITECTURE.md exists" "[ -f '$DIR/guides/COMPONENT-ARCHITECTURE.md' ]"
if [ -f "$DIR/guides/COMPONENT-ARCHITECTURE.md" ]; then
  CA=$(wc -l < "$DIR/guides/COMPONENT-ARCHITECTURE.md")
  assert "COMPONENT-ARCHITECTURE.md ≥ 50 lines (got $CA)" "[ $CA -ge 50 ]"
fi

assert "guides/STATE-MANAGEMENT.md exists" "[ -f '$DIR/guides/STATE-MANAGEMENT.md' ]"
if [ -f "$DIR/guides/STATE-MANAGEMENT.md" ]; then
  SM=$(wc -l < "$DIR/guides/STATE-MANAGEMENT.md")
  assert "STATE-MANAGEMENT.md ≥ 50 lines (got $SM)" "[ $SM -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "───────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
