#!/usr/bin/env bash
# test-intent-design-phase10.sh — Phase 10 discovery (INTENT.md) and the evolved
# design contract (DESIGN.md) record the agreed decisions.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INTENT="$REPO_ROOT/INTENT.md"
DESIGN="$REPO_ROOT/DESIGN.md"

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

# --- INTENT.md: the discovery gate ---
assert "INTENT.md exists (discovery gate)" "[ -f '$INTENT' ]"
assert "has Objective" "grep -q '## 1. Objective' '$INTENT'"
assert "has Audience" "grep -q '## 2. Audience' '$INTENT'"
assert "has Constraints" "grep -q '## 3. Constraints' '$INTENT'"
assert "has Success metrics" "grep -q '## 4. Success metrics' '$INTENT'"
assert "has Scope" "grep -q '## 5. Scope' '$INTENT'"
assert "records the direction decision" "grep -q 'editorial-premium' '$INTENT'"
assert "records the mockup scope (landing + docs page)" "grep -qi 'one representative docs page' '$INTENT'"
assert "records the hero decision (keep + extend)" "grep -q 'keep the terminal animation' '$INTENT'"
assert "records bilingual + a11y targets" "grep -q 'WCAG 2.2 AA' '$INTENT' && grep -qi 'bilingual' '$INTENT'"

# --- DESIGN.md: the Phase 10 evolution ---
assert "DESIGN.md has the Phase 10 section" "grep -q '## Phase 10 — Landing Refresh' '$DESIGN'"
assert "Phase 10 label is v6.3.0 (shipped, not v6.4.0)" "grep -q '## Phase 10 — Landing Refresh (v6.3.0)' '$DESIGN' && ! grep -q '## Phase 10 — Landing Refresh (v6.4.0)' '$DESIGN'"
assert "keeps the editorial direction" "grep -q 'evolve the editorial-premium' '$DESIGN'"
assert "specs the three animations" "grep -q '### The three animations' '$DESIGN' && grep -q 'Flow (lifecycle)' '$DESIGN' && grep -q 'Harness' '$DESIGN' && grep -q 'Loop' '$DESIGN'"
assert "keeps light + dark first-class" "grep -q 'Light & dark (first-class' '$DESIGN'"
assert "has hue-per-phase" "grep -q 'Hue-per-phase' '$DESIGN'"
assert "has the compatibility band (multi-agent)" "grep -q '### Compatibility band' '$DESIGN' && grep -q 'Claude Code' '$DESIGN'"
assert "treats discoverability as design (SEO/AEO/a11y)" "grep -q 'Discoverability is a design concern' '$DESIGN' && grep -q 'llms.txt' '$DESIGN'"
assert "hero shows the three install channels" "grep -q 'channel 1' '$DESIGN' && grep -q 'channel 2' '$DESIGN' && grep -q 'channel 3' '$DESIGN'"
assert "has Phase 10 anti-patterns" "grep -q '### Phase 10 anti-patterns' '$DESIGN'"
assert "still bans purple" "grep -q 'No purple' '$DESIGN' || grep -q 'No purple; see bans' '$DESIGN'"
assert "keeps the Design Files section" "grep -q '## Design Files' '$DESIGN'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
