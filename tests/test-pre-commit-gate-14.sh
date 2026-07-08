#!/usr/bin/env bash
# test-pre-commit-gate-14.sh — Behavioral test for pre-commit Gate 14 (Test Runner)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Verifies that Gate 14 correctly invokes tests/run-all.sh and:
# 1. Passes when run-all.sh returns 0
# 2. Blocks when run-all.sh returns 1
# 3. Skips when run-all.sh doesn't exist
#
# Extracts and tests the Gate 14 logic in isolation.
#
# Usage: bash tests/test-pre-commit-gate-14.sh
# Exit: 0 if all tests pass, 1 if any fail

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR=$(mktemp -d)
PASSED=0
FAILED=0
TOTAL=0

cleanup() {
  rm -rf "$TESTS_DIR"
}
trap cleanup EXIT

assert() {
  local test_name="$1"
  local condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $test_name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $test_name"
    FAILED=$((FAILED + 1))
  fi
}

# The Gate 14 logic from pre-commit as a reusable function.
# Takes: REPO_ROOT path
# Returns: 0 = PASS/SKIP, 1 = FAIL
run_gate_14() {
  local root="$1"
  local runner="${root}/tests/run-all.sh"
  if [ -f "$runner" ]; then
    if bash "$runner" > /dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}

echo -e "${YELLOW}Pre-Commit Gate 14 Behavioral Test Suite${NC}"
echo "──────────────────────────────────────────────"

# ─── Test 1: Pass when run-all.sh returns 0 ───
echo ""
echo "Test 1: Gate 14 passes when tests pass"
TMP1="$TESTS_DIR/gate14-pass"
mkdir -p "$TMP1/tests"
cat > "$TMP1/tests/run-all.sh" << 'SCRIPT'
#!/usr/bin/env bash
echo "All tests passed"
exit 0
SCRIPT
chmod +x "$TMP1/tests/run-all.sh"
run_gate_14 "$TMP1"
assert "run-all.sh returns 0 → exit 0" "[ $? -eq 0 ]"

# ─── Test 2: Block when run-all.sh returns 1 ───
echo ""
echo "Test 2: Gate 14 blocks when tests fail"
TMP2="$TESTS_DIR/gate14-fail"
mkdir -p "$TMP2/tests"
cat > "$TMP2/tests/run-all.sh" << 'SCRIPT'
#!/usr/bin/env bash
echo "Test suite failed"
exit 1
SCRIPT
chmod +x "$TMP2/tests/run-all.sh"
run_gate_14 "$TMP2"
assert "run-all.sh returns 1 → exit 1" "[ $? -eq 1 ]"

# ─── Test 3: Skip when run-all.sh doesn't exist ───
echo ""
echo "Test 3: Gate 14 skips when no run-all.sh"
TMP3="$TESTS_DIR/gate14-norunner"
mkdir -p "$TMP3/tests"
# Don't create run-all.sh
run_gate_14 "$TMP3"
assert "no run-all.sh → exit 0 (skip)" "[ $? -eq 0 ]"

# ─── Test 4: Gate 14 in actual pre-commit hook contains correct logic ───
echo ""
echo "Test 4: Gate 14 logic exists in pre-commit hook"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"
assert "pre-commit hook contains 'TEST RUNNER' header" "grep -q 'TEST RUNNER' '$HOOK'"
assert "pre-commit hook contains 'tests/run-all.sh' reference" "grep -q 'tests/run-all.sh' '$HOOK'"
assert "pre-commit hook has Gate 14 comment" "grep -q '^# Gate 14: Test Runner' '$HOOK'"

# ─── Test 5: pre-commit bash syntax still valid ───
echo ""
echo "Test 5: pre-commit hook syntax valid"
bash -n "$HOOK" 2>/dev/null
assert "bash -n passes" "[ $? -eq 0 ]"

# ─── Summary ───
echo ""
echo "──────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
