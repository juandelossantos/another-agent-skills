#!/usr/bin/env bash
# test-session_state.sh — Content check for development/SESSION_STATE.md:
# reflects today's actual work (skills+hooks automation, web updates), not
# the stale Phase 7 kickoff snapshot from the prior session.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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

assert "documents the global skills install work" "grep -qi 'global skills' '$FILE'"
assert "documents the enforcement hooks automation work" "grep -qi 'enforcement hooks' '$FILE'"
assert "documents the website update work" "grep -qi 'website' '$FILE'"
assert "lists what's still open under Task 7.1" "grep -q 'Still Open' '$FILE'"
assert "notes the plugin-structure limitation isn't fixed yet" "grep -qi 'not a real auto-discoverable Claude Code plugin' '$FILE'"
assert "documents the post-commit code-review pass and what it caught" "grep -q 'full .code-review. pass' '$FILE'"
assert "documents the pre-flight.sh dirty-tree-blocks-every-commit bug" "grep -qi 'blocked 100% of commits' '$FILE'"
assert "documents the commit-approval.sh dead-token bug" "grep -q 'DECISION_APPROVED' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
