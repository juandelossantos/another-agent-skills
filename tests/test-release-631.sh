#!/usr/bin/env bash
# test-release-631.sh — version consistency for 6.3.1: VERSION, the npm package,
# the RELEASE-NOTES top entry and the "current version" docs must all agree.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  TOTAL=$((TOTAL + 1))
  if eval "$2"; then
    echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1))
  fi
}

assert "VERSION is 6.3.1" "[ '$V' = '6.3.1' ]"
assert "npm/package.json mirrors VERSION" "[ \"\$(node -p \"require('$REPO_ROOT/npm/package.json').version\")\" = '$V' ]"
assert "RELEASE-NOTES top entry is 6.3.1" "[ \"\$(grep -m1 '^## ' '$REPO_ROOT/RELEASE-NOTES.md' | cut -d' ' -f2)\" = '$V' ]"
assert "README badge is v6.3.1" "grep -q 'Version: v6.3.1' '$REPO_ROOT/README.md'"
assert "PROGRESS_STATUS current version is 6.3.1" "grep -qF 'Current version:** 6.3.1' '$REPO_ROOT/PROGRESS_STATUS.md'"
assert "HEALTH-CHECK version is 6.3.1" "grep -qF '**Version:** 6.3.1' '$REPO_ROOT/HEALTH-CHECK.md'"
assert "bootstrap.sh usage example tracks VERSION" "grep -q -- '--version v${V}' '$REPO_ROOT/bootstrap.sh'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
