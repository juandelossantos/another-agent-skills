#!/usr/bin/env bash
# test-plan-phase8.sh — Content check for PLAN.md after v6.2.0: Phase 7 is
# marked released and Phase 8 P8.1–P8.3 are marked done + ACTIVE, with the
# Current Status table at 6.2.0.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/PLAN.md"

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

assert "Current Status version is 6.2.0" "grep -qF '| Version | **6.2.0**' '$FILE'"
assert "Phase 7 dual-contract section present" "grep -q 'Phase 7: OpenCode v1/v2 Plugin Compatibility (v6.2.0)' '$FILE'"
assert "Phase 7 marked RELEASED as v6.2.0" "grep -q 'RELEASED as v6.2.0' '$FILE'"
assert "Phase 8 section marked IN PROGRESS" "grep -q 'Phase 8: Remote Enforcement — Gate Integrity (v6.2.0) — 🔄 IN PROGRESS' '$FILE'"
assert "Phase 8 P8.1 marked DONE" "grep -q 'P8.1 ✅ DONE' '$FILE'"
assert "Phase 8 P8.3 marked DONE" "grep -q 'P8.3 ✅ DONE' '$FILE'"
assert "Phase 8 P8.4 marked CLOSED (philosophy A)" "grep -q 'P8.4 ✅ CLOSED' '$FILE'"
assert "Phase 8 P8.5/P8.7 still PENDING" "grep -q 'P8.5 ⬜ PENDING' '$FILE' && grep -q 'P8.7 ⬜ PENDING' '$FILE'"
assert "Phase 8 status says P8.1–P8.3 DONE and ACTIVE" "grep -q 'P8.1–P8.3 DONE and ACTIVE' '$FILE'"
assert "Phase 7 listed in Completed Phases" "grep -qF '| **7** | **v6.2.0** |' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
