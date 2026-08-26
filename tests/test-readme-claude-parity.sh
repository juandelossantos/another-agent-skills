#!/usr/bin/env bash
# test-readme-claude-parity.sh — Content check for README.md: the Agent
# Compatibility table credits Claude Code with global auto-installed skills.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/README.md"

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

assert "compatibility table has a global-skills row" "grep -q '57 skills installed globally' '$FILE'"
assert "row credits Claude Code with ~/.claude/skills/ auto" "grep -q 'auto → \`~/.claude/skills/\`' '$FILE'"
assert "Quick Start still documents --agent claude" "grep -q 'install.sh --agent claude' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
