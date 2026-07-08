#!/usr/bin/env bash
# tests/run-all.sh — Unified test runner for another-agent-skills
#
# Runs all project-level test suites and reports results.
# Used by CI and pre-commit (Gate 14).
#
# Invocation: bash tests/run-all.sh
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

run_suite() {
  local name="$1" cmd="$2"
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
run_suite "TDD gate"              "bash tests/test-tdd-gate.sh"
run_suite "Pre-commit gates"     "bash tests/test-pre-commit-gates.sh"
run_suite "Gate 14 behavioral"  "bash tests/test-pre-commit-gate-14.sh"
run_suite "Sync hooks"           "bash tests/test-sync-hooks.sh"
run_suite "Commit-msg hook"     "bash tests/test-commit-msg.sh"
run_suite "Commit-approval"     "bash tests/test-commit-approval.sh"
run_suite "Frontmatter"         "bash tests/test-frontmatter.sh"
run_suite "Pre-flight"          "bash tests/test-pre-flight.sh"
run_suite "Flat files"          "bash tests/test-flat-files.sh"
run_suite "Guide refs"          "bash tests/test-guide-refs.sh"
run_suite "Skill content"       "bash tests/test-performance-skill.sh"
run_suite "Observability"       "bash tests/test-observability-skill.sh"
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
