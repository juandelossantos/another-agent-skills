#!/usr/bin/env bash
# test-npm-publish-workflow.sh — asserts .github/workflows/npm-publish.yml uses
# OIDC Trusted Publishing (no stored npm token), is gated by the npm-release
# environment, and publishes only (no install/test/build). Phase 9 / P9.5.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$REPO_ROOT/.github/workflows/npm-publish.yml"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then echo "  ✓ $name"; PASSED=$((PASSED + 1)); else echo "  ✗ $name"; FAILED=$((FAILED + 1)); fi
}

echo ""
echo "npm-publish.yml — OIDC trusted publishing"
echo "──────────────────────────────────────────"

assert "workflow exists" "[ -f '$FILE' ]"
assert "requests id-token: write (OIDC)" "grep -qE '^  id-token: write' '$FILE'"
assert "requests contents: read" "grep -qE '^  contents: read' '$FILE'"
assert "gated by environment npm-release" "grep -qE '^    environment: npm-release' '$FILE'"
assert "trigger: workflow_dispatch" "grep -q 'workflow_dispatch:' '$FILE'"
assert "trigger: release published" "grep -q 'types: \[published\]' '$FILE'"
assert "uses actions/setup-node" "grep -q 'actions/setup-node' '$FILE'"
assert "Node 24" "grep -qE 'node-version: *.?24' '$FILE'"
assert "runs npm publish" "grep -q 'npm publish' '$FILE'"
assert "publishes with --access public" "grep -q 'npm publish --access public' '$FILE'"
assert "publishes from the npm/ directory" "grep -qE 'working-directory: npm' '$FILE'"
assert "does NOT pass --provenance (automatic under OIDC)" "! grep -q -- '--provenance' '$FILE'"
assert "no npm token secret referenced" "! grep -qi 'NPM_TOKEN' '$FILE'"
assert "no secrets.NPM reference" "! grep -qi 'secrets\.NPM' '$FILE'"
assert "no npm ci (publish only)" "! grep -q 'npm ci' '$FILE'"
assert "no test/build step (publish only)" "! grep -qE 'npm (test|run (test|build))' '$FILE'"
assert "documents trusted publisher setup (user)" "grep -q 'juandelossantos' '$FILE'"
assert "documents trusted publisher setup (workflow)" "grep -q 'npm-publish.yml' '$FILE'"
assert "documents trusted publisher setup (environment)" "grep -q 'npm-release' '$FILE'"

echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
