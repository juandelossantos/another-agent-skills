#!/usr/bin/env bash
# test-plan-ordering.sh — the execution order (9 -> 10 -> 11) and the
# discoverability scope (SEO/AEO/a11y) are recorded in PLAN.md.

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

# --- Explicit execution order ---
assert "has an 'Orden de ejecución' section" "grep -q '## Orden de ejecución' '$PLAN'"
assert "orders Phase 9 before Phase 10 before Phase 11" "grep -q 'Phase 9 (distribución) → Phase 10 (landing/docs + descubribilidad) → Phase 11 (docs site)' '$PLAN'"
assert "justifies it (install story / git clone)" "grep -q 'git clone … && bash install.sh' '$PLAN'"
assert "names the rework/drift risk" "grep -qi 'Evita rework y drift' '$PLAN'"
assert "reconciles the phase versions (10 shipped in v6.3.0; 11 re-planned)" "grep -q 'Phase 9 → \`v6.3.0\`' '$PLAN' && grep -q 'Phase 10 → \`v6.3.0\` (shipped with Phase 9)' '$PLAN' && grep -q 'Phase 11 → re-planned, no version assigned' '$PLAN'"

# --- Phase 10 discoverability scope ---
assert "Phase 10 is v6.3.0" "grep -q '## Phase 10: Landing & Docs Refresh + Descubribilidad (v6.3.0)' '$PLAN'"
assert "Phase 10 has the discoverability block" "grep -q 'Bloque D — Descubribilidad: SEO + AEO + accesibilidad + award-winning' '$PLAN'"
assert "covers SEO technical (sitemap/robots/hreflang)" "grep -q 'sitemap.xml\` + \`robots.txt' '$PLAN'"
assert "covers AEO + llms.txt" "grep -q 'AEO' '$PLAN' && grep -q 'llms.txt' '$PLAN'"
assert "covers structured data" "grep -q 'Datos estructurados' '$PLAN'"
assert "covers WCAG 2.2 AA" "grep -q 'WCAG 2.2 AA' '$PLAN'"
assert "covers keywords + sector language" "grep -q 'Keywords + lenguaje del sector' '$PLAN'"
assert "covers indexing/measurement" "grep -q 'Indexación + medición' '$PLAN'"

# --- Phase 11 ---
assert "Phase 11 is re-planned / superseded" "grep -q '## Phase 11: Docs site — Astro + Starlight (re-planned; superseded by Phase 10' '$PLAN'"
assert "Phase 11 includes SEO/AEO per language" "grep -q 'SEO/AEO por idioma' '$PLAN'"
assert "Phase 11 includes WCAG 2.2 AA in Starlight" "grep -q 'WCAG 2.2 AA en el tema Starlight' '$PLAN'"

# --- Phase 9 closure ---
assert "Phase 9 is marked COMPLETE" "grep -q '## Phase 9: Distribution & Upgrades (v6.3.0) — ✅ COMPLETE' '$PLAN'"
assert "Phase 9 is in the Completed Phases table" "grep -qF '| **9** | **v6.3.0** |' '$PLAN'"
assert "Phase 9 task table is ✅ DONE" "grep -qF 'P9.1 ✅ DONE' '$PLAN' && grep -qF 'P9.8** ✅ DONE' '$PLAN'"
assert "Current Status tests count is 141" "grep -q '141 suites' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
