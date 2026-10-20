#!/usr/bin/env bash
# test-l2-ship-to-users.sh — Phase 15: the L2 approval check ships to consumers.
#
# The framework's gates.yml and the template installed by init-agents must run
# the same check, and the check script must be installed in the project.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

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
echo "L2 approval check — framework + consumer template"
echo "─────────────────────────────────────────────────"

FW="$REPO_ROOT/.github/workflows/gates.yml"
TPL="$REPO_ROOT/templates/gates.yml"
INIT="$REPO_ROOT/scripts/init-agents.sh"
INSTALL="$REPO_ROOT/install.sh"

assert "framework gates.yml runs the L2 check" "grep -q 'scripts/check-approved-tree.sh' '$FW'"
assert "consumer template runs the L2 check" "grep -q 'scripts/check-approved-tree.sh' '$TPL'"
assert "consumer template passes the PR body via env" "grep -q 'PR_BODY:' '$TPL' && grep -q 'github.event.pull_request.body' '$TPL'"
assert "consumer template checks out the PR head" "grep -q 'github.event.pull_request.head.sha' '$TPL'"
assert "init-agents installs check-approved-tree.sh" "grep -q 'AAS_LEGACY_SCRIPTS=.*check-approved-tree.sh' '$INIT'"
assert "install.sh installs check-approved-tree.sh" "grep -q 'check-approved-tree.sh' '$INSTALL'"
assert "the check script exists and is executable" "[ -x '$REPO_ROOT/scripts/check-approved-tree.sh' ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
