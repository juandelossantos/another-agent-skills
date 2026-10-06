#!/usr/bin/env bash
# test-plan-lote-b12-b17.sh — PLAN.md records the B12–B17 batch (rollout
# findings), prioritized, with B13's evidence corrected, B17 promoted to
# Phase 13 (type-aware verification), and B12 as NEXT.
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

# Backlog index lists B12–B17
assert "backlog index lists B12–B17" "for n in 12 13 14 15 16 17; do grep -q \"^| B\$n |\" '$PLAN' || exit 1; done"

# Prioritization table
assert "prioritization lists B12 (P0 false PASS)" "grep -q '(B12.1–B12.5)' '$PLAN'"
assert "prioritization lists B13" "grep -q '(B13.1–B13.2)' '$PLAN'"
assert "prioritization lists B14" "grep -q '(B14.1–B14.4)' '$PLAN'"
assert "prioritization lists B15" "grep -q '(B15.1–B15.3)' '$PLAN'"
assert "prioritization lists B16" "grep -q '(B16.1–B16.3)' '$PLAN'"
assert "prioritization lists Phase 13 (ex-B17, P0)" "grep -q '\*\*Phase 13\*\* — TDD gate verifica por nombre, no por tipo (ex-B17)' '$PLAN'"

# B13 — corrected evidence
assert "B13 names the real single-quoted skill (.agents/skills/vercel-optimize)" "grep -q 'vercel-optimize' '$PLAN'"
assert "B13 corrects the root cause (not the rollout blocker)" "grep -q 'causa del bloqueo del rollout' '$PLAN'"

# Phase 13 — the redesign
assert "has the Phase 13 section" "grep -q '## Phase 13: Type-aware verification gate' '$PLAN'"
assert "Phase 13 has the artifact→verification taxonomy" "grep -q 'artifact → verification' '$PLAN'"
assert "Phase 13 has tasks P13.1–P13.9" "grep -q '| P13.9 |' '$PLAN'"
assert "Phase 13 includes the EN/ES docs task" "grep -q 'Docs EN/ES' '$PLAN'"
assert "B17 is folded into Phase 13" "grep -q 'B17 → doblado en \*\*Phase 13\*\*' '$PLAN'"

# Ordering: B12 is NEXT
assert "B12 is NEXT" "grep -q 'B12 es NEXT' '$PLAN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
