#!/usr/bin/env bash
# test-gates-workflow.sh — asserts .github/workflows/gates.yml runs the REAL
# gates (not just STACK_CONFIG.md commands) and exposes a check named "gates",
# which becomes the required status check enforced remotely (L2).
#
# Gate config: .github/workflows/gates.yml
# Spec: PLAN.md — Phase 8 / P8.2

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$REPO_ROOT/.github/workflows/gates.yml"

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

echo ""
echo "gates.yml — remote gate workflow"
echo "──────────────────────────────────"

assert "gates.yml exists" "[ -f '$FILE' ]"
assert "job id is 'gates'" "grep -qE '^  gates:\$' '$FILE'"
assert "job display name is 'gates' (required check name)" "grep -qE '^    name: gates\$' '$FILE'"
assert "runs on pull_request" "grep -q 'pull_request:' '$FILE'"
assert "runs on push" "grep -q 'push:' '$FILE'"
assert "runs on push to main" "grep -qE 'branches: \[main\]' '$FILE'"
assert "invokes scripts/tdd-gate.sh" "grep -q 'bash scripts/tdd-gate.sh' '$FILE'"
assert "invokes tests/run-all.sh" "grep -q 'bash tests/run-all.sh' '$FILE'"
assert "invokes scripts/skill-lint.sh skills/" "grep -q 'bash scripts/skill-lint.sh skills/' '$FILE'"
assert "invokes scripts/validate-skill-table.sh" "grep -q 'bash scripts/validate-skill-table.sh' '$FILE'"
assert "runs a bash -n syntax pass" "grep -q 'bash -n' '$FILE'"
assert "syntax pass covers scripts/*.sh" "grep -qF 'scripts/*.sh' '$FILE'"
assert "syntax pass covers scripts/git-hooks/*" "grep -qF 'scripts/git-hooks/*' '$FILE'"
assert "no network fetch commands (curl/wget)" "! grep -qE '(curl|wget) ' '$FILE'"
assert "no mutating git commands (no writes)" "! grep -qE 'git (push|commit|tag)' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
