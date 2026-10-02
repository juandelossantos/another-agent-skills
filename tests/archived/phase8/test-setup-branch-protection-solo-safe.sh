#!/usr/bin/env bash
# test-setup-branch-protection-solo-safe.sh — Phase 8 content check: the
# branch-protection script is solo-safe. It auto-detects the repo shape, offers
# solo/team profiles, and enforces a lockout guard (never require an approval
# the only human with push access cannot give). The behavioral coverage lives in
# tests/test-setup-branch-protection.sh; this is the phase snapshot.
#
# Spec: PLAN.md — Phase 8 / P8.1 + docs/BRANCH-PROTECTION.md

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
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
echo "branch protection — solo-safe profiles + lockout guard"
echo "────────────────────────────────────────────────────────"

# ── Script: detection ──
assert "detects the owner type" "grep -q 'owner.type' '$SCRIPT'"
assert "counts push/admin collaborators" "grep -q 'collaborators' '$SCRIPT'"
assert "excludes bots from the human count" "grep -q '\[bot\]' '$SCRIPT'"

# ── Script: profiles + flags ──
assert "supports --mode auto|solo|team" "grep -q 'auto|solo|team' '$SCRIPT'"
assert "solo profile: 0 approvals" "grep -q 'APPROVALS=0' '$SCRIPT'"
assert "team profile: 1 approval" "grep -q 'APPROVALS=1' '$SCRIPT'"
assert "supports --approvals" "grep -q -- '--approvals' '$SCRIPT'"
assert "supports --code-owner-reviews" "grep -q -- '--code-owner-reviews' '$SCRIPT'"
assert "supports --enforce-admins" "grep -q -- '--enforce-admins' '$SCRIPT'"

# ── Script: lockout guard ──
assert "has a lockout guard" "grep -qi 'lockout guard' '$SCRIPT'"
assert "guard forces the solo-safe profile" "grep -q 'solo-safe profile' '$SCRIPT'"
assert "guard can be overridden explicitly" "grep -q -- '--force-lockout-risk' '$SCRIPT'"
assert "prints the detected + final mode" "grep -q 'final mode' '$SCRIPT'"
assert "prints the final payload" "grep -q 'Final payload' '$SCRIPT'"

# ── Doc: the human-facing contract ──
assert "doc exists" "[ -f '$DOC' ]"
assert "doc explains you cannot approve your own PR" "grep -qi 'approve your own' '$DOC'"
assert "doc covers the solo profile" "grep -q 'solo' '$DOC'"
assert "doc covers the team profile" "grep -q 'team' '$DOC'"
assert "doc documents the lockout guard" "grep -qi 'lockout guard' '$DOC'"
assert "doc documents --force-lockout-risk" "grep -q -- '--force-lockout-risk' '$DOC'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
