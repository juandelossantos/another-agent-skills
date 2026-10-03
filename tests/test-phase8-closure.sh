#!/usr/bin/env bash
# test-phase8-closure.sh — Phase 8 (Remote Enforcement) stays closed across the
# status/plan/progress docs even after Phase 9 (distribution) landed: no doc
# still calls it "in progress", every P8.x task is marked done, and the remote
# layer is described as live on `main`. The SESSION_STATE handoff has moved on
# to Phase 9, so this guards that the Phase 8 closure facts persist in history.
#
# This is the behavioral companion for the Phase 8 closure docs update; it lives
# in tests/ (behavioral/permanent), not the capped tests/task/ working set.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"
PROGRESS="$REPO_ROOT/PROGRESS_STATUS.md"
HEALTH="$REPO_ROOT/HEALTH-CHECK.md"
SESSION="$REPO_ROOT/development/SESSION_STATE.md"

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

# --- PLAN.md ---
assert "PLAN Phase 8 section is COMPLETE" "grep -q 'Phase 8: Remote Enforcement — Gate Integrity (v6.2.0) — ✅ COMPLETE' '$PLAN'"
assert "PLAN has no Phase 8 IN PROGRESS marker" "! grep -q '🔄 IN PROGRESS' '$PLAN'"
assert "PLAN marks every P8.1–P8.9 task DONE/CLOSED" "! grep -qE 'P8\.[0-9] ⬜ PENDING' '$PLAN'"
assert "PLAN lists Phase 8 in Completed Phases" "grep -qF '| **8** | **v6.2.0** |' '$PLAN'"
assert "PLAN Next target is Phase 11" "grep -q 'Next target | \*\*Phase 11\*\*' '$PLAN'"
assert "PLAN tests row says 102 suites" "grep -qF '102 suites passing' '$PLAN'"

# --- PROGRESS_STATUS.md ---
assert "PROGRESS header says Phase 8 complete" "grep -q 'Phase 8 complete' '$PROGRESS'"
assert "PROGRESS says remote enforcement live" "grep -qi 'Remote Enforcement live' '$PROGRESS'"
assert "PROGRESS In Progress moved on to Phase 11" "grep -q 'Phase 11: Docs site' '$PROGRESS'"
assert "PROGRESS Completed lists Phase 8" "grep -q 'Phase 8: Remote Enforcement — Gate Integrity' '$PROGRESS'"

# --- HEALTH-CHECK.md ---
assert "HEALTH recommends Phase 8 COMPLETE" "grep -q 'Phase 8 COMPLETE' '$HEALTH'"
assert "HEALTH no longer says Phase 8 in progress" "! grep -q 'Phase 8 in progress' '$HEALTH'"
assert "HEALTH records remote authority (L2) ACTIVE" "grep -q 'Remote authority (L2)' '$HEALTH'"

# --- SESSION_STATE.md ---
assert "SESSION_STATE retains the Phase 8 closure handoff" "grep -q 'Phase 8 closure' '$SESSION'"
assert "SESSION_STATE retains the Phase 9 historical handoff" "grep -q 'Phase 9 (previous)' '$SESSION'"
assert "SESSION_STATE resume points at Phase 11" "grep -q 'git checkout -b feat/phase11-docs-site' '$SESSION'"

# --- Cross-doc: no stale "in progress" claim survives ---
assert "no status doc still calls Phase 8 in progress" "! grep -qi 'Phase 8 in progress' '$PLAN' '$PROGRESS' '$HEALTH' '$SESSION'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
