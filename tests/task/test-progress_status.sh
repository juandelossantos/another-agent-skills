#!/usr/bin/env bash
# test-progress_status.sh — Content check for PROGRESS_STATUS.md: the header
# reflects the post-v6.2.0 state (Phase 7 released, Phase 8 P8.1–P8.3 active),
# and the "Known Limitations" row no longer claims Claude Code needs manual
# adapter setup for skills+hooks.

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
assert "status line reflects v6.2.0 released" "grep -q 'v6.2.0 released' '$FILE'"
assert "header date is 2026-10-02" "grep -qF 'Last updated:** 2026-10-02' '$FILE'"
assert "current version is 6.2.0" "grep -qF 'Current version:** 6.2.0' '$FILE'"
assert "status names Phase 8 P8.1–P8.3 done" "grep -q 'Phase 8 P8.1–P8.3 done' '$FILE'"
assert "status says branch protection ACTIVE" "grep -q 'branch protection ACTIVE' '$FILE'"
assert "In Progress names Phase 8 Remote Enforcement" "grep -q 'Phase 8: Remote Enforcement (Gate Integrity)' '$FILE'"
assert "Completed lists Phase 7 v6.2.0" "grep -q 'Phase 7: OpenCode v1/v2, Multi-Agent & Guardrails (v6.2.0)' '$FILE'"
assert "Version History has a 6.2.0 row" "grep -qF '| **6.2.0** | 2026-10-01 |' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
