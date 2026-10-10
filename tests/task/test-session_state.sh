#!/usr/bin/env bash
# test-session_state.sh — Content check for development/SESSION_STATE.md: the
# top handoff reflects the Phase 8-complete reality (remote enforcement live,
# Phase 10 next, resume commands), not the stale Phase 8 kickoff snapshot.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/development/SESSION_STATE.md"

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

assert "handoff title is the blog handoff" "grep -q '# Session State — blog shipped (W2/W3) · next: the 4 channel adaptations + T2' '$FILE'"
assert "documents Phase 10 SHIPPED" "grep -q 'Phase 10 SHIPPED' '$FILE'"
assert "retains the Phase 9 historical handoff" "grep -q 'Phase 9 (previous)' '$FILE'"
assert "names the merged Phase 9 PRs" "grep -q 'PRs #47' '$FILE'"
assert "documents the pending npm manual step" "grep -q '2026-10-06' '$FILE' && grep -qi 'TOTP' '$FILE'"
assert "records Homebrew as not planned" "grep -qi 'Homebrew is not planned' '$FILE'"
assert "records T1 (npm activation done)" "grep -q 'T1 — npm activation (DONE)' '$FILE'"
assert "Next tasks name T2 (web + docs now LIVE)" "grep -q 'T2 — Web + docs update (the web is now LIVE)' '$FILE'"
assert "T2 covers the security-headers gap" "grep -q 'security-headers gap' '$FILE'"
assert "gives the T1 resume command (npm publish)" "grep -q 'npm publish --access public' '$FILE'"
assert "documents the gated tag step" "grep -q 'Gated steps' '$FILE' && grep -q 'git tag vX.Y.Z' '$FILE'"
assert "records verified system state" "grep -q 'System state (verified 2026-10-03)' '$FILE'"
assert "records 108 suites" "grep -q '108 suites passing' '$FILE'"
assert "records the web suite" "grep -q '83 node + 85 e2e' '$FILE'"
assert "records Phase 14 SHIPPED (distribution closeout)" "grep -q 'Phase 14 SHIPPED' '$FILE'"
assert "records the open backlog (B13..B20)" "grep -q 'B13' '$FILE' && grep -q 'B20' '$FILE'"
assert "records the T2 next step (security-headers)" "grep -q 'T2' '$FILE' && grep -q 'security-headers gap' '$FILE'"
assert "retains the historical previous handoff" "grep -q 'previous sessions. handoff' '$FILE'"

# --- 2026-10-06 handoff: B4–B11 shipped + the B12–B17 next task ---
assert "records the PRs (#56–#58)" "grep -q 'PRs #56–#58' '$FILE'"
assert "records the B12–B17 lote" "grep -q 'B12–B17' '$FILE'"
assert "records B12 as the first next task" "grep -q 'Fix B12' '$FILE'"
assert "records B17 → Phase 13" "grep -q 'B17.*Phase 13' '$FILE'"
assert "records the courtside rollout branch" "grep -q 'chore/aas-portable-refs' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
