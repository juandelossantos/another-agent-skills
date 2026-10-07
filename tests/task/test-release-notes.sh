#!/usr/bin/env bash
# test-release-notes.sh — Content check for RELEASE-NOTES.md: the v6.1.0
# entry exists, documents the review-caught bugs honestly, and matches
# VERSION.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$REPO_ROOT/RELEASE-NOTES.md"

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

assert "has a 6.1.0 heading" "grep -q '^## 6.1.0' '$FILE'"
assert "6.3.1 is the topmost (most recent) entry" "[ \"\$(grep -n '^## ' '$FILE' | head -1 | cut -d: -f2-)\" = '## 6.3.1 (2026-10-07) — release pipeline + npm channel fixes' ]"
assert "the top section covers Phase 8/8.1/9/10" "grep -q 'Phase 8 — remote enforcement' '$FILE' && grep -q 'Phase 8.1' '$FILE' && grep -q 'Phase 9 — distribution' '$FILE' && grep -q 'Phase 10 — the public web' '$FILE'"
assert "the top section is honest about the pending npm/Homebrew steps" "grep -qi 'not yet activated' '$FILE' && grep -q 'HOMEBREW_TAP_TOKEN' '$FILE'"
assert "the top section is honest about the un-deployed web" "grep -qi 'not deployed' '$FILE'"
assert "documents the pre-flight.sh commit-blocking bug" "grep -qi 'blocked every normal commit' '$FILE'"
assert "documents the commit-approval.sh retired-token bug" "grep -q 'retired token file' '$FILE'"
assert "VERSION matches the top RELEASE-NOTES entry" "[ \"\$(cat '$REPO_ROOT/VERSION')\" = '6.3.1' ]"
assert "npm/package.json version is 6.3.1 (kept in sync with VERSION)" "grep -q '\"version\": \"6.3.1\"' '$REPO_ROOT/npm/package.json'"
assert "documents the second (GitHub PR) review round's macOS date bug" "grep -qi 'GNU-only .date -d.' '$FILE'"
assert "documents the CI failure this review caught" "grep -qi 'CI failure this review caught' '$FILE'"
assert "documents the absolute-symlink root cause found after fixing the review's findings" "grep -qi 'absolute, machine-specific path' '$FILE'"
assert "documents the Phase-7 flags as POSIX-only" "grep -qi 'Phase 7 flags are POSIX-only' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
