#!/usr/bin/env bash
# test-api-design-skill.sh — Verifies api-and-interface-design is complete
# Task 2.3: stub (39 lines) → complete (≤250 lines, 2 guides)
#
# Usage: bash tests/test-api-design-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
SKILL="api-and-interface-design"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}API Design Skill Test Suite${NC}"
echo "─────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Protocol Selection section" "grep -qi 'REST\|GraphQL\|gRPC' '$DIR/SKILL.md'"
assert "has Contract Design section" "grep -qi 'Contract\|OpenAPI\|Schema' '$DIR/SKILL.md'"
assert "has Versioning section" "grep -qi 'Versioning\|breaking' '$DIR/SKILL.md'"
assert "has Module Boundaries section" "grep -qi 'Module boundary\|Dependency' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 250 lines (got $LINES)" "[ $LINES -le 250 ]"

mkdir -p "$DIR/guides"
assert "guides/CONTRACT-TEMPLATES.md exists" "[ -f '$DIR/guides/CONTRACT-TEMPLATES.md' ]"
if [ -f "$DIR/guides/CONTRACT-TEMPLATES.md" ]; then
  CT=$(wc -l < "$DIR/guides/CONTRACT-TEMPLATES.md")
  assert "CONTRACT-TEMPLATES.md ≥ 50 lines (got $CT)" "[ $CT -ge 50 ]"
fi

assert "guides/VERSIONING-STRATEGIES.md exists" "[ -f '$DIR/guides/VERSIONING-STRATEGIES.md' ]"
if [ -f "$DIR/guides/VERSIONING-STRATEGIES.md" ]; then
  VS=$(wc -l < "$DIR/guides/VERSIONING-STRATEGIES.md")
  assert "VERSIONING-STRATEGIES.md ≥ 50 lines (got $VS)" "[ $VS -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "─────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
