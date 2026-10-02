#!/usr/bin/env bash
# test-sync-hooks.sh — Test sync-hooks subcommand (Phase 0, Task 0.5b)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Verifies that `bash scripts/init-agents.sh sync-hooks` copies hooks
# from scripts/git-hooks/ to .git/hooks/ without full re-init.
#
# Usage: bash tests/test-sync-hooks.sh
# Exit: 0 if all tests pass, 1 if any fail

set -uo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT_SCRIPT="$REPO_ROOT/scripts/init-agents.sh"

PASSED=0
FAILED=0
TOTAL=0

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

echo -e "${YELLOW}Sync Hooks Test Suite${NC}"
echo "──────────────────────────────────────────"

# ─── Test 1: init-agents.sh exists ───
echo ""
echo "Test 1: init-agents.sh exists"
assert "init-agents.sh exists" "[ -f '$INIT_SCRIPT' ]"

# ─── Test 2: sync-hooks subcommand exists ───
echo ""
echo "Test 2: sync-hooks subcommand exists in help"
HELP_OUTPUT=$(bash "$INIT_SCRIPT" --help 2>&1 || true)
echo "$HELP_OUTPUT" | grep -q "sync-hooks" > /dev/null 2>&1
assert "sync-hooks appears in help output" "[ $? -eq 0 ]"

# ─── Test 3: sync-hooks installs a portable pre-commit shim ───
echo ""
echo "Test 3: sync-hooks installs the portable pre-commit shim"
# Create a temp repo
TMP_REPO=$(mktemp -d)
git -C "$TMP_REPO" init -q
git -C "$TMP_REPO" config user.email "test@test.com"
git -C "$TMP_REPO" config user.name "Test"
# Make hooks dir
mkdir -p "$TMP_REPO/.git/hooks"
# Put an old custom hook in place
echo "# old hook" > "$TMP_REPO/.git/hooks/pre-commit"
# Run sync-hooks from the temp repo
(cd "$TMP_REPO" && bash "$INIT_SCRIPT" sync-hooks 2>&1)
assert "pre-commit is a portable shim" "grep -q 'AAS_DIR' '$TMP_REPO/.git/hooks/pre-commit'"
assert "pre-commit shim is thin (< 40 lines)" "[ \$(wc -l < '$TMP_REPO/.git/hooks/pre-commit') -lt 40 ]"
assert "sync-hooks writes .aas/config" "[ -f '$TMP_REPO/.aas/config' ]"

# ─── Test 4: sync-hooks installs a portable commit-msg shim ───
echo ""
echo "Test 4: sync-hooks installs the portable commit-msg shim"
assert "commit-msg is a portable shim" "grep -q 'AAS_DIR' '$TMP_REPO/.git/hooks/commit-msg'"

# ─── Test 5: sync-hooks makes hooks executable ───
echo ""
echo "Test 5: synced hooks are executable"
assert "pre-commit is executable" "[ -x '$TMP_REPO/.git/hooks/pre-commit' ]"
assert "commit-msg is executable" "[ -x '$TMP_REPO/.git/hooks/commit-msg' ]"

# ─── Test 6: sync-hooks backs up existing hooks (under .aas/backups/) ───
echo ""
echo "Test 6: sync-hooks backs up existing hooks"
BACKUP_COUNT=$(ls "$TMP_REPO/.aas/backups/"*pre-commit* 2>/dev/null | wc -l)
assert "backup file created (got $BACKUP_COUNT)" "[ '$BACKUP_COUNT' -ge 1 ]"

# Cleanup
rm -rf "$TMP_REPO"

# ─── Summary ───
echo ""
echo "──────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
