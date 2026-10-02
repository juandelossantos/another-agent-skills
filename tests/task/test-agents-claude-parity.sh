#!/usr/bin/env bash
# test-agents-claude-parity.sh — Content checks for docs/agents.html: the
# "What Works Where" table now shows Auto for Claude Code's SKILL.md
# concepts row, matching the shipped ~/.claude/skills/ auto-install.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/docs/agents.html"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

SKILL_ROW=$(grep 'SKILL.md concepts' "$FILE")
assert "SKILL.md concepts row exists" "[ -n '$SKILL_ROW' ]"
assert "SKILL.md concepts row: OpenCode + Claude Code both Auto" "echo \"$SKILL_ROW\" | grep -qE '<td>Auto</td><td>Auto</td><td>Manual</td>'"
assert "subtitle mentions Claude Code alongside OpenCode" "grep -q 'automatically for OpenCode and Claude Code' '$FILE'"
assert "claudeCodeDesc mentions ~/.claude/skills/" "grep -q '~/.claude/skills/' '$FILE'"
assert "claudeCodeExample still shows the install command" "grep -q 'bash install.sh --agent claude' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
