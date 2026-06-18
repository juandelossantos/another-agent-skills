#!/usr/bin/env bash
# log-test-results.sh — Records test results before commit approval
# Agent MUST run this after tests pass, before presenting DECISION POINT.
# The commit-msg hook v6 checks for this file before allowing commit.
#
# Usage: bash scripts/log-test-results.sh <pass_count> <fail_count> [test_command]
# Example: bash scripts/log-test-results.sh 15 0 "npm test"

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo '.')
TEST_LOG="${REPO_ROOT}/.git/TEST_LOG"

PASS="${1:-0}"
FAIL="${2:-0}"
CMD="${3:-unknown}"

if [ "$FAIL" -gt 0 ]; then
  echo "ERROR: $FAIL test(s) failed. Fix before committing."
  exit 1
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
{
  echo "timestamp=${TIMESTAMP}"
  echo "command=${CMD}"
  echo "passed=${PASS}"
  echo "failed=${FAIL}"
  echo "status=PASS"
} > "$TEST_LOG"

echo "✓ Test results logged (${PASS} passed, ${FAIL} failed)"
