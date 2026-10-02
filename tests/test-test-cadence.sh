#!/usr/bin/env bash
# test-test-cadence.sh — verifies the TASK-test cadence is wired end to end:
# the doc exists, the cap has a single source of truth, the pre-commit hook
# scopes the cap to tests/task/*.sh (not the persistent tests/test-*.sh), and
# the runner discovers the working set.
#
# Spec: docs/TEST-CADENCE.md
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOC="$REPO_ROOT/docs/TEST-CADENCE.md"
CONF="$REPO_ROOT/scripts/test-cadence.conf"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"
RUNNER="$REPO_ROOT/tests/run-all.sh"

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

echo ""
echo "TEST-CADENCE — task working set, single source of truth"
echo "───────────────────────────────────────────────────────"

# ─── Doc ───
assert "docs/TEST-CADENCE.md exists" "[ -f '$DOC' ]"
assert "doc states the cap (20)" "grep -q 'MAX_TASK_TESTS=20' '$DOC'"
assert "doc names the working set (tests/task)" "grep -q 'tests/task' '$DOC'"
assert "doc names the archive step" "grep -q 'tests/archived' '$DOC'"
assert "doc says behavioral tests are not counted" "grep -qi 'behavioral.*not counted\|not counted' '$DOC'"
assert "doc describes the cadence/checkpoint" "grep -qi 'cadence' '$DOC'"

# ─── Single source of truth ───
assert "scripts/test-cadence.conf exists" "[ -f '$CONF' ]"
MAX="$(grep -oE '^MAX_TASK_TESTS=[0-9]+' "$CONF" 2>/dev/null | head -1 | cut -d= -f2)"
assert "config sets MAX_TASK_TESTS=20 (got ${MAX:-none})" "[ '${MAX:-0}' -eq 20 ]"

# ─── Hook wiring ───
assert "hook reads the cadence config" "grep -q 'test-cadence.conf' '$HOOK'"
assert "hook counts tests/task/*.sh" "grep -q 'tests/task' '$HOOK'"
assert "hook emits the checkpoint warning" "grep -q 'TASK-TEST CADENCE' '$HOOK'"
assert "hook no longer counts tests/test-*.sh" "! grep -q 'TEST COUNT WARNING' '$HOOK'"

# ─── Runner wiring ───
assert "runner discovers tests/task/*.sh" "grep -q 'tests/task/test-\*.sh' '$RUNNER'"

# ─── Working set exists ───
TASK_COUNT="$(find "$REPO_ROOT/tests/task" -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')"
assert "tests/task working set present ($TASK_COUNT files)" "[ '$TASK_COUNT' -ge 1 ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
