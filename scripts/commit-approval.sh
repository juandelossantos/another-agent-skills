#!/usr/bin/env bash
# commit-approval.sh — Records user approval for commit (v3)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Flow:
# 1. Agent runs tests → bash scripts/log-test-results.sh
# 2. Agent presents DECISION POINT (diff + test results + manifest)
# 3. User says "yes commit" in chat
# 4. Agent runs this script
# 5. Script writes COMMIT_MANIFEST + COMMIT_APPROVED
# 6. Agent commits
# 7. commit-msg hook v6 verifies: TEST_LOG? MANIFEST? APPROVED? → allows
#
# Usage: bash scripts/commit-approval.sh "commit message" [file1 file2...]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMIT_MSG="${1:-}"
REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"
APPROVAL_FILE="${REPO_ROOT}/.git/COMMIT_APPROVED"
MANIFEST_FILE="${REPO_ROOT}/.git/COMMIT_MANIFEST"
TEST_LOG="${REPO_ROOT}/.git/TEST_LOG"
APPROVAL_LOG="${REPO_ROOT}/.git/APPROVAL_LOG"

if [[ -z "$COMMIT_MSG" ]]; then
  echo -e "${RED}Error: No commit message provided.${NC}"
  exit 1
fi

# Check: TEST_LOG exists and shows PASS
TEST_PASSED=0
if [[ -f "$TEST_LOG" ]]; then
  STATUS=$(grep "^status=" "$TEST_LOG" | cut -d= -f2-)
  PASSED=$(grep "^passed=" "$TEST_LOG" | cut -d= -f2-)
  if [[ "$STATUS" == "PASS" ]]; then
    TEST_PASSED=1
  fi
fi

if [[ $TEST_PASSED -eq 0 ]]; then
  echo -e "${YELLOW}⚠ No test results found. Run tests first:${NC}"
  echo "  bash scripts/log-test-results.sh <pass> <fail> <command>"
  echo ""
fi

# Write commit manifest
FILES="${*:2}"
{
  echo "## Commit Manifest"
  echo ""
  echo "**Message:** ${COMMIT_MSG}"
  echo ""
  echo "### Files"
  if [[ -n "$FILES" ]]; then
    echo "- $FILES" | sed 's/ /\n- /g'
  else
    echo "- (auto-detected by git)"
  fi
  echo ""
  if [[ $TEST_PASSED -eq 1 ]]; then
    echo "### Tests: ${PASSED} passed ✅"
  else
    echo "### Tests: not run ⚠️"
  fi
  echo ""
  echo "### User Approval"
  echo "- User said 'yes commit' in chat"
} > "$MANIFEST_FILE"

# Display manifest
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  COMMIT MANIFEST — reviewed by user                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
cat "$MANIFEST_FILE"
echo ""

# Write approval file
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
{
  echo "timestamp=${TIMESTAMP}"
  echo "message=${COMMIT_MSG}"
  if [[ -n "$FILES" ]]; then
    echo "files=${FILES}"
  fi
  if [[ $TEST_PASSED -eq 1 ]]; then
    echo "tested=true"
    echo "tests_passed=${PASSED}"
  fi
} > "$APPROVAL_FILE"

# Log to audit trail
{
  echo "[${TIMESTAMP}] APPROVED: ${COMMIT_MSG}"
  if [[ $TEST_PASSED -eq 1 ]]; then
    echo "[${TIMESTAMP}] TESTS: ${PASSED} passed"
  fi
} >> "$APPROVAL_LOG"

echo -e "${GREEN}✓${NC} Commit approved."
echo "  Message: ${GREEN}${COMMIT_MSG}${NC}"
echo "  Timestamp: ${TIMESTAMP}"
echo "  ${YELLOW}Approval valid for 5 minutes.${NC}"
if [[ $TEST_PASSED -eq 1 ]]; then
  echo "  ${GREEN}Tests: ${PASSED} passed${NC}"
fi
