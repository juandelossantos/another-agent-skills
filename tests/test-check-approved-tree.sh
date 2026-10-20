#!/usr/bin/env bash
# test-check-approved-tree.sh — Phase 15 (L2): the required check must refuse a
# PR whose head tree differs from the human-approved digest in the PR body.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$REPO_ROOT/scripts/check-approved-tree.sh"

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

TMP=$(mktemp -d)
(
  cd "$TMP" || exit 1
  git init -q
  git config user.email t@t.com
  git config user.name T
  echo one > a.txt
  git add a.txt
  git commit -q -m one
)
TREE=$(git -C "$TMP" rev-parse 'HEAD^{tree}')

run() { ( cd "$TMP" && PR_BODY="$1" bash "$CHECK" ) >/dev/null 2>&1; }

echo ""
echo "check-approved-tree — L2 approval binding"
echo "──────────────────────────────────────────"

run ""; RC=$?
assert "no PR body (push to main) → skip (exit 0)" "[ $RC -eq 0 ]"

run "Just a description, no digest."; RC=$?
assert "missing digest → block (exit 1)" "[ $RC -ne 0 ]"

run "AAS-APPROVED-TREE: $TREE"; RC=$?
assert "matching digest → pass (exit 0)" "[ $RC -eq 0 ]"

run "Some prose.
AAS-APPROVED-TREE: $TREE
More prose."; RC=$?
assert "digest embedded in a larger body → pass" "[ $RC -eq 0 ]"

OTHER=0000000000000000000000000000000000000000
run "AAS-APPROVED-TREE: $OTHER"; RC=$?
assert "mismatched digest → block (exit 1)" "[ $RC -ne 0 ]"

# A new commit changes the head tree → the old approval no longer matches.
( cd "$TMP" && echo two > b.txt && git add b.txt && git commit -q -m two )
run "AAS-APPROVED-TREE: $TREE"; RC=$?
assert "tree changed after approval → block (exit 1)" "[ $RC -ne 0 ]"
NEW_TREE=$(git -C "$TMP" rev-parse 'HEAD^{tree}')
run "AAS-APPROVED-TREE: $NEW_TREE"; RC=$?
assert "re-approving the new head → pass" "[ $RC -eq 0 ]"

rm -rf "$TMP"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
