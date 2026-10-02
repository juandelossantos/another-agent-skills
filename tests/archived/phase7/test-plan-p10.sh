#!/usr/bin/env bash
# test-plan-p10.sh — PLAN.md records Phase 10 (landing/docs refresh, v6.2.0).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "## Phase 10: Landing & Docs Refresh" "$PLAN" && echo "  ✓ Phase 10 heading" || { echo "  ✗ missing Phase 10"; fail=1; }
grep -q "award-winning" "$PLAN" && echo "  ✓ award-winning inspiration research" || { echo "  ✗ missing inspiration research"; fail=1; }
grep -q "RELEASE-NOTES.md\` v6.1.0" "$PLAN" && echo "  ✓ release v6.1.0 plan" || { echo "  ✗ missing release plan"; fail=1; }

exit "$fail"
