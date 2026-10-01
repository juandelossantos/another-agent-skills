#!/usr/bin/env bash
# test-pre-commit-merged.sh — the merged pre-commit hook keeps Gate 0 and a
# realistic test-count ceiling after the v6.1.0/v6.2.0 reconciliation.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"
fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

grep -q "Gate 0" "$HOOK"; check $? "Gate 0 (decision approval) present"
grep -qE "MAX_TESTS=[0-9]+" "$HOOK"; check $? "MAX_TESTS is set"
COUNT="$(find "$REPO_ROOT/tests" -maxdepth 1 -name 'test-*.sh' | wc -l | tr -d ' ')"
MAX="$(grep -oE 'MAX_TESTS=[0-9]+' "$HOOK" | head -1 | cut -d= -f2)"
[ "${MAX:-0}" -ge "${COUNT}" ]; check $? "ceiling ($MAX) >= test count ($COUNT)"

exit "$fail"
