#!/usr/bin/env bash
# test-commit-approval.sh — Tests for .claude-plugin/agent-discipline/hooks/commit-approval.sh
#
# Simulates the JSON payload Claude Code sends on stdin for a PreToolUse/Bash
# hook and asserts the correct exit code (0 = allow, 2 = block) for each case.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_ROOT/.claude-plugin/agent-discipline/hooks/commit-approval.sh"

PASSED=0; FAILED=0; TOTAL=0
assert_exit() {
  local name="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL + 1))
  if [ "$actual" -eq "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} $name (exit $actual)"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name (expected exit $expected, got $actual)"
    FAILED=$((FAILED + 1))
  fi
}

TMP_REPO=$(mktemp -d)
git -C "$TMP_REPO" init -q
git -C "$TMP_REPO" config user.email "test@test.com"
git -C "$TMP_REPO" config user.name "Test"
echo "x" > "$TMP_REPO/f"
git -C "$TMP_REPO" add f
git -C "$TMP_REPO" commit -qm init

export CLAUDE_PROJECT_DIR="$TMP_REPO"

echo "git status" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "allows non-blocked command (git status)" 0 "$?"

echo "git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks git commit without approval token" 2 "$?"

touch "$TMP_REPO/.git/COMMIT_APPROVED"
echo "git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "allows git commit with approval token" 0 "$?"
rm "$TMP_REPO/.git/COMMIT_APPROVED"

echo "   git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks indented git commit (leading-whitespace fix)" 2 "$?"

rm -rf "$TMP_REPO"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
