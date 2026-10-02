#!/usr/bin/env bash
# test-plan-p72.sh — PLAN.md records the P7.2 global install work.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "P7.2" "$PLAN" && echo "  ✓ PLAN.md references P7.2" || { echo "  ✗ PLAN.md missing P7.2"; fail=1; }
grep -q -- "--plugin-only" "$PLAN" && echo "  ✓ PLAN.md documents --plugin-only" || { echo "  ✗ PLAN.md missing --plugin-only"; fail=1; }

exit "$fail"
