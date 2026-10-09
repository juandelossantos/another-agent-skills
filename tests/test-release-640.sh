#!/usr/bin/env bash
# test-release-640.sh — every version surface must agree with VERSION.
#
# Version-agnostic on purpose: it reads VERSION and asserts each surface, so it
# survives future version bumps without edits (the version is never hardcoded).
# Surfaces: npm/package.json · README badge · RELEASE-NOTES top · PROGRESS ·
# HEALTH · bootstrap.sh · docs/index.html · web/src/config.ts.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  TOTAL=$((TOTAL + 1))
  if eval "$2"; then
    echo "  ✓ $1"; PASSED=$((PASSED + 1))
  else
    echo "  ✗ $1"; FAILED=$((FAILED + 1))
  fi
}

assert "VERSION is semver (X.Y.Z)" "echo '$V' | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'"
assert "npm/package.json mirrors VERSION" "[ \"\$(node -p \"require('$REPO_ROOT/npm/package.json').version\")\" = '$V' ]"
assert "RELEASE-NOTES top entry is VERSION" "[ \"\$(grep -m1 '^## ' '$REPO_ROOT/RELEASE-NOTES.md' | cut -d' ' -f2)\" = '$V' ]"
assert "README badge is v\$V" "grep -q 'Version: v$V' '$REPO_ROOT/README.md'"
assert "PROGRESS_STATUS current version is VERSION" "grep -qF 'Current version:** $V' '$REPO_ROOT/PROGRESS_STATUS.md'"
assert "HEALTH-CHECK version is VERSION" "grep -qF '**Version:** $V' '$REPO_ROOT/HEALTH-CHECK.md'"
assert "bootstrap.sh usage example tracks VERSION" "grep -q -- '--version v$V' '$REPO_ROOT/bootstrap.sh'"
assert "docs/index.html current version is v\$V" "grep -q \"<td>v$V</td>\" '$REPO_ROOT/docs/index.html'"
assert "web/src/config.ts VERSION is v\$V" "grep -q \"VERSION = 'v$V'\" '$REPO_ROOT/web/src/config.ts'"

echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
