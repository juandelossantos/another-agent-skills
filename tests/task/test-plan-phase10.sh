#!/usr/bin/env bash
# test-plan-phase10.sh — Phase 10 records the #workflows styling debt (from Phase 8.1).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

assert "Phase 10 section exists" "grep -q '## Phase 10' '$PLAN'"
assert "records the #workflows styling debt" "grep -qi 'Estilo propio de la sección' '$PLAN'"
assert "names the .philosophy reuse" "grep -q 'reutiliza el estilo \`.philosophy\`' '$PLAN'"
assert "plans a dedicated workflows style" "grep -qi 'no existe \`.workflows\`' '$PLAN'"
assert "references Phase 8.1 as the origin" "grep -qi 'deuda de Phase 8.1' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
