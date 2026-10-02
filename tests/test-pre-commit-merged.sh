#!/usr/bin/env bash
# test-pre-commit-merged.sh — the merged pre-commit hook keeps Gate 0 and the
# TASK-test cadence after the v6.1.0/v6.2.0 reconciliation: the ceiling applies
# to the tests/task/*.sh working set and is read from the single source of
# truth, scripts/test-cadence.conf.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"
CONF="$REPO_ROOT/scripts/test-cadence.conf"
fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

grep -q "Gate 0" "$HOOK"; check $? "Gate 0 (decision approval) present"
grep -qE "MAX_TASK_TESTS=[0-9]+" "$HOOK"; check $? "MAX_TASK_TESTS is set in the hook"
[ -f "$CONF" ]; check $? "cadence config present"
MAX="$(grep -oE '^MAX_TASK_TESTS=[0-9]+' "$CONF" | head -1 | cut -d= -f2)"
[ "${MAX:-0}" -eq 20 ]; check $? "single source of truth cap is 20 (got ${MAX:-none})"
grep -q 'tests/task' "$HOOK"; check $? "hook scopes the cap to tests/task/*.sh"

exit "$fail"
