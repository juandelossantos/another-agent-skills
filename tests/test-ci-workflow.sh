#!/usr/bin/env bash
# test-ci-workflow.sh — Content check for .github/workflows/ci.yml: jq is
# guaranteed present before any test/lint/build command runs. Added after a
# real CI failure on PR #34 where install.sh's hook-wiring step (which needs
# jq) silently no-op'd in the "quality" job, and the test suite's own log
# capture swallowed the diagnostic output instead of surfacing it.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/.github/workflows/ci.yml"

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

assert "ci.yml exists" "[ -f '$FILE' ]"
assert "installs jq before running the test command" "grep -q 'Ensure jq is available' '$FILE'"
assert "the jq step runs before 'Run tests'" "[ \$(grep -n 'Ensure jq is available' '$FILE' | cut -d: -f1) -lt \$(grep -n 'name: Run tests' '$FILE' | cut -d: -f1) ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
