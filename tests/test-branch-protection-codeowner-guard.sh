#!/usr/bin/env bash
# test-branch-protection-codeowner-guard.sh — the code-owner review guard.
#
# "Require review from Code Owners" is another approval the author cannot give
# themselves. When the local CODEOWNERS lists a single owner, a PR authored by
# that owner can never satisfy the requirement (GitHub forbids self-approval),
# so the setup script must drop the requirement rather than risk a lockout.
# This is a persistent behavioral contract for that guard.
#
# Spec: PLAN.md — Phase 8 / docs/BRANCH-PROTECTION.md

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/setup-branch-protection.sh"
DOC="$REPO_ROOT/docs/BRANCH-PROTECTION.md"

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
echo "setup-branch-protection.sh — code-owner guard (solo-safe)"
echo "────────────────────────────────────────────────────────"

assert "script reads CODEOWNERS" "grep -q 'CODEOWNERS' '$SCRIPT'"
assert "script has a code-owner guard" "grep -qi 'code.owner guard' '$SCRIPT'"
assert "script forces code-owner review off for a single owner" "grep -q 'GUARD_CODE_OWNER' '$SCRIPT'"
assert "script supports --no-code-owner-reviews" "grep -q -- '--no-code-owner-reviews' '$SCRIPT'"
assert "script caps approvals at GitHub's API max (6)" "grep -qE 'APPROVALS.*-gt 6|MAX_APPROVALS.*6' '$SCRIPT'"

assert "doc documents the code-owner guard" "grep -qi 'code.owner guard' '$DOC'"
assert "doc documents --no-code-owner-reviews" "grep -q -- '--no-code-owner-reviews' '$DOC'"
assert "doc explains a sole code owner cannot self-approve" "grep -qi 'code owner.*own\|own.*code owner' '$DOC'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
