#!/usr/bin/env bash
# test-init-agents-ships-remote.sh — init-agents installs the remote layer (P8.6).
#
# A new project must get .github/workflows/gates.yml (the `gates` required
# check) and the setup-branch-protection.sh script, and be told how to turn the
# remote authority layer on.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT_SCRIPT="$REPO_ROOT/scripts/init-agents.sh"

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

# --- Behavioral: a git project with a GitHub remote gets the gate workflow ---
# (init-agents only installs the remote workflow when a GitHub remote exists.)
tmp=$(mktemp -d)
git -C "$tmp" init -q
git -C "$tmp" config user.email test@test.com
git -C "$tmp" config user.name Test
git -C "$tmp" remote add origin https://github.com/example/demo.git
(cd "$tmp" && bash "$INIT_SCRIPT" >/dev/null 2>&1)
assert "scaffold creates .github/workflows/gates.yml" "[ -f '$tmp/.github/workflows/gates.yml' ]"
assert "installed workflow is the gates workflow" "grep -q '^name: gates' '$tmp/.github/workflows/gates.yml' 2>/dev/null"
assert "installed workflow defines the gates job" "grep -q '^  gates:' '$tmp/.github/workflows/gates.yml' 2>/dev/null"
rm -rf "$tmp"

# --- Static: the wiring exists in init-agents.sh ---
assert "init-agents defines install_gates_workflow" "grep -q 'install_gates_workflow()' '$INIT_SCRIPT'"
assert "init-agents calls install_gates_workflow" "grep -q '^    install_gates_workflow$' '$INIT_SCRIPT'"
assert "installs from templates/gates.yml" "grep -q 'templates/gates.yml' '$INIT_SCRIPT'"
assert "links setup-branch-protection.sh" "grep -q 'setup-branch-protection.sh' '$INIT_SCRIPT'"
assert "no longer installs the generic ci.yml" "! grep -q 'install_ci_template' '$INIT_SCRIPT'"
assert "next steps mention the remote layer" "grep -q 'setup-branch-protection.sh' '$INIT_SCRIPT' && grep -qi 'REMOTE ENFORCEMENT' '$INIT_SCRIPT'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
