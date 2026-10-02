#!/usr/bin/env bash
# test-plan-p75.sh — PLAN.md records the P7.5 detection work and Phase 9.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "P7.5" "$PLAN" && echo "  ✓ PLAN.md references P7.5" || { echo "  ✗ PLAN.md missing P7.5"; fail=1; }
grep -q "agent-detect.sh" "$PLAN" && echo "  ✓ PLAN.md references agent-detect.sh" || { echo "  ✗ PLAN.md missing agent-detect.sh"; fail=1; }
grep -q "## Phase 9: Distribution & Upgrades" "$PLAN" && echo "  ✓ Phase 9 present" || { echo "  ✗ Phase 9 missing"; fail=1; }
grep -q "P9.1" "$PLAN" && echo "  ✓ Phase 9 tasks present" || { echo "  ✗ Phase 9 tasks missing"; fail=1; }

exit "$fail"
