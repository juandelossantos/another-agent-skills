#!/usr/bin/env bash
# test-branch-protection-l3-honesty.sh — the L2/L3 rows state their real limits.
#
# Found in the Phase 8 closure review: the layers table claimed L3 "closes the
# CI-is-forgeable hole" unconditionally, and L2 "real enforcement" without the
# admin caveat. Both are only true for non-admins / when code-owner review is
# enforced. This guards the honest wording.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BP="$REPO_ROOT/docs/BRANCH-PROTECTION.md"

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

# L3: no unconditional "closes the hole" claim.
assert "L3 row does not claim it closes the hole unconditionally" "! grep -q 'hole\. |$' '$BP'"
assert "L3 qualifies it to enforced code-owner review" "grep -q 'only while code-owner review is enforced' '$BP'"
assert "L3 names the single-owner CODEOWNERS limitation" "grep -qi 'single-owner' '$BP'"
assert "L3 says it is configured but not enforced on solo" "grep -qi 'configured but \*\*not enforced\*\*' '$BP'"

# L2: admin caveat is present.
assert "L2 mentions the solo-admin bypass" "grep -qi 'solo admin can still bypass' '$BP'"

# The deeper caveats still exist (solo + code-owner guards).
assert "still documents the solo admin-bypass caveat" "grep -q 'Solo caveat' '$BP'"
assert "still documents the code-owner guard" "grep -q '## The code-owner guard' '$BP'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
