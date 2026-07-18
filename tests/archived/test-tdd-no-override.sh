#!/usr/bin/env bash
# test-tdd-no-override.sh — Verifies TDD gate has no override bypass
# TDD gate must BLOCK any code change without a matching test, regardless of OVERRIDE text.
#
# Usage: bash tests/test-tdd-no-override.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE_SCRIPT="$REPO_ROOT/scripts/tdd-gate.sh"
PASSED=0; FAILED=0; TOTAL=0

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'

setup_repo() {
  local suffix="$1"
  local dir="$REPO_ROOT/.tdd_test_${suffix}_$$"
  mkdir -p "$dir"
  git init -q -b test-branch "$dir"
  git -C "$dir" config user.email "t@t.com"
  git -C "$dir" config user.name "T"
  echo "$dir"
}

cleanup() { rm -rf "$REPO_ROOT"/.tdd_test_*_$$ 2>/dev/null; }
trap cleanup EXIT

assert_exit() {
  local name="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL + 1))
  if [ "$actual" -eq "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} $name (exit=$actual)"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name — expected exit $expected, got $actual"
    FAILED=$((FAILED + 1))
  fi
}

echo -e "${YELLOW}TDD No-Override Test Suite${NC}"
echo "──────────────────────────────────────"

# Test: OVERRIDE in message must NOT bypass TDD
echo ""
echo "Test 1: OVERRIDE in message without test (expect BLOCK)"
REPO=$(setup_repo 1)
touch "$REPO/app.js"
git -C "$REPO" add app.js
(cd "$REPO" && COMMIT_MSG=$'fix: typo\n\nOVERRIDE: no test' bash "$GATE_SCRIPT" > /dev/null 2>&1)
assert_exit "OVERRIDE without test → BLOCK" 1 $?

# Test: OVERRIDE with matching test — still needs new test file
echo ""
echo "Test 2: OVERRIDE + pre-existing test (expect BLOCK — new test required)"
REPO=$(setup_repo 2)
touch "$REPO/util.js" "$REPO/tests/util.test.js"
git -C "$REPO" add .
(cd "$REPO" && COMMIT_MSG=$'fix: util\n\nOVERRIDE: existing test' bash "$GATE_SCRIPT" > /dev/null 2>&1)
assert_exit "OVERRIDE + pre-existing test → BLOCK" 1 $?

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
