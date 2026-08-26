#!/usr/bin/env bash
# test-commit-approval.sh — Tests for .claude-plugin/agent-discipline/hooks/commit-approval.sh
#
# Simulates the JSON payload Claude Code sends on stdin for a PreToolUse/Bash
# hook and asserts the correct exit code (0 = allow, 2 = block) for each case.
# Uses .git/DECISION_APPROVED (the repo's current approval-token scheme —
# see rules/common/enforcement.md), not the retired .git/COMMIT_APPROVED.

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
assert_exit "blocks git commit without DECISION_APPROVED token" 2 "$?"

echo "$(date -Iseconds)" > "$TMP_REPO/.git/DECISION_APPROVED"
echo "git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "allows git commit with a fresh DECISION_APPROVED token" 0 "$?"

# No UTC/offset suffix — matches how the hook's regex reads a real
# DECISION_APPROVED token (it strips the offset and lets `date -d`
# interpret the bare timestamp as local time, same as the token writer).
date -d "-11 minutes" +"%Y-%m-%dT%H:%M:%S" > "$TMP_REPO/.git/DECISION_APPROVED" 2>/dev/null \
  || date -v-11M +"%Y-%m-%dT%H:%M:%S" > "$TMP_REPO/.git/DECISION_APPROVED"
echo "git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks git commit with a stale (>10min) DECISION_APPROVED token" 2 "$?"
rm -f "$TMP_REPO/.git/DECISION_APPROVED"

echo "   git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks indented git commit (leading-whitespace fix)" 2 "$?"

rm -rf "$TMP_REPO"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
