#!/usr/bin/env bash
# test-pre-flight-hook.sh — Tests for .claude-plugin/agent-discipline/hooks/pre-flight.sh
#
# Confirms it scopes to actually-risky commands only (unlike a blanket
# "Bash(git *)" matcher, which would also block routine `git status`), blocks
# risky commands on a dirty tree with the correct Claude Code exit code, and
# — critically — does NOT block a normal `git commit` on staged changes
# (staged = dirty is commit's expected precondition, not a danger sign).

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
echo "git push" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks git push on a dirty (unstaged) tree" 2 "$?"

echo "rm -rf somedir" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "blocks rm -rf on a dirty tree" 2 "$?"

# The regression this test suite missed before code review caught it live:
# staging a change for commit makes the tree "dirty" too, but committing
# staged changes is the ONLY normal way `git commit` is ever invoked.
git -C "$TMP_REPO" add f
echo "git commit -m x" | jq -Rn '{tool_input:{command: input}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "allows git commit on a normal staged-for-commit tree (regression)" 0 "$?"

git -C "$TMP_REPO" checkout -q f

# Regression: jq missing at hook-run time must fail open WITH a visible
# warning, not silently.
NO_JQ_DIR="$(mktemp -d)"
for tool in bash cat grep sed date git dirname mktemp head tr; do
  t="$(command -v "$tool" 2>/dev/null)"
  [ -n "$t" ] && ln -sf "$t" "$NO_JQ_DIR/$tool"
done
WARNING="$(PATH="$NO_JQ_DIR" bash "$HOOK" 2>&1 <<<'{"tool_input":{"command":"git push"}}' >/dev/null)"
WARN_EXIT=$?
rm -rf "$NO_JQ_DIR"
assert_exit "exits 0 (fail-open) when jq is unavailable" 0 "$WARN_EXIT"
TOTAL=$((TOTAL + 1))
if echo "$WARNING" | grep -q "jq not found"; then
  echo -e "  ${GREEN}✓${NC} prints a visible warning when jq is unavailable (not silent)"
  PASSED=$((PASSED + 1))
else
  echo -e "  ${RED}✗${NC} prints a visible warning when jq is unavailable (not silent) — got: $WARNING"
  FAILED=$((FAILED + 1))
fi

# Stale-reference regression: the hook mirrors plugins/agent-discipline/index.js
# (not the deleted src/lib.ts), and no longer claims an approval-token gate.
TOTAL=$((TOTAL + 1))
if grep -q '\.opencode/plugins/agent-discipline\|approval-token' "$HOOK"; then
  echo -e "  ${RED}✗${NC} still references a stale path or token"
  FAILED=$((FAILED + 1))
else
  echo -e "  ${GREEN}✓${NC} no stale path/token reference"
  PASSED=$((PASSED + 1))
fi

rm -rf "$TMP_REPO"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
