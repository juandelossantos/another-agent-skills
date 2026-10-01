#!/usr/bin/env bash
# test-edit-guard-hook.sh — Tests for .claude-plugin/agent-discipline/hooks/edit-guard.sh
#
# PreToolUse (record) must never block. PostToolUse (verify) must exit 0 when
# the line-count delta is small, exit 1 (non-blocking warning) when it exceeds
# the shared scripts/edit-guard.sh threshold.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_ROOT/.claude-plugin/agent-discipline/hooks/edit-guard.sh"

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
mkdir -p "$TMP_REPO/scripts"
cp "$REPO_ROOT/scripts/edit-guard.sh" "$TMP_REPO/scripts/"
export CLAUDE_PROJECT_DIR="$TMP_REPO"

seq 1 20 > "$TMP_REPO/big.txt"

jq -n --arg fp "$TMP_REPO/big.txt" '{hook_event_name: "PreToolUse", tool_input: {file_path: $fp}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "PreToolUse always allows (recording step)" 0 "$?"

jq -n --arg fp "$TMP_REPO/big.txt" '{hook_event_name: "PostToolUse", tool_input: {file_path: $fp}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "PostToolUse allows when file unchanged" 0 "$?"

echo "1" > "$TMP_REPO/big.txt"  # shrink 20 -> 1 line, well past the 20% threshold
jq -n --arg fp "$TMP_REPO/big.txt" '{hook_event_name: "PostToolUse", tool_input: {file_path: $fp}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "PostToolUse warns (non-blocking) on >20% line-count drop" 1 "$?"

echo "{}" | bash "$HOOK" >/dev/null 2>&1
assert_exit "no-op (exit 0) when file_path is missing from payload" 0 "$?"

# Regression: a brand-new file has no PreToolUse baseline (the shared script
# dies under `set -e` on cmd_lines() for a nonexistent file) — PostToolUse
# must not misreport this as a >20% content-drop warning.
rm -f "$TMP_REPO/created.txt"
jq -n --arg fp "$TMP_REPO/created.txt" '{hook_event_name: "PreToolUse", tool_input: {file_path: $fp}}' | bash "$HOOK" >/dev/null 2>&1
printf "a\nb\nc\nd\ne\n" > "$TMP_REPO/created.txt"
jq -n --arg fp "$TMP_REPO/created.txt" '{hook_event_name: "PostToolUse", tool_input: {file_path: $fp}}' | bash "$HOOK" >/dev/null 2>&1
assert_exit "PostToolUse does not false-positive-warn on a newly created file" 0 "$?"

# Regression: jq missing at hook-run time must fail open WITH a visible
# warning, not silently.
NO_JQ_DIR="$(mktemp -d)"
for tool in bash cat grep sed date git dirname mktemp head tr; do
  t="$(command -v "$tool" 2>/dev/null)"
  [ -n "$t" ] && ln -sf "$t" "$NO_JQ_DIR/$tool"
done
WARNING="$(PATH="$NO_JQ_DIR" bash "$HOOK" 2>&1 <<<"{\"hook_event_name\":\"PreToolUse\",\"tool_input\":{\"file_path\":\"$TMP_REPO/big.txt\"}}" >/dev/null)"
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

# Stale-reference regression: the hook mirrors plugins/agent-discipline/index.js,
# not the deleted .opencode/plugins/agent-discipline/src/lib.ts path.
TOTAL=$((TOTAL + 1))
if grep -q '\.opencode/plugins/agent-discipline' "$HOOK"; then
  echo -e "  ${RED}✗${NC} still references the deleted .opencode plugin path"
  FAILED=$((FAILED + 1))
else
  echo -e "  ${GREEN}✓${NC} no reference to the deleted .opencode plugin path"
  PASSED=$((PASSED + 1))
fi

rm -rf "$TMP_REPO"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
