#!/usr/bin/env bash
# test-pre-commit-max-tests.sh — the test-count ceiling in the pre-commit hook is
# realistic for the current suite (it was 11, from when there were far fewer
# tests; Phase 8 raised it to 64 after adding the remote-enforcement tests).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"
COUNT="$(find "$REPO_ROOT/tests" -maxdepth 1 -name 'test-*.sh' | wc -l | tr -d ' ')"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

MAX="$(grep -oE 'MAX_TESTS=[0-9]+' "$HOOK" | head -1 | cut -d= -f2)"
[ -n "$MAX" ]; check $? "MAX_TESTS is set in the hook"
[ "${MAX:-0}" -ge "${COUNT}" ]; check $? "ceiling ($MAX) >= current test count ($COUNT)"
[ "${MAX:-0}" -ge 30 ]; check $? "ceiling is realistic (>= 30)"

exit "$fail"
