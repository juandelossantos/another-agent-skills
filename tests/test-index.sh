#!/usr/bin/env bash
# test-index.sh — the legacy root landing (superseded by web/; GitHub Pages
# deploys web/dist, not this file) stays consistent with the current product:
# the skill/guide counts and no Homebrew channel. This is the name-paired test
# for the `index.html` code change (TDD gate) — `.html` is classified as code.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/index.html"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo "  ✓ $name"; PASSED=$((PASSED + 1))
  else
    echo "  ✗ $name"; FAILED=$((FAILED + 1))
  fi
}

assert "legacy landing advertises 58 skills" "grep -q '58 composable skills' '$FILE'"
assert "legacy landing advertises 153 guides" "grep -q '153 guides' '$FILE'"
assert "legacy landing does not name Homebrew" "! grep -qi 'homebrew' '$FILE'"

echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
