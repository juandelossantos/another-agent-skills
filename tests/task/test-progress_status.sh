#!/usr/bin/env bash
# test-progress_status.sh — Content check for PROGRESS_STATUS.md: the
# "Known Limitations" row no longer claims Claude Code needs manual adapter
# setup for skills+hooks (it doesn't, since today's install.sh change).

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

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
