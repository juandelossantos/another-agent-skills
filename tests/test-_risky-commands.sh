#!/usr/bin/env bash
# test-_risky-commands.sh — Unit tests for .claude-plugin/agent-discipline/hooks/_risky-commands.sh
# (the shared risky-command classification sourced by commit-approval.sh and
# pre-flight.sh — added after code review flagged their duplicated case
# statements as a desync risk).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_ROOT/.claude-plugin/agent-discipline/hooks/_risky-commands.sh"

PASSED=0; FAILED=0; TOTAL=0
assert_bool() {
  local name="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL + 1))
  if [ "$actual" = "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name (expected $expected, got $actual)"
    FAILED=$((FAILED + 1))
  fi
}

check() { if "$1" "$2"; then echo "true"; else echo "false"; fi; }

assert_bool "is_git_mutation_command: git commit -m x" "true" "$(check is_git_mutation_command 'git commit -m x')"
assert_bool "is_git_mutation_command: git push" "true" "$(check is_git_mutation_command 'git push')"
assert_bool "is_git_mutation_command: git status is NOT a mutation" "false" "$(check is_git_mutation_command 'git status')"

assert_bool "is_risky_command: git commit IS risky (upstream-behind still checked)" "true" "$(check is_risky_command 'git commit -m x')"
assert_bool "is_risky_command: rm -rf" "true" "$(check is_risky_command 'rm -rf dir')"
assert_bool "is_risky_command: ls is NOT risky" "false" "$(check is_risky_command 'ls -la')"

assert_bool "is_dirty_tree_risky_command: git commit is EXEMPT (staged=dirty is normal)" "false" "$(check is_dirty_tree_risky_command 'git commit -m x')"
assert_bool "is_dirty_tree_risky_command: git push IS gated on a clean tree" "true" "$(check is_dirty_tree_risky_command 'git push')"
assert_bool "is_dirty_tree_risky_command: rm -rf IS gated on a clean tree" "true" "$(check is_dirty_tree_risky_command 'rm -rf dir')"

TRIMMED="$(trim_leading_whitespace '   git commit -m x')"
assert_bool "trim_leading_whitespace strips leading spaces" "git commit -m x" "$TRIMMED"

# Regressions from the second code-review pass on PR #34.
assert_bool "word boundary: 'git commit-tree' (plumbing) is NOT misclassified as 'git commit'" "false" "$(check is_git_mutation_command 'git commit-tree abc123')"
assert_bool "word boundary: 'git pushx' is NOT misclassified as 'git push'" "false" "$(check is_git_mutation_command 'git pushx origin main')"
assert_bool "compound command: 'cd x && git push' is still detected" "true" "$(check is_git_mutation_command 'cd x && git push')"
assert_bool "compound command: 'git status; git commit -m x' is still detected" "true" "$(check is_git_mutation_command 'git status; git commit -m x')"
assert_bool "env-var prefix: 'FOO=bar git commit -m x' is still detected" "true" "$(check is_git_mutation_command 'FOO=bar git commit -m x')"
assert_bool "env command prefix: 'env FOO=bar git commit -m x' is still detected" "true" "$(check is_git_mutation_command 'env FOO=bar git commit -m x')"

# Rule 12b — a PR merge is a remote merge the agent must never run.
assert_bool "is_pr_merge_command: 'gh pr merge 42'" "true" "$(check is_pr_merge_command 'gh pr merge 42')"
assert_bool "is_pr_merge_command: 'gh -R owner/repo pr merge 42' (flags-aware)" "true" "$(check is_pr_merge_command 'gh -R owner/repo pr merge 42')"
assert_bool "is_pr_merge_command: 'gh pr create' is NOT a merge" "false" "$(check is_pr_merge_command 'gh pr create --base main')"
assert_bool "is_pr_merge_command: 'gh pr view 42' is NOT a merge" "false" "$(check is_pr_merge_command 'gh pr view 42')"

# Stale-reference regression: the shared classifier mirrors the OpenCode plugin
# at plugins/agent-discipline/index.js, not the deleted src/lib.ts path.
TOTAL=$((TOTAL + 1))
if grep -q '\.opencode/plugins/agent-discipline' "$REPO_ROOT/.claude-plugin/agent-discipline/hooks/_risky-commands.sh"; then
  echo -e "  ${RED}✗${NC} still references the deleted .opencode plugin path"
  FAILED=$((FAILED + 1))
else
  echo -e "  ${GREEN}✓${NC} no reference to the deleted .opencode plugin path"
  PASSED=$((PASSED + 1))
fi

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
