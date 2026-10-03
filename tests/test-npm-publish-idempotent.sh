#!/usr/bin/env bash
# test-npm-publish-idempotent.sh — the OIDC publish is idempotent and keeps the
# npm version in sync with VERSION (so maintainers never sync by hand).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WF="$REPO_ROOT/.github/workflows/npm-publish.yml"

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

assert "workflow exists" "[ -f '$WF' ]"

# Version sync: the npm version is derived from VERSION at publish time.
assert "syncs the version from VERSION" "grep -q 'Sync package.json version from VERSION' '$WF'"
assert "reads VERSION" "grep -q 'tr -d .\\[:space:\\]' '$WF'"

# Idempotency: skip if the version already exists on npm.
assert "checks whether the version is already published" "grep -q 'npm view \"@juandelossantos/another-agent-skills@' '$WF'"
assert "publish step is gated on the check" "grep -q \"if: steps.check.outputs.already != 'true'\" '$WF'"

# Still OIDC, still no token, still publish-only.
assert "requests id-token: write" "grep -q 'id-token: write' '$WF'"
assert "does not use an npm token secret" "! grep -qE 'NPM_TOKEN|secrets\\.NPM' '$WF'"
assert "publishes with --access public" "grep -q 'npm publish --access public' '$WF'"
assert "does not run install/test/build steps" "! grep -qE 'npm (ci|install|test)|run build' '$WF'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
