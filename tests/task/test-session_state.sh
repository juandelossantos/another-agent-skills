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

assert "handoff title is Phase 10 COMPLETE" "grep -q '# Session State — Phase 10 COMPLETE: Public Web + v6.3.0 Release' '$FILE'"
assert "documents Phase 10 COMPLETE" "grep -q 'Phase 10 COMPLETE' '$FILE'"
assert "retains the Phase 9 historical handoff" "grep -q 'Phase 9 (previous)' '$FILE'"
assert "names the merged Phase 9 PRs" "grep -q 'PRs #47' '$FILE'"
assert "documents the pending npm manual step" "grep -q '2026-10-06' '$FILE' && grep -qi 'TOTP' '$FILE'"
assert "documents the pending Homebrew step" "grep -q 'HOMEBREW_TAP_TOKEN' '$FILE'"
assert "Next Steps name Phase 11" "grep -q 'Phase 11 — docs site' '$FILE'"
assert "gives explicit resume commands" "grep -q 'Resume:' '$FILE' && grep -q 'git checkout -b feat/phase11-docs-site' '$FILE'"
assert "records verified system state" "grep -q 'System state (verified 2026-10-03)' '$FILE'"
assert "records 104 suites" "grep -q '104 suites passing' '$FILE'"
assert "records the v6.3.0 version" "grep -q 'now \*\*v6.3.0' '$FILE'"
assert "retains the historical previous handoff" "grep -q 'previous sessions. handoff' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
