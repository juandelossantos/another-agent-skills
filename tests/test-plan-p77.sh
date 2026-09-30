#!/usr/bin/env bash
# test-plan-p77.sh — PLAN.md records P7.7 (guardrails, philosophy A).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "P7.7" "$PLAN" && echo "  ✓ PLAN.md references P7.7" || { echo "  ✗ PLAN.md missing P7.7"; fail=1; }
grep -qi "filosofía A\|deny incondicional" "$PLAN" && echo "  ✓ PLAN.md records philosophy A" || { echo "  ✗ PLAN.md missing philosophy A"; fail=1; }
grep -q "guardrails-only" "$PLAN" && echo "  ✓ PLAN.md documents --guardrails-only" || { echo "  ✗ PLAN.md missing --guardrails-only"; fail=1; }

exit "$fail"
