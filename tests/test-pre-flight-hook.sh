#!/usr/bin/env bash
# test-pre-flight-hook.sh — Tests for .claude-plugin/agent-discipline/hooks/pre-flight.sh
#
# Confirms it scopes to actually-risky commands only (unlike a blanket
# "Bash(git *)" matcher, which would also block routine `git status`), and
# blocks risky commands on a dirty tree with the correct Claude Code exit code.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_ROOT/.claude-plugin/agent-discipline/hooks/pre-flight.sh"

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
assert_exit "allows non-risky command (git status) even if tree is dirty later" 0 "$?"

echo "git push" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "allows risky command (git push) on a clean tree" 0 "$?"

echo "dirty" >> "$TMP_REPO/f"
echo "git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks risky command (git commit) on a dirty tree" 2 "$?"

echo "rm -rf somedir" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks rm -rf on a dirty tree" 2 "$?"

git -C "$TMP_REPO" checkout -q f
rm -rf "$TMP_REPO"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
