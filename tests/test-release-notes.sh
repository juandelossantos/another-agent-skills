#!/usr/bin/env bash
# test-release-notes.sh — Content check for RELEASE-NOTES.md: the v6.1.0
# entry exists, documents the review-caught bugs honestly, and matches
# VERSION.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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
assert "6.2.0 is the topmost (most recent) entry" "[ \"\$(grep -n '^## ' '$FILE' | head -1 | cut -d: -f2-)\" = '## 6.2.0 (2026-10-01) — Phase 7: OpenCode v1/v2, Multi-Agent & Guardrails' ]"
assert "documents the pre-flight.sh commit-blocking bug" "grep -qi 'blocked every normal commit' '$FILE'"
assert "documents the commit-approval.sh retired-token bug" "grep -q 'retired token file' '$FILE'"
assert "VERSION matches the top RELEASE-NOTES entry" "[ \"\$(cat '$REPO_ROOT/VERSION')\" = '6.2.0' ]"
assert "documents the second (GitHub PR) review round's macOS date bug" "grep -qi 'GNU-only .date -d.' '$FILE'"
assert "documents the CI failure this review caught" "grep -qi 'CI failure this review caught' '$FILE'"
assert "documents the absolute-symlink root cause found after fixing the review's findings" "grep -qi 'absolute, machine-specific path' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
