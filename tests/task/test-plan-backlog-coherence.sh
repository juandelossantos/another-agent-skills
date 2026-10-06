#!/usr/bin/env bash
# test-plan-backlog-coherence.sh — PLAN.md is coherent after the
# courtside-scoreboard exercise: no duplicate "Phase 7", the backlog B4–B9 is
# prioritized, B6 records the real root cause (bash vs shell), B9 exists, and
# the backlog has an index.

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

# --- No duplicate Phase 7 ---
assert "exactly one '## Phase 7' heading" "[ \"\$(grep -c '^## Phase 7:' '$PLAN')\" -eq 1 ]"
assert "the released Phase 7 is the OpenCode v1/v2 one" "grep -q '^## Phase 7: OpenCode v1/v2 Plugin Compatibility (v6.2.0) — ✅ RELEASED' '$PLAN'"
assert "the planned harness phase is Phase 12" "grep -q '^## Phase 12: Cross-Platform Harness Parity (v7.0.0) — PLANNED' '$PLAN'"
assert "no '## Phase 7: Cross-Platform' heading survives" "! grep -q '^## Phase 7: Cross-Platform' '$PLAN'"
assert "Phase 12 tasks are renumbered" "grep -q '### Task 12.1' '$PLAN' && grep -q '### Task 12.10' '$PLAN' && ! grep -q '### Task 7.1' '$PLAN'"

# --- Prioritization covers B5–B9 ---
assert "prioritization lists B6 (guardrail)" "grep -q 'Guardrail del plugin inerte en OpenCode v2 (B6.1–B6.6)' '$PLAN'"
assert "prioritization lists B5 (hooks)" "grep -q 'Hooks locales inertes por \`core.hooksPath\` (B5.1–B5.4)' '$PLAN'"
assert "prioritization lists B9 (skills)" "grep -q 'Skills: descubrimiento y rutas del Protocolo (B9.1–B9.4)' '$PLAN'"
assert "prioritization lists B7 (rules)" "grep -q 'Rule 12 no se auto-inyecta en el contexto (B7.1–B7.3)' '$PLAN'"
assert "prioritization lists B8 (PR gate)" "grep -q 'PR review gate sin disparador (B8.1–B8.2)' '$PLAN'"
assert "has the updated sequence rule (mecánico → blando)" "grep -q 'de lo \*\*mecánico\*\* a lo \*\*blando\*\*' '$PLAN'"

# --- B6 root cause corrected (bash vs shell) ---
assert "B6.3 records the real root cause (shell, not bash)" "grep -q 'la herramienta de shell es \*\*\`shell\`\*\*, no \`bash\`' '$PLAN'"
assert "B6.3 quotes the migration doc" "grep -q '\`bash\` is now \`shell\`' '$PLAN'"
assert "B6.3 accepts both tool ids" "grep -q 'aceptar \`shell\` (v2) y \`bash\` (v1)' '$PLAN'"
assert "B6.3 marks the old API hypothesis wrong" "grep -q 'la hipótesis previa de incompatibilidad de API era \*\*incorrecta\*\*' '$PLAN'"

# --- B9 exists ---
assert "B9 section exists" "grep -q '### Backlog detallado — B9' '$PLAN'"
assert "B9 has tasks B9.1–B9.4" "grep -q '| B9.1 |' '$PLAN' && grep -q '| B9.4 |' '$PLAN'"
assert "B9 explains it is discovery vs forced execution" "grep -q 'no\*\* es un fallo de descubrimiento' '$PLAN'"

# --- Backlog index ---
assert "backlog has an index table" "grep -q '| ID | Tema | Prioridad | Estado |' '$PLAN'"
assert "index lists B1 through B9" "for n in 1 2 3 4 5 6 7 8 9; do grep -q \"^| B\$n |\" '$PLAN' || exit 1; done"

# --- Cross-references / coherence notes ---
assert "B4 names the B5/B9 interaction" "grep -q 'B4, B5 y B9 deben resolverse juntos' '$PLAN'"
assert "B7 is marked as a soft fix" "grep -q 'Naturaleza:\*\* arreglo \*\*blando\*\* (contexto/texto). Complementa el enforcement mecánico (B5/B6)' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
