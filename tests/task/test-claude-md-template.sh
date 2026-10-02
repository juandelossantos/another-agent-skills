#!/usr/bin/env bash
# test-claude-md-template.sh — Content check for templates/CLAUDE.md: points
# at Claude Code's real global skills path, not the OpenCode-only one.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/templates/CLAUDE.md"

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

assert "points to ~/.claude/skills/ (Claude Code's real path)" "grep -q '~/.claude/skills/' '$FILE'"
assert "no longer points only at the OpenCode-only opencode/skills path" "! grep -q '~/.config/opencode/skills/' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
