#!/usr/bin/env bash
# test-plan-p77.sh — PLAN.md records P7.7 (guardrails, philosophy A).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "P7.7" "$PLAN" && echo "  ✓ PLAN.md references P7.7" || { echo "  ✗ PLAN.md missing P7.7"; fail=1; }
grep -qi "filosofía A\|deny incondicional" "$PLAN" && echo "  ✓ PLAN.md records philosophy A" || { echo "  ✗ PLAN.md missing philosophy A"; fail=1; }
grep -q "guardrails-only" "$PLAN" && echo "  ✓ PLAN.md documents --guardrails-only" || { echo "  ✗ PLAN.md missing --guardrails-only"; fail=1; }
# Stale token claim: the reconciled dual-contract note must not still say the
# hook allows a commit with a fresh token.
! grep -q "permite con token fresco" "$PLAN" && echo "  ✓ no stale 'token fresco' claim in PLAN.md" || { echo "  ✗ stale token claim remains"; fail=1; }

# Review lesson: the command classifier must be a single shared source of truth
# across adapters (anchored/duplicated checks drift and become bypassable).
grep -qi "clasificador de comandos" "$PLAN" && echo "  ✓ PLAN.md records the shared-classifier lesson" || { echo "  ✗ PLAN.md missing shared-classifier lesson"; fail=1; }
grep -qi "única fuente de verdad" "$PLAN" && echo "  ✓ PLAN.md records the single-source-of-truth rule" || { echo "  ✗ PLAN.md missing single-source rule"; fail=1; }

exit "$fail"
