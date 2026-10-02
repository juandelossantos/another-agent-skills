#!/usr/bin/env bash
# test-pre-commit-no-task-dir.sh — regression: pre-commit must not fail in a
# project that has no tests/task/ working set.
#
# Bug (found by the P8.7 remote-enforcement E2E): the hook runs under
# `set -euo pipefail`, and `find "$REPO_ROOT/tests/task" ... | wc -l` fails when
# that directory does not exist. pipefail turns that into a hook failure, so
# every commit was blocked in a fresh init-agents project (which has no
# tests/task/). The count gate must guard the directory.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_SRC="$REPO_ROOT/scripts/git-hooks/pre-commit"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

# --- Static: the directory is guarded ---
assert "source guards the tests/task directory" "grep -q 'if \[ -d \"\${REPO_ROOT}/tests/task\" \]' '$HOOK_SRC'"
assert "defaults the count to 0 when absent" "grep -q 'TASK_TEST_COUNT=0' '$HOOK_SRC'"

# --- Behavioral: pre-commit passes in a project without tests/task/ ---
TMP=$(mktemp -d)
(
  cd "$TMP"
  git init -q
  git checkout -q -b work 2>/dev/null || true
  git config user.email t@t.com
  git config user.name T
  git config commit.gpgsign false
  echo "# init" > README.md
  git add README.md && git commit -q -m init
  mkdir -p .git/hooks
  cp "$HOOK_SRC" .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  printf '%s decision\n' "$(date +%Y-%m-%dT%H:%M:%S)" > .git/DECISION_APPROVED
  echo "note" > a.txt
  git add a.txt
) >/dev/null 2>&1

# A fresh project has no tests/task/ — assert that explicitly, then run the hook.
assert "the temp project has no tests/task/" "[ ! -d '$TMP/tests/task' ]"
( cd "$TMP" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR bash .git/hooks/pre-commit ) >/dev/null 2>&1
HOOK_EXIT=$?
assert "pre-commit exits 0 without tests/task/ (no false block)" "[ $HOOK_EXIT -eq 0 ]"

rm -rf "$TMP"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
