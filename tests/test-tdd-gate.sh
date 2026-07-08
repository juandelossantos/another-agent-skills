#!/usr/bin/env bash
# test-tdd-gate.sh — Test suite for the TDD Gate (Phase 0)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# These tests validate the TDD pre-commit gate behavior.
# Gate script: scripts/tdd-gate.sh
#
# Usage: bash tests/test-tdd-gate.sh
# Exit: 0 if all tests pass, 1 if any fail

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE_SCRIPT="$REPO_ROOT/scripts/tdd-gate.sh"
TESTS_DIR=$(mktemp -d)
PASSED=0
FAILED=0
TOTAL=0

cleanup() {
  rm -rf "$TESTS_DIR"
}
trap cleanup EXIT

# Helper: create a temp git repo with isolated config
setup_repo() {
  local repo="$TESTS_DIR/repo-$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" config user.email "test@test.com"
  git -C "$repo" config user.name "Test"
  echo "# test" > "$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -q -m "init"
  mkdir -p "$repo/tests"
  echo "$repo"
}

# Helper: assert exit code
assert_exit() {
  local test_name="$1"
  local expected="$2"
  local actual="$3"
  TOTAL=$((TOTAL + 1))
  if [ "$actual" -eq "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} $test_name (exit=$actual)"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $test_name — expected exit $expected, got $actual"
    FAILED=$((FAILED + 1))
  fi
}

echo -e "${YELLOW}TDD Gate Test Suite${NC}"
echo "──────────────────────────────────"

# ─── Test 1: Code-only staged → BLOCK ───
echo ""
echo "Test 1: Code-only staged (expect BLOCK)"
REPO=$(setup_repo 1)
touch "$REPO/foo.js"
git -C "$REPO" add foo.js
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "Code-only staged → BLOCK" 1 "$ACTUAL"

# ─── Test 2: Code + test staged → PASS ───
echo ""
echo "Test 2: Code + test staged (expect PASS)"
REPO=$(setup_repo 2)
touch "$REPO/foo.js" "$REPO/foo.test.js"
git -C "$REPO" add .
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "Code + test staged → PASS" 0 "$ACTUAL"

# ─── Test 3: No code staged → SKIP ───
echo ""
echo "Test 3: No code staged (expect SKIP/PASS)"
REPO=$(setup_repo 3)
touch "$REPO/docs.md"
git -C "$REPO" add docs.md
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "No code staged → PASS" 0 "$ACTUAL"

# ─── Test 4: OVERRIDE in commit message → PASS ───
echo ""
echo "Test 4: OVERRIDE in message (expect PASS)"
REPO=$(setup_repo 4)
touch "$REPO/bar.ts"
git -C "$REPO" add bar.ts
(cd "$REPO" && COMMIT_MSG=$'fix: typo\n\nOVERRIDE: typo-only change' bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "OVERRIDE in message → PASS" 0 "$ACTUAL"

# ─── Test 5: Test in tests/ directory → PASS ───
echo ""
echo "Test 5: Test in tests/ directory (expect PASS)"
REPO=$(setup_repo 5)
touch "$REPO/app.py"
touch "$REPO/tests/test_app.py"
git -C "$REPO" add .
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "Test in tests/ dir → PASS" 0 "$ACTUAL"

# ─── Test 6: test_ prefix → PASS ───
echo ""
echo "Test 6: test_ prefix (expect PASS)"
REPO=$(setup_repo 6)
touch "$REPO/main.go" "$REPO/test_main.go"
git -C "$REPO" add .
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "test_ prefix → PASS" 0 "$ACTUAL"

# ─── Test 7: _spec suffix → PASS ───
echo ""
echo "Test 7: _spec suffix (expect PASS)"
REPO=$(setup_repo 7)
touch "$REPO/handler.rb" "$REPO/handler_spec.rb"
git -C "$REPO" add .
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "_spec suffix → PASS" 0 "$ACTUAL"

# ─── Test 8: Config-only → SKIP ───
echo ""
echo "Test 8: Config-only staged (expect SKIP/PASS)"
REPO=$(setup_repo 8)
touch "$REPO/config.json"
git -C "$REPO" add config.json
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "Config-only → PASS" 0 "$ACTUAL"

# ─── Test 9: Extensionless shell script (shebang) without test → BLOCK ───
echo ""
echo "Test 9: Extensionless script with shebang, no test (expect BLOCK)"
REPO=$(setup_repo 9)
mkdir -p "$REPO/scripts/git-hooks"
printf '#!/usr/bin/env bash\necho hello\n' > "$REPO/scripts/git-hooks/pre-commit"
chmod +x "$REPO/scripts/git-hooks/pre-commit"
git -C "$REPO" add scripts/git-hooks/pre-commit
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "Extensionless shebang script → BLOCK" 1 "$ACTUAL"

# ─── Test 10: Extensionless shell script with test → PASS ───
echo ""
echo "Test 10: Extensionless script with shebang, with test (expect PASS)"
REPO=$(setup_repo 10)
mkdir -p "$REPO/scripts/git-hooks" "$REPO/tests"
printf '#!/usr/bin/env bash\necho hello\n' > "$REPO/scripts/git-hooks/pre-commit"
chmod +x "$REPO/scripts/git-hooks/pre-commit"
touch "$REPO/tests/test_pre-commit.sh"
git -C "$REPO" add .
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "Extensionless shebang script + test → PASS" 0 "$ACTUAL"

# ─── Test 11: Binary shebang (#!/bin/sh) without test → BLOCK ───
echo ""
echo "Test 11: #!/bin/sh script without test (expect BLOCK)"
REPO=$(setup_repo 11)
printf '#!/bin/sh\necho hello\n' > "$REPO/my-tool"
chmod +x "$REPO/my-tool"
git -C "$REPO" add my-tool
(cd "$REPO" && bash "$GATE_SCRIPT" > /dev/null 2>&1)
ACTUAL=$?
assert_exit "#!/bin/sh script → BLOCK" 1 "$ACTUAL"

# ─── Summary ───
echo ""
echo "──────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
