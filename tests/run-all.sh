#!/usr/bin/env bash
# tests/run-all.sh — Unified test runner for another-agent-skills
#
# Runs project-level test suites. With --changed flag, scopes to tests
# matching staged files (used by pre-commit Gate 14).
#
# Invocation: bash tests/run-all.sh [--changed]

set -uo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT" || { echo "FATAL: cannot cd to repo root"; exit 1; }

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0

INFRA_TESTS="test-tdd-gate.sh test-tdd-no-override.sh test-commit-msg.sh test-pre-flight.sh test-pre-commit-gates.sh test-pre-commit-gate-14.sh test-flat-files.sh test-sync-hooks.sh test-guide-refs.sh"

# Determine scope mode
SCOPE_CHANGED=false
if [[ "${1:-}" == "--changed" ]]; then
  SCOPE_CHANGED=true
fi

run_suite() {
  local name="$1" cmd="$2"
  # In --changed mode, check if test matches any staged file
  if $SCOPE_CHANGED; then
    # Extract test filename from command
    local test_file
    test_file=$(echo "$cmd" | grep -oP "tests/test-\w+\.sh" | head -1 || true)
    if [ -z "$test_file" ]; then
      # Always run non-file-specific suites (audit, init)
      true
    else
      # Check if test name-matches any changed file
      local test_stem
      test_stem=$(basename "$test_file" .sh | sed 's/^test-//')
      local matched=false
      while IFS= read -r changed_file; do
        local code_stem
        code_stem=$(basename "$changed_file" | sed 's/\.[^.]*$//')
        # Case-insensitive containment check
        if echo "$code_stem" | grep -qi "$test_stem" || echo "$test_stem" | grep -qi "$code_stem"; then
          matched=true
          break
        fi
      done < <(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
      # Always run infrastructure tests
      local base
      base=$(basename "$test_file")
      for infra in $INFRA_TESTS; do
        if [ "$base" = "$infra" ]; then
          matched=true
          break
        fi
      done
      if ! $matched; then
        echo ""
        echo -e "  ${YELLOW}−${NC} $name — skipped (no matching changes)"
        return 0
      fi
    fi
  fi
  echo ""
  echo -e "${BOLD}[$name]${NC}"
  if bash -c "$cmd" 2>&1; then
    echo -e "  ${GREEN}✓${NC} $name: PASS"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗${NC} $name: FAIL"
    FAIL=$((FAIL + 1))
  fi
}

echo "╔════════════════════════════════════════╗"
echo "║  PROJECT TEST RUNNER                   ║"
echo "║  another-agent-skills                  ║"
echo "╚════════════════════════════════════════╝"

run_suite "Audit wrapper-contract" "bash tests/audit/run.sh"
run_suite "Audit universal engine" "bash tests/audit/universal.sh"
run_suite "Init-agents features"  "bash tests/init/run.sh"
# Auto-discover tests/test-*.sh — no manual registration needed
for test_file in "$REPO_ROOT"/tests/test-*.sh; do
  [ -f "$test_file" ] || continue
  name=$(basename "$test_file" .sh | sed 's/^test-//')
  run_suite "$name" "bash '$test_file'"
done
run_suite "Skill lint"           "bash scripts/skill-lint.sh skills/"

if [ -f scripts/eval/test-e2e.sh ]; then
  run_suite "Eval e2e" "bash scripts/eval/test-e2e.sh"
fi

TOTAL=$((PASS + FAIL))
echo ""
echo "══════════════════════════════════════════"
echo -e "  ${BOLD}$TOTAL suites: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo "══════════════════════════════════════════"

exit $FAIL
