#!/usr/bin/env bash
# test-skill-merge.sh — Verifies visual-frontend-mastery was merged into frontend-ui-engineering
# Task 2.5: delete duplicate skill, preserve eval cases
#
# Usage: bash tests/test-skill-merge.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
SKILLS="$(cd "$(dirname "$0")/.." && pwd)/skills"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Skill Merge Test Suite${NC}"
echo "────────────────────────────────────"

assert "visual-frontend-mastery directory deleted" "[ ! -d '$SKILLS/visual-frontend-mastery' ]"
assert "visual-frontend-mastery.html deleted" "[ ! -f '$(dirname "$SKILLS")/docs/skill/visual-frontend-mastery.html' ]"
assert "eval cases moved to frontend-ui-engineering" "[ -f '$SKILLS/frontend-ui-engineering/evals/trigger.jsonl' ]"
assert "no visual-frontend-mastery refs in AGENTS.md" "! grep -q 'visual-frontend-mastery' AGENTS.md"
assert "no refs in index.html" "! grep -q 'visual-frontend-mastery' index.html"
assert "no refs in docs/skills.html" "! grep -q 'visual-frontend-mastery' docs/skills.html"
assert "no refs in PATTERNS.md" "! grep -q 'visual-frontend-mastery' PATTERNS.md"
assert "no refs in ANTI-PATTERNS.md" "! grep -q 'visual-frontend-mastery' ANTI-PATTERNS.md"
assert "no refs in AGENTS-EXTENDED.md" "! grep -q 'visual-frontend-mastery' AGENTS-EXTENDED.md"

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
