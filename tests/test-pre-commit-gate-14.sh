#!/usr/bin/env bash
# test-pre-commit-gate-14.sh — B12: the Gate 14 (test runner) must resolve the
# test command via the single source (scripts/stack-config-cmd.sh), NOT the old
# `grep -A1 '^| Test' | tail -1` parser that took the line after the last Test
# row (lint) and reported "All tests passed" → a false PASS.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRE="$REPO_ROOT/scripts/git-hooks/pre-commit"

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

assert "Gate 14 uses the single-source parser" "grep -qF 'stack-config-cmd.sh' '$PRE'"
assert "the old false-PASS parser is gone" "! grep -qF \"grep -A1 '^| Test'\" '$PRE'"
assert "Gate 14 keeps the tests/run-all.sh fallback" "grep -qF 'run-all.sh' '$PRE' && grep -qF 'TEST_RUNNER' '$PRE'"
assert "Gate 14 still runs the command as data (bash -c)" "grep -qF 'bash -c \"\$TEST_CMD\"' '$PRE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
