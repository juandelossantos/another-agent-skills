#!/usr/bin/env bash
# test-release-version-consistency.sh — version-AGNOSTIC release check: every
# version surface must agree with VERSION, whatever it is. Delegates the channel
# surfaces to scripts/check-channel-consistency.sh and adds the release-notes /
# progress / health headers, so a future release does not have to edit a
# version-pinned test.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
V="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"

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

assert "VERSION is a semver" "printf '%s' \"\$V\" | grep -qE '^[0-9]+\\.[0-9]+\\.[0-9]+\$'"
assert "check-channel-consistency.sh passes" "bash '$REPO_ROOT/scripts/check-channel-consistency.sh' --root '$REPO_ROOT' >/dev/null 2>&1"
assert "npm/package.json mirrors VERSION" "[ \"\$(node -p \"require('$REPO_ROOT/npm/package.json').version\")\" = '$V' ]"
assert "RELEASE-NOTES top entry is $V" "[ \"\$(grep -m1 '^## ' '$REPO_ROOT/RELEASE-NOTES.md' | cut -d' ' -f2)\" = '$V' ]"
assert "PROGRESS_STATUS current version is $V" "grep -qF 'Current version:** $V' '$REPO_ROOT/PROGRESS_STATUS.md'"
assert "HEALTH-CHECK version is $V" "grep -qF '**Version:** $V' '$REPO_ROOT/HEALTH-CHECK.md'"
assert "bootstrap.sh example tracks VERSION" "grep -q -- '--version v$V' '$REPO_ROOT/bootstrap.sh'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
