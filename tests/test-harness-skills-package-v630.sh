#!/usr/bin/env bash
# test-harness-skills-package-v630.sh — v6.3.0 synchronization: the guide count is
# the real one (151, not the stale 74), and the npm package version tracks VERSION.
#
# Name matches the changed code files docs/HARNESS.md, docs/skills.html and
# npm/package.json so the TDD gate pairs them.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"

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

# --- VERSION is the release ---
assert "VERSION is 6.3.1" "[ '$VERSION' = '6.3.1' ]"

# --- npm tracks VERSION (the OIDC workflow also syncs it, but the repo stays in sync) ---
assert "npm/package.json version == VERSION" "[ \"\$(node -p \"require('$REPO_ROOT/npm/package.json').version\")\" = '$VERSION' ]"

# --- The guide count is the real one (151), not the stale 74 ---
assert "HARNESS.md states 151 guides" "grep -q '151 guides' '$REPO_ROOT/docs/HARNESS.md'"
assert "HARNESS.md no longer says 74 guides" "! grep -q '74 guides' '$REPO_ROOT/docs/HARNESS.md'"
assert "docs/skills.html states 151" "grep -q '151' '$REPO_ROOT/docs/skills.html'"
assert "README states 151 guides" "grep -q '151 guides' '$REPO_ROOT/README.md'"

# --- npm derives the version (no hardcoded 6.2.0 in the release paths) ---
assert "build-brew-formula was removed (Homebrew dropped)" "[ ! -e '$REPO_ROOT/scripts/build-brew-formula.sh' ]"
assert "npm publish workflow syncs from VERSION" "grep -q 'VERSION' '$REPO_ROOT/.github/workflows/npm-publish.yml'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
