#!/usr/bin/env bash
# test-approval-gate.sh — approval-gate parses and stays portable on macOS/BSD.
#
# v6.4.3 replaced GNU-only tooling here: macOS has no `grep -P` and BSD sed
# requires a backup suffix on `-i`. Both failed silently inside `$( ... || true )`,
# so the script read empty values instead of erroring. This suite is the
# regression guard; scripts/check-portability.sh enforces the class repo-wide.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/approval-gate.sh"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1))
  fi
}

echo ""
echo "approval-gate — portable on macOS/BSD"
echo "─────────────────────────────────────"

assert "script exists" "[ -f '$SCRIPT' ]"
assert "script parses" "bash -n '$SCRIPT' >/dev/null 2>&1"
assert "no grep -P (BSD grep has no PCRE)" "! grep -E 'grep -[a-zA-Z]*P' '$SCRIPT' | grep -vE '^[[:space:]]*#' | grep -q ."
assert "no bare sed -i (BSD needs a backup suffix)" "! grep -E 'sed[[:space:]]+-i[[:space:]]' '$SCRIPT' | grep -vE '^[[:space:]]*#' | grep -q ."

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
