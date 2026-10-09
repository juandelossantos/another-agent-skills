#!/usr/bin/env bash
# test-release-npm-chain.sh — release.yml MUST chain npm-publish.yml.
#
# A release created by GITHUB_TOKEN does NOT trigger other workflows, so
# `release: published` on npm-publish.yml never fires for our releases. The npm
# channel therefore only works if release.yml calls npm-publish.yml via
# `workflow_call`. This job was dropped by accident in #66 — which is why v6.3.2
# never reached npm. This test guards it.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REL="$REPO_ROOT/.github/workflows/release.yml"
NPM="$REPO_ROOT/.github/workflows/npm-publish.yml"

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

assert "release.yml exists" "[ -f '$REL' ]"
assert "npm-publish.yml exists" "[ -f '$NPM' ]"

# The chained job (block-scoped: from `  publish-npm:` to the next top-level key).
BLOCK="$(awk '/^  publish-npm:/{f=1} f{print} f&&/^[^ ]/&&!/^  publish-npm:/{exit}' "$REL")"
assert "release.yml declares a publish-npm job" "[ -n \"\$BLOCK\" ]"
assert "publish-npm needs the release job" "printf '%s' \"\$BLOCK\" | grep -qE '^    needs: release'"
assert "publish-npm calls npm-publish.yml (workflow_call)" "printf '%s' \"\$BLOCK\" | grep -qF 'uses: ./.github/workflows/npm-publish.yml'"
assert "publish-npm grants id-token: write (OIDC)" "printf '%s' \"\$BLOCK\" | grep -qE '^      id-token: write'"

# The callee must accept workflow_call and keep publishing STAGED.
assert "npm-publish.yml accepts workflow_call" "grep -qE '^  workflow_call:' '$NPM'"
assert "npm-publish.yml stages (never a bare npm publish)" "grep -q 'npm stage publish' '$NPM' && ! grep -qE 'run: npm publish' '$NPM'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
