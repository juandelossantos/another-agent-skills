#!/usr/bin/env bash
# test-plan-p73.sh — PLAN.md records P7.3 and backlog B3.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "P7.3 completado" "$PLAN" && echo "  ✓ P7.3 progress recorded" || { echo "  ✗ missing P7.3 progress"; fail=1; }
grep -q "B3: TDD gate false-pass" "$PLAN" && echo "  ✓ B3 backlog item present" || { echo "  ✗ missing B3"; fail=1; }
grep -q "Duplicate plugin ID" "$PLAN" && echo "  ✓ duplicate-id coherence recorded" || { echo "  ✗ missing coherence note"; fail=1; }

exit "$fail"
