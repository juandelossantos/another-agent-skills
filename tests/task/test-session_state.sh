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

assert "handoff title is Phase 8 COMPLETE" "grep -q '# Session State — Phase 8 COMPLETE: Remote Enforcement Live' '$FILE'"
assert "documents remote enforcement is LIVE" "grep -qi 'remote enforcement is LIVE' '$FILE'"
assert "documents P8.1–P8.3 done" "grep -q 'P8.1–P8.3' '$FILE'"
assert "names the working branch" "grep -q 'chore/phase8-close-status' '$FILE'"
assert "Next Steps name Phase 10" "grep -q 'Phase 10 — landing/docs refresh' '$FILE'"
assert "gives explicit resume commands" "grep -q 'Resume:' '$FILE' && grep -q 'git checkout -b feat/phase10-landing' '$FILE'"
assert "records verified system state" "grep -q 'System state (verified 2026-10-02)' '$FILE'"
assert "records 66 suites" "grep -q '66 suites passing' '$FILE'"
assert "retains the historical previous handoff" "grep -q 'previous sessions. handoff' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
