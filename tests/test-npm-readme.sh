#!/usr/bin/env bash
# test-npm-readme.sh — asserts the npm wrapper README documents the wrapper's
# contract: no framework payload, pinned + checksum-verified install, and the
# `aas-npm` bin. Phase 9 / P9.5.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$REPO_ROOT/npm/README.md"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then echo "  ✓ $name"; PASSED=$((PASSED + 1)); else echo "  ✗ $name"; FAILED=$((FAILED + 1)); fi
}

echo ""
echo "npm/README.md — wrapper docs"
echo "─────────────────────────────"

assert "README exists" "[ -f '$FILE' ]"
assert "documents the npx install command" "grep -q 'npx @juandelossantos/another-agent-skills install' '$FILE'"
assert "states it ships no framework payload" "grep -qi 'no framework payload' '$FILE'"
assert "documents the aas-npm bin" "grep -q 'aas-npm' '$FILE'"
assert "documents --version" "grep -q -- '--version' '$FILE'"
assert "documents --dry-run" "grep -q -- '--dry-run' '$FILE'"
assert "documents sha256 verification" "grep -qi 'sha256' '$FILE'"
assert "documents the pinned release (never main)" "grep -qi 'never fetches from' '$FILE'"
assert "documents Node >= 18" "grep -qE 'Node.js >= 18|Node.js ≥ 18' '$FILE'"
assert "documents Trusted Publishing (OIDC)" "grep -qi 'Trusted Publishing' '$FILE'"

echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
