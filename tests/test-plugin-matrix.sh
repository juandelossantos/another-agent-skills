#!/usr/bin/env bash
# test-plugin-matrix.sh — scripts/plugin-matrix.sh default (no-network) run.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

OUT="$(bash "$REPO_ROOT/scripts/plugin-matrix.sh" 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "default run exits 0"
printf '%s\n' "$OUT" | grep -q "compatibility matrix"; check $? "prints the matrix header"
printf '%s\n' "$OUT" | grep -q "system (v2)"; check $? "reports the system v2 section"
printf '%s\n' "$OUT" | grep -q "opencode"; check $? "reports an opencode line"

exit "$fail"
