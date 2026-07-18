#!/usr/bin/env bash
# test-idea-refine-skill.sh — Verifies idea-refine is complete
# Task 2.10: stub (39 lines) → complete (≤120 lines, 2 guides)
#
# Usage: bash tests/test-idea-refine-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="idea-refine"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Idea Refine Test Suite${NC}"
echo "─────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Divergent Thinking section" "grep -qi 'diverg' '$DIR/SKILL.md'"
assert "has Convergent Thinking section" "grep -qi 'converg' '$DIR/SKILL.md'"
assert "has Double Diamond or equivalent process" "grep -qi 'double diamond\|diverge.*converge\|problem space.*solution space' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"
assert "has Facilitation Prompts section" "grep -qi 'facilitation\|prompts' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 120 lines (got $LINES)" "[ $LINES -le 120 ]"

mkdir -p "$DIR/guides"
assert "guides/DIVERGENT-CONVERGENT.md exists" "[ -f '$DIR/guides/DIVERGENT-CONVERGENT.md' ]"
if [ -f "$DIR/guides/DIVERGENT-CONVERGENT.md" ]; then
  DC=$(wc -l < "$DIR/guides/DIVERGENT-CONVERGENT.md")
  assert "DIVERGENT-CONVERGENT.md ≥ 50 lines (got $DC)" "[ $DC -ge 50 ]"
fi

assert "guides/FACILITATION-PROMPTS.md exists" "[ -f '$DIR/guides/FACILITATION-PROMPTS.md' ]"
if [ -f "$DIR/guides/FACILITATION-PROMPTS.md" ]; then
  FP=$(wc -l < "$DIR/guides/FACILITATION-PROMPTS.md")
  assert "FACILITATION-PROMPTS.md ≥ 30 lines (got $FP)" "[ $FP -ge 30 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "─────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
