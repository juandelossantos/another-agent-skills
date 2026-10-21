#!/usr/bin/env bash
# test-readme-no-changelog.sh — READMEs are product pages, not release logs.
#
# Policy (v6.4.3): a README shows exactly ONE "What's new" section, and it names
# the current VERSION. History lives in RELEASE-NOTES.md and GitHub Releases,
# linked from a single "Previous releases" line. Without this gate every release
# appends another section and the page becomes a changelog nobody reads.
#
# Version-agnostic on purpose: it reads VERSION, so it keeps working on every bump.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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

check_readme() {  # path, label
  local file="$1" label="$2"
  local whats count stale

  echo ""
  echo "$label"
  [ -f "$file" ]; local exists=$?
  assert "exists" "[ '$exists' = '0' ]"

  whats="$(grep -ciE "^\*\*what's new|^## what's new" "$file" 2>/dev/null || true)"
  count="$(grep -cE '^## What.s [Nn]ew' "$file" 2>/dev/null || true)"
  assert "has exactly one What's new section" "[ '$count' = '1' ]"
  assert "the What's new section names v$V" "grep -qiE \"^## What's new in v$V\$\" '$file'"

  # Any OTHER versioned heading means the page is accumulating history.
  stale="$(grep -E '^## .*v[0-9]+\.[0-9]+\.[0-9]+' "$file" \
    | grep -viE "v$V\$|v$V[^0-9]" || true)"
  assert "no other versioned section" "[ -z \"\$stale\" ]"

  assert "links the previous releases" "grep -qE 'Previous releases|Older releases' '$file'"
  assert "links RELEASE-NOTES.md" "grep -q 'RELEASE-NOTES.md' '$file'"
  assert "links GitHub Releases" "grep -q 'github.com/juandelossantos/another-agent-skills/releases' '$file'"
}

echo ""
echo "README policy — one current release, history in RELEASE-NOTES.md"
echo "────────────────────────────────────────────────────────────────"

check_readme "$REPO_ROOT/README.md" "README.md (GitHub)"
check_readme "$REPO_ROOT/npm/README.md" "npm/README.md (npm page)"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
