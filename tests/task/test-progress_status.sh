#!/usr/bin/env bash
# test-progress_status.sh — Content check for PROGRESS_STATUS.md: the header
# reflects the Phase 8-complete state (remote enforcement live, Phase 10 next),
# and the "Known Limitations" row credits Claude Code with automatic parity.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/PROGRESS_STATUS.md"

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

assert "Known Limitations row no longer lumps Claude with Cursor" "! grep -q 'Claude/Cursor need adapter setup' '$FILE'"
assert "Known Limitations row credits Claude Code with automatic parity" "grep -q 'Claude Code now gets full automatic parity' '$FILE'"
assert "status line reflects v6.3.0 released" "grep -q 'v6.3.0 released' '$FILE'"
assert "header date is 2026-10-06" "grep -qF 'Last updated:** 2026-10-06' '$FILE'"
assert "status names Phase 13 complete (type-aware TDD gate)" "grep -q 'Phase 13 complete (type-aware TDD gate' '$FILE'"
assert "current version is 6.3.0" "grep -qF 'Current version:** 6.3.0' '$FILE'"
assert "status names Phase 8 complete" "grep -q 'Phase 8 complete' '$FILE'"
assert "status says Remote Enforcement live" "grep -qi 'Remote Enforcement live' '$FILE'"
assert "status names Phase 9 complete" "grep -q 'Phase 9 complete' '$FILE'"
assert "status names Phase 10 complete" "grep -q 'Phase 10 complete' '$FILE'"
assert "status states the real guide count (151)" "grep -q '151 guides' '$FILE'"
assert "In Progress names T1 (npm + Homebrew activation)" "grep -q 'T1 — npm + Homebrew activation (maintainer, manual)' '$FILE'"
assert "T1 records the npm suspension lift + TOTP" "grep -q '2026-10-06 00:55 UTC' '$FILE' && grep -q 'TOTP' '$FILE'"
assert "T1 records the Homebrew tap + token" "grep -q 'HOMEBREW_TAP_TOKEN' '$FILE'"
assert "In Progress names T2 (web + docs once LIVE)" "grep -q 'T2 — Web + docs update once LIVE' '$FILE'"
assert "T2 covers the security-headers gap" "grep -q 'security-headers gap' '$FILE'"
assert "Completed lists Phase 10" "grep -q 'Phase 10: Landing & Docs Refresh' '$FILE'"
assert "Phase 10 is pending merge/deploy" "grep -q 'PR/merge/deploy pending' '$FILE'"
assert "In Progress no longer names Phase 8" "! grep -q 'Phase 8: Remote Enforcement (Gate Integrity)' '$FILE'"
assert "Completed lists Phase 9" "grep -q 'Phase 9: Distribution & Upgrades' '$FILE'"
assert "Completed lists Phase 8" "grep -q 'Phase 8: Remote Enforcement — Gate Integrity' '$FILE'"
assert "Completed lists Phase 7 v6.2.0" "grep -q 'Phase 7: OpenCode v1/v2, Multi-Agent & Guardrails (v6.2.0)' '$FILE'"
assert "Version History has a 6.2.0 row" "grep -qF '| **6.2.0** | 2026-10-01 |' '$FILE'"
assert "records the real suite count (133)" "grep -q '133 test suites green' '$FILE'"
assert "records the web suite (74 node + 85 e2e)" "grep -q '74 node + 85 e2e' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
