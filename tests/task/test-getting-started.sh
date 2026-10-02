#!/usr/bin/env bash
# test-getting-started.sh — Content check for docs/getting-started.html: the
# Claude Code section reflects automatic skills+hooks install, not the old
# "copy rules into CLAUDE.md for skills" instruction (no longer true).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/docs/getting-started.html"

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

assert "claudeCodeDesc mentions ~/.claude/skills/ auto-discovery" "grep -q '~/.claude/skills/' '$FILE'"
assert "claudeCodeDesc mentions hooks wiring into .claude/settings.json" "grep -q '.claude/settings.json' '$FILE'"
assert "still notes SOUL.md/AGENTS.md rules stay manual" "grep -q 'that part stays manual' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
