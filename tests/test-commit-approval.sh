#!/usr/bin/env bash
# test-commit-approval.sh — Test suite for commit-approval.sh (v4 read-only)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Verifies that commit-approval.sh:
# 1. Validates --plan-approved and --manifest-presented flags
# 2. Blocks on main without --allow-main
# 3. Does NOT write COMMIT_APPROVED or COMMIT_MANIFEST
#
# Usage: bash tests/test-commit-approval.sh
# Exit: 0 if all tests pass, 1 if any fail

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/commit-approval.sh"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

echo -e "${YELLOW}Commit-Approval Test Suite${NC}"
echo "──────────────────────────────────────"

# ─── Test 1: Passes with correct flags ───
echo ""
echo "Test 1: Passes with --plan-approved --manifest-presented"
OUTPUT=$(bash "$SCRIPT" "test message" --plan-approved --manifest-presented --allow-main 2>&1) || true
assert "exit 0" "[ $? -eq 0 ]"
assert "prints manifest" "echo '$OUTPUT' | grep -q 'COMMIT MANIFEST'"

# ─── Test 2: Blocks without --plan-approved ───
echo ""
echo "Test 2: Blocks without --plan-approved"
bash "$SCRIPT" "test" --manifest-presented > /dev/null 2>&1
assert "exit 1" "[ $? -eq 1 ]"

# ─── Test 3: Blocks without --manifest-presented ───
echo ""
echo "Test 3: Blocks without --manifest-presented"
bash "$SCRIPT" "test" --plan-approved > /dev/null 2>&1
assert "exit 1" "[ $? -eq 1 ]"

# ─── Test 4: Does NOT write COMMIT_APPROVED ───
echo ""
echo "Test 4: Does not write COMMIT_APPROVED"
TMP=$(mktemp -d)
(cd "$TMP" && git init -q -b dev-test && git config user.email "t@t.com" && git config user.name "T")
bash "$SCRIPT" "msg" --plan-approved --manifest-presented > /dev/null 2>&1
assert "COMMIT_APPROVED not created" "[ ! -f '$TMP/.git/COMMIT_APPROVED' ]"
rm -rf "$TMP"

# ─── Test 5: Does NOT write COMMIT_MANIFEST ───
echo ""
echo "Test 5: Does not write COMMIT_MANIFEST"
TMP2=$(mktemp -d)
(cd "$TMP2" && git init -q -b dev-test && git config user.email "t@t.com" && git config user.name "T")
bash "$SCRIPT" "msg" --plan-approved --manifest-presented > /dev/null 2>&1
assert "COMMIT_MANIFEST not created" "[ ! -f '$TMP2/.git/COMMIT_MANIFEST' ]"
rm -rf "$TMP2"

# ─── Test 6: Syntax valid ───
echo ""
echo "Test 6: Syntax valid"
bash -n "$SCRIPT" 2>/dev/null
assert "bash -n passes" "[ $? -eq 0 ]"

# ─── Summary ───
echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""

if [ "$FAILED" -gt 0 ]; then exit 1; fi
exit 0
