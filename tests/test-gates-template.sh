#!/usr/bin/env bash
# test-gates-template.sh — the shipped remote-gate workflow (templates/gates.yml).
#
# This is the L2 authority template that init-agents installs into a user
# project as .github/workflows/gates.yml. Its job must be named `gates` (that is
# the required status check), it must be read-only, and it must explain how to
# turn the remote layer on.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/templates/gates.yml"

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

assert "template exists" "[ -f '$FILE' ]"
assert "is the only gate workflow template (ci.yml removed)" "[ ! -f '$REPO_ROOT/templates/ci.yml' ]"
assert "workflow is named gates" "grep -q '^name: gates' '$FILE'"
assert "job is named gates (the required check)" "grep -q '^  gates:' '$FILE'"
assert "runs on pull_request" "grep -q 'pull_request:' '$FILE'"
assert "runs on push to main" "grep -q 'push:' '$FILE'"
assert "is read-only (contents: read)" "grep -q 'permissions:' '$FILE' && grep -q 'contents: read' '$FILE'"
assert "reads STACK_CONFIG.md" "grep -q 'STACK_CONFIG.md' '$FILE'"
assert "explains how to enable branch protection" "grep -q 'setup-branch-protection.sh' '$FILE'"
assert "runs the AAS audit when present" "grep -q 'audit-project.sh' '$FILE'"
assert "explains L2 is the authority" "grep -qi 'authority' '$FILE'"

# Parse as YAML when a parser is available (best-effort; not a hard dependency).
if python3 -c 'import yaml' 2>/dev/null; then
  assert "is valid YAML" "python3 -c 'import yaml,sys; yaml.safe_load(open(sys.argv[1]))' '$FILE'"
else
  echo "  (skipped) python3 yaml module not available — structural greps only"
fi

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
