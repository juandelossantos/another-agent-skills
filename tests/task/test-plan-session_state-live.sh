#!/usr/bin/env bash
# test-plan-session-state-live.sh — PLAN.md + SESSION_STATE.md reflect the
# SHIPPED + LIVE state of Phase 10 (and the new E1/T3 tasks).
#
# Name matches PLAN.md and development/SESSION_STATE.md (both changed by the
# Phase 10 closure handoff) so the TDD gate pairs it.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"
STATE="$REPO_ROOT/development/SESSION_STATE.md"

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

echo "PLAN.md"
assert "exists" "[ -f '$PLAN' ]"
assert "records the web as SHIPPED + LIVE" "grep -q 'SHIPPED + LIVE' '$PLAN'"
assert "points at the live URL" "grep -q 'juandelossantos.github.io/another-agent-skills' '$PLAN'"
assert "reports 108 core suites" "grep -q '108 suites' '$PLAN'"
assert "lists the E1 essay task" "grep -q '### E1 — Essay' '$PLAN'"
assert "lists the T3 tag task" "grep -q '### T3 — Tag' '$PLAN'"
assert "T2 says the web is LIVE" "grep -q 'the web is now LIVE' '$PLAN'"

echo ""
echo "development/SESSION_STATE.md"
assert "exists" "[ -f '$STATE' ]"
assert "header says Phase 10 SHIPPED" "grep -q 'Phase 10 SHIPPED' '$STATE'"
assert "branch is main @ 1258306" "grep -q 'tip \`1258306\`' '$STATE'"
assert "records the live URL" "grep -q 'juandelossantos.github.io/another-agent-skills' '$STATE'"
assert "names the deploy workflow" "grep -q 'deploy-web' '$STATE'"
assert "reports 108 core suites" "grep -q '108 suites' '$STATE'"
assert "lists E1 (essay)" "grep -q 'E1 — Essay' '$STATE'"
assert "lists T3 (tag v6.3.0)" "grep -q 'T3 — Tag' '$STATE'"
assert "lists T2 (web + docs live)" "grep -q 'T2 — Web + docs update (the web is now LIVE)' '$STATE'"
assert "names the essay files" "grep -q 'essay-human-in-command.en.md' '$STATE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
