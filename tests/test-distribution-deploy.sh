#!/usr/bin/env bash
# test-distribution-deploy.sh — docs/DISTRIBUTION.md documents the web deploy.
#
# Name matches docs/DISTRIBUTION.md (changed by the deploy-web work) so the TDD
# gate pairs it.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOC="$REPO_ROOT/docs/DISTRIBUTION.md"

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

assert "DISTRIBUTION.md exists" "[ -f '$DOC' ]"
assert "documents the web (landing + docs) deployment" "grep -qi 'Web (landing + docs) deployment\|web.*deploy' '$DOC'"
assert "names the deploy workflow" "grep -q 'deploy-web.yml' '$DOC'"
assert "records the one-time Pages source switch" "grep -qi 'GitHub Actions' '$DOC' && grep -qi 'Settings.*Pages\|Pages.*Source' '$DOC'"
assert "notes the security-headers gap (Pages ignores _headers)" "grep -qi '_headers\|CSP\|security.headers' '$DOC'"
assert "points at the deploy workflow + README" "grep -q 'deploy-web' '$DOC'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
