#!/usr/bin/env bash
# test-commit-msg.sh — Test suite for commit-msg hook (no COMMIT_APPROVED dependency)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Verifies that commit-msg hook only depends on TDD gate,
# not on COMMIT_APPROVED, COMMIT_MANIFEST, or TEST_LOG.
#
# Usage: bash tests/test-commit-msg.sh
# Exit: 0 if all tests pass, 1 if any fail

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/commit-msg"
TDD_GATE="$REPO_ROOT/scripts/tdd-gate.sh"
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

# Helper: simulate commit-msg with TDD gate result
setup_repo() {
  local repo="$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" config user.email "test@test.com"
  git -C "$repo" config user.name "Test"
  echo "# test" > "$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -q -m "init"
  mkdir -p "$repo/tests" "$repo/scripts"
  # Reference the TDD gate by absolute path so the hook finds it
  echo '#!/usr/bin/env bash' > "$repo/scripts/tdd-gate.sh"
  echo "exec bash '$TDD_GATE' \"\$@\"" >> "$repo/scripts/tdd-gate.sh"
  chmod +x "$repo/scripts/tdd-gate.sh"
  mkdir -p "$repo/.git"
}

run_commit_msg() {
  local repo="$1"
  local msg="$2"
  local commit_msg_file="$repo/.git/COMMIT_EDITMSG"
  echo "$msg" > "$commit_msg_file"
  (cd "$repo" && bash "$HOOK" "$commit_msg_file" > /dev/null 2>&1)
  return $?
}

echo -e "${YELLOW}Commit-Msg Hook Test Suite${NC}"
echo "──────────────────────────────────────"

# ─── Test 1: Commit-msg passes without COMMIT_APPROVED, COMMIT_MANIFEST, or TEST_LOG ───
echo ""
echo "Test 1: Commit-msg passes without approval files (expect PASS)"
REPO1="$TESTS_DIR/repo1"
setup_repo "$REPO1"

# Stage code + test (TDD should pass)
touch "$REPO1/foo.js" "$REPO1/foo.test.js"
git -C "$REPO1" add foo.js foo.test.js

# Ensure NO approval files exist
rm -f "$REPO1/.git/COMMIT_APPROVED" "$REPO1/.git/COMMIT_MANIFEST" "$REPO1/.git/TEST_LOG"

run_commit_msg "$REPO1" "feat: add foo"
assert "Commit-msg passes without COMMIT_APPROVED" "[ $? -eq 0 ]"

# ─── Test 2: Commit-msg still blocks when TDD fails ───
echo ""
echo "Test 2: Commit-msg blocks when TDD fails (expect BLOCK)"
REPO2="$TESTS_DIR/repo2"
setup_repo "$REPO2"

# Stage code only (TDD should fail)
touch "$REPO2/bar.js"
git -C "$REPO2" add bar.js

run_commit_msg "$REPO2" "feat: add bar"
assert "Commit-msg blocks on TDD failure" "[ $? -eq 1 ]"

# ─── Test 3: Syntax valid ───
echo ""
echo "Test 3: Syntax valid"
bash -n "$HOOK" 2>/dev/null
assert "bash -n passes" "[ $? -eq 0 ]"

# ─── Test 4: Header says v4 with TDD gate ───
echo ""
echo "Test 4: Version is v4"
assert "version v4 in header" "head -3 '$HOOK' | grep -q 'v4'"
assert "TDD gate in header" "head -5 '$HOOK' | grep -qi 'TDD'"

# ─── Summary ───
echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
