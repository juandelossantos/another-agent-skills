#!/usr/bin/env bash
# test-deprecation-skill.sh — Verifies deprecation-and-migration is complete
# Task 2.7: stub (30 lines) → complete (≤150 lines, 2 guides)
#
# Usage: bash tests/test-deprecation-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="deprecation-and-migration"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Deprecation Skill Test Suite${NC}"
echo "────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Deprecation Lifecycle section" "grep -qi 'lifecycle\|Announce\|Deprecate\|Sunset' '$DIR/SKILL.md'"
assert "has Migration Strategies section" "grep -qi 'Migration\|strangler\|parallel run\|big bang' '$DIR/SKILL.md'"
assert "has Backward Compatibility section" "grep -qi 'Backward\|compat' '$DIR/SKILL.md'"
assert "has Communication section" "grep -qi 'Communication\|notice\|template' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 150 lines (got $LINES)" "[ $LINES -le 150 ]"

mkdir -p "$DIR/guides"
assert "guides/MIGRATION-STRATEGIES.md exists" "[ -f '$DIR/guides/MIGRATION-STRATEGIES.md' ]"
if [ -f "$DIR/guides/MIGRATION-STRATEGIES.md" ]; then
  MS=$(wc -l < "$DIR/guides/MIGRATION-STRATEGIES.md")
  assert "MIGRATION-STRATEGIES.md ≥ 50 lines (got $MS)" "[ $MS -ge 50 ]"
fi

assert "guides/DEPRECATION-COMMUNICATION.md exists" "[ -f '$DIR/guides/DEPRECATION-COMMUNICATION.md' ]"
if [ -f "$DIR/guides/DEPRECATION-COMMUNICATION.md" ]; then
  DC=$(wc -l < "$DIR/guides/DEPRECATION-COMMUNICATION.md")
  assert "DEPRECATION-COMMUNICATION.md ≥ 50 lines (got $DC)" "[ $DC -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
