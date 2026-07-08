#!/usr/bin/env bash
# test-code-simplification-skill.sh — Verifies code-simplification is complete
# Task 2.9: stub (36 lines) → complete (≤150 lines, 2 guides)
#
# Usage: bash tests/test-code-simplification-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="code-simplification"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Code Simplification Test Suite${NC}"
echo "─────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Simplicity Heuristics section" "grep -qi 'heuristic\|complexity\|Beck\|4 rules\|simple design' '$DIR/SKILL.md'"
assert "has Refactoring Decision section" "grep -qi 'refactor\|decision\|extract\|replace\|remove' '$DIR/SKILL.md'"
assert "has When NOT to Use section" "grep -qi 'When NOT to Use\|not.*simplif' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 150 lines (got $LINES)" "[ $LINES -le 150 ]"

mkdir -p "$DIR/guides"
assert "guides/SIMPLIFICATION-HEURISTICS.md exists" "[ -f '$DIR/guides/SIMPLIFICATION-HEURISTICS.md' ]"
if [ -f "$DIR/guides/SIMPLIFICATION-HEURISTICS.md" ]; then
  SH=$(wc -l < "$DIR/guides/SIMPLIFICATION-HEURISTICS.md")
  assert "SIMPLIFICATION-HEURISTICS.md ≥ 50 lines (got $SH)" "[ $SH -ge 50 ]"
fi

assert "guides/REFACTORING-DECISIONS.md exists" "[ -f '$DIR/guides/REFACTORING-DECISIONS.md' ]"
if [ -f "$DIR/guides/REFACTORING-DECISIONS.md" ]; then
  RD=$(wc -l < "$DIR/guides/REFACTORING-DECISIONS.md")
  assert "REFACTORING-DECISIONS.md ≥ 50 lines (got $RD)" "[ $RD -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "─────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
