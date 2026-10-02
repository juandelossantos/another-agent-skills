#!/usr/bin/env bash
# test-session_state.sh — Content check for development/SESSION_STATE.md: the
# top handoff reflects the post-v6.2.0 reality (Phase 7 released, Phase 8
# P8.1–P8.3 active, test cadence, resume commands), not the stale Phase 7
# kickoff snapshot.

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

assert "handoff title is Phase 8" "grep -q '# Session State — Phase 8: Remote Enforcement' '$FILE'"
assert "documents Phase 7 released as v6.2.0" "grep -q 'Phase 7 released as' '$FILE'"
assert "documents P8.1–P8.3 done and ACTIVE" "grep -q 'P8.1–P8.3 done and ACTIVE' '$FILE'"
assert "documents the test cadence" "grep -q 'Test cadence formalized' '$FILE'"
assert "names the working branch" "grep -q 'chore/session-status-update' '$FILE'"
assert "lists remaining Phase 8 tasks P8.5–P8.7" "grep -q 'P8.5' '$FILE' && grep -q 'P8.7' '$FILE'"
assert "gives explicit resume commands" "grep -q 'Resume:' '$FILE' && grep -q 'git checkout -b feat/phase8-remote-ship' '$FILE'"
assert "records verified system state" "grep -q 'System state (verified 2026-10-02)' '$FILE'"
assert "retains the historical previous handoff" "grep -q 'previous session.s handoff' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
