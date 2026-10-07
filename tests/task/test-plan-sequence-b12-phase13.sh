#!/usr/bin/env bash
# test-plan-sequence-b12-phase13.sh — PLAN.md records the updated sequence rule
# for the B12–B17 lote + Phase 13 (the post-PR-#59 follow-up).
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1))
  fi
}

assert "has the 2026-10-06 sequence rule" "grep -q 'Regla de secuencia (actualizada 2026-10-06, lote B12–B17 + Phase 13)' '$PLAN'"
assert "frames it as concrete → structural" "grep -q 'de lo \*\*concreto\*\* a lo \*\*estructural\*\*' '$PLAN'"
assert "puts B12 before Phase 13" "grep -q '\*\*B12\*\*.*\*\*Phase 13\*\*' '$PLAN'"
assert "names the Phase 13 spec" "grep -q 'development/SPEC-TDD-GATE.md' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
