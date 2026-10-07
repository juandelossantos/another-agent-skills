#!/usr/bin/env bash
# test-health-check.sh — Content check for HEALTH-CHECK.md: reflects the
# Phase 8-complete state (remote enforcement live, Phase 10 next). Folds in the
# former test-health-check-sync.sh Recommendations checks, which were archived
# to tests/archived/phase8/ so the working set stays capped.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/HEALTH-CHECK.md"

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

assert "recommends Phase 7 released as v6.2.0" "grep -q 'Phase 7 released as v6.2.0' '$FILE'"
assert "documents Phase 8 COMPLETE" "grep -q 'Phase 8 COMPLETE' '$FILE'"
assert "no longer says Phase 8 in progress" "! grep -q 'Phase 8 in progress' '$FILE'"
assert "documents remote enforcement live" "grep -qi 'remote enforcement live' '$FILE'"
assert "records remote authority (L2) ACTIVE" "grep -q 'Remote authority (L2)' '$FILE' && grep -q 'branch protection on .main.' '$FILE'"
assert "version header is 6.3.0" "grep -q '\*\*Version:\*\* 6.3.0' '$FILE'"
assert "records the real guide count (151)" "grep -q '151 guides' '$FILE'"
assert "documents the v6.3.0 release" "grep -q 'v6.3.0 released' '$FILE'"
assert "documents the test cadence" "grep -q 'Test cadence' '$FILE'"
assert "documents Phase 10 COMPLETE" "grep -q 'Phase 10 COMPLETE' '$FILE'"
assert "records Phase 10 complete on the branch" "grep -q 'feat/phase10-landing' '$FILE'"
assert "names the next task T1 (npm + Homebrew)" "grep -q 'T1 — npm + Homebrew activation (maintainer, manual)' '$FILE'"
assert "names the next task T2 (web + docs once LIVE)" "grep -q 'T2 — web + docs update once LIVE' '$FILE'"
assert "T2 covers the security-headers gap" "grep -q 'security-headers gap' '$FILE'"
assert "documents Phase 9 COMPLETE" "grep -q 'Phase 9 COMPLETE' '$FILE'"
assert "records 133 suites" "grep -q '133 suites' '$FILE'"
assert "links the distribution docs" "grep -q 'docs/DISTRIBUTION.md' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
