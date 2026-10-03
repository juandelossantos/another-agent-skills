#!/usr/bin/env bash
# test-health-check-plan-progress_status-session_state.sh — Phase 10 closure:
# the status docs record Phase 10 COMPLETE (v6.3.0) and the next tasks T1/T2.
#
# Name matches the changed code files HEALTH-CHECK.md, PLAN.md,
# PROGRESS_STATUS.md and development/SESSION_STATE.md.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"
PROG="$REPO_ROOT/PROGRESS_STATUS.md"
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

# --- PLAN: Phase 10 complete + the next tasks ---
assert "PLAN marks Phase 10 COMPLETE" "grep -q 'Phase 10.*✅ COMPLETE\|Phase 10:.*COMPLETE' '$PLAN'"
assert "PLAN has a Next tasks section" "grep -qi '## Next tasks' '$PLAN'"
assert "PLAN records T1 (npm + Homebrew)" "grep -q 'T1' '$PLAN' && grep -qi 'Homebrew' '$PLAN' && grep -qi 'npm' '$PLAN'"
assert "PLAN records the npm suspension window" "grep -q '2026-10-06' '$PLAN'"
assert "PLAN records T2 (web + docs once live)" "grep -q 'T2' '$PLAN' && grep -qi 'once.*live\|LIVE' '$PLAN'"
assert "PLAN mentions the security-headers gap" "grep -qi 'security.headers\|_headers\|CSP' '$PLAN'"

# --- PROGRESS: header + the next tasks ---
assert "PROGRESS header is 6.3.0" "grep -qE 'Current version:\*\* 6\.3\.0|Current version: 6\.3\.0' '$PROG'"
assert "PROGRESS In Progress points at T1/T2" "grep -q 'T1' '$PROG' && grep -q 'T2' '$PROG'"

# --- HEALTH: regenerated + the recommendations ---
assert "HEALTH header is 6.3.0" "grep -q '6.3.0' '$HEALTH'"
assert "HEALTH recommends T1/T2" "grep -q 'T1' '$HEALTH' && grep -q 'T2' '$HEALTH'"

# --- SESSION_STATE: the handoff ---
assert "SESSION_STATE is the Phase 10 handoff" "grep -qi 'Phase 10' '$SESSION'"
assert "SESSION_STATE records the next tasks" "grep -q 'T1' '$SESSION' && grep -q 'T2' '$SESSION'"
assert "SESSION_STATE notes the gated PR/merge/tag/deploy" "grep -qi 'tag\|deploy' '$SESSION'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
