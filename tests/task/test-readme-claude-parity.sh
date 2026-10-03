#!/usr/bin/env bash
# test-readme-claude-parity.sh — Content check for README.md: the Agent
# Compatibility table credits Claude Code with global auto-installed skills.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
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
assert "version badge is v6.3.0" "grep -q 'Version: v6.3.0' '$FILE'"
assert "README states the real guide count (151)" "grep -q '151 guides' '$FILE'"
assert "the single What's New section is v6.3.0" "grep -q \"## What's New in v6.3.0\" '$FILE'"
assert "no older v6.1.0 What's New section remains" "! grep -q \"What's New in v6.1.0\" '$FILE'"
assert "documents the Phase-7 flags as POSIX-only" "grep -qi 'Phase-7 installer flags' '$FILE' && grep -qi 'POSIX-only' '$FILE'"
assert "points Windows users at install.sh for the Phase-7 flags" "grep -qi 'install.ps1.*not yet these flags\|not yet these flags' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
