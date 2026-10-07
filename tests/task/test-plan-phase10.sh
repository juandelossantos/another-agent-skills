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

# --- Phase 10 closure + the next tasks (T1/T2) ---
assert "Phase 10 heading is marked COMPLETE" "grep -q '## Phase 10: Landing & Docs Refresh + Descubribilidad (v6.3.0) — ✅ COMPLETE' '$PLAN'"
assert "Phase 10 status names the merge (PR #55 → main)" "grep -q 'PR #55' '$PLAN' && grep -q '1258306' '$PLAN'"
assert "has a Next tasks section" "grep -q '^## Next tasks' '$PLAN'"
assert "T1 is npm activation (done)" "grep -q 'T1 — npm activation (DONE)' '$PLAN'"
assert "T1 records npm activation (done)" "grep -q 'T1 — npm activation (DONE)' '$PLAN'"
assert "T1 records Homebrew as not planned" "grep -qi 'Homebrew — NOT PLANNED' '$PLAN'"
assert "T1 references the distribution doc" "grep -q 'docs/DISTRIBUTION.md' '$PLAN'"
assert "T2 is the web + docs update (now LIVE)" "grep -q 'T2 — Web + docs update (the web is now LIVE)' '$PLAN'"
assert "T2 covers the security-headers gap" "grep -q 'security-headers gap' '$PLAN' && grep -q '_headers' '$PLAN'"
assert "records the web suite (83 node + 85 e2e)" "grep -q '83 node + 85 e2e' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
