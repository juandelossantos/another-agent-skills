#!/usr/bin/env bash
# test-ci-cd-skill.sh — Verifies ci-cd-and-automation is complete
# Task 2.4: stub (35 lines) → complete (≤250 lines, 2 guides)
#
# Usage: bash tests/test-ci-cd-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
SKILL="ci-cd-and-automation"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}CI/CD Skill Test Suite${NC}"
echo "───────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Pipeline Design section" "grep -qi 'Pipeline\|stages' '$DIR/SKILL.md'"
assert "has Quality Gates section" "grep -qi 'Quality gate\|gate' '$DIR/SKILL.md'"
assert "has Deployment Strategies section" "grep -qi 'Deploy\|blue-green\|canary\|rolling' '$DIR/SKILL.md'"
assert "has Secrets Management section" "grep -qi 'Secret\|credential' '$DIR/SKILL.md'"
assert "has Rollback section" "grep -qi 'Rollback\|revert' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 250 lines (got $LINES)" "[ $LINES -le 250 ]"

mkdir -p "$DIR/guides"
assert "guides/PIPELINE-TEMPLATES.md exists" "[ -f '$DIR/guides/PIPELINE-TEMPLATES.md' ]"
if [ -f "$DIR/guides/PIPELINE-TEMPLATES.md" ]; then
  PT=$(wc -l < "$DIR/guides/PIPELINE-TEMPLATES.md")
  assert "PIPELINE-TEMPLATES.md ≥ 50 lines (got $PT)" "[ $PT -ge 50 ]"
fi

assert "guides/QUALITY-GATES.md exists" "[ -f '$DIR/guides/QUALITY-GATES.md' ]"
if [ -f "$DIR/guides/QUALITY-GATES.md" ]; then
  QG=$(wc -l < "$DIR/guides/QUALITY-GATES.md")
  assert "QUALITY-GATES.md ≥ 50 lines (got $QG)" "[ $QG -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "───────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
