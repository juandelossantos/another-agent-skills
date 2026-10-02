#!/usr/bin/env bash
# test-pre-commit-max-tests.sh — the test-count gate is a TASK-test cadence:
# it caps the working set in tests/task/*.sh (MAX_TASK_TESTS, single source of
# truth: scripts/test-cadence.conf) and does NOT count the persistent
# behavioral/regression tests in tests/test-*.sh.
#
# Cadence: hit the cap -> push + full review -> git mv tests/task/<batch>
# tests/archived/<phase>/ -> reset. See docs/TEST-CADENCE.md.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"
CONF="$REPO_ROOT/scripts/test-cadence.conf"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# Single source of truth holds the cap.
[ -f "$CONF" ]; check $? "cadence config exists (scripts/test-cadence.conf)"
MAX="$(grep -oE '^MAX_TASK_TESTS=[0-9]+' "$CONF" | head -1 | cut -d= -f2)"
[ -n "$MAX" ]; check $? "MAX_TASK_TESTS is set in the config"
[ "${MAX:-0}" -eq 20 ]; check $? "cap is 20 (got ${MAX:-none})"

# The hook reads the cap from that one place.
grep -q 'test-cadence.conf' "$HOOK"; check $? "hook reads scripts/test-cadence.conf"
grep -qE 'MAX_TASK_TESTS=[0-9]+' "$HOOK"; check $? "hook defines a MAX_TASK_TESTS fallback"

# The hook counts the TASK working set, not the behavioral suite.
grep -q 'tests/task' "$HOOK"; check $? "hook counts tests/task/*.sh"
grep -q 'TASK-TEST CADENCE' "$HOOK"; check $? "hook emits the cadence checkpoint warning"
grep -q 'tests/archived' "$HOOK"; check $? "hook documents the archive step"

# The old absolute ceiling over tests/test-*.sh must be gone.
if grep -qE 'MAX_TESTS=[0-9]+' "$HOOK"; then
  echo "  ✗ old MAX_TESTS ceiling still present in hook"; fail=1
else
  echo "  ✓ old absolute MAX_TESTS ceiling removed"
fi
if grep -q 'TEST COUNT WARNING' "$HOOK"; then
  echo "  ✗ old behavioral test-count warning still present"; fail=1
else
  echo "  ✓ behavioral tests (tests/test-*.sh) are no longer counted"
fi

exit "$fail"
