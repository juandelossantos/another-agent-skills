#!/usr/bin/env bash
# test-agent-runner.sh — Phase 15: the external runner applies a patch, runs the
# suite, and commits only if green. On failure it reverts and never commits.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNNER="$REPO_ROOT/scripts/agent-runner.sh"

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

make_repo() {
  local d; d=$(mktemp -d)
  (
    cd "$d" || exit 1
    git init -q
    git config user.email t@t.com
    git config user.name T
    git config commit.gpgsign false
    echo one > a.txt
    git add a.txt && git commit -q -m init
  ) >/dev/null 2>&1
  echo "$d"
}

make_patch() {
  local d="$1" p; p=$(mktemp)
  ( cd "$d" && echo two > a.txt && git diff > "$p" && git checkout -- a.txt ) >/dev/null 2>&1
  echo "$p"
}

echo ""
echo "agent-runner — patch → tests → commit, or revert"
echo "──────────────────────────────────────────────────"

# --- passing tests: commit ---
T=$(make_repo); P=$(make_patch "$T")
( cd "$T" && bash "$RUNNER" --patch "$P" --message "apply patch" --test-cmd "true" ) >/dev/null 2>&1; RC=$?
assert "passing tests → commit (exit 0)" "[ $RC -eq 0 ]"
assert "the patch was applied" "grep -q '^two$' '$T/a.txt'"
assert "the commit message is the requested one" "[ \"\$(git -C '$T' log -1 --format=%s)\" = 'apply patch' ]"
rm -rf "$T" "$P"

# --- failing tests: revert, no commit ---
T=$(make_repo); P=$(make_patch "$T")
( cd "$T" && bash "$RUNNER" --patch "$P" --message "should fail" --test-cmd "false" ) >/dev/null 2>&1; RC=$?
assert "failing tests → exit 1" "[ $RC -ne 0 ]"
assert "the patch was reverted" "grep -q '^one$' '$T/a.txt'"
assert "no commit was created" "[ \"\$(git -C '$T' log -1 --format=%s)\" = 'init' ]"
rm -rf "$T" "$P"

# --- invalid patch ---
T=$(make_repo); BAD=$(mktemp); printf 'not a patch\n' > "$BAD"
( cd "$T" && bash "$RUNNER" --patch "$BAD" --message "nope" --test-cmd "true" ) >/dev/null 2>&1; RC=$?
assert "invalid patch → exit 1" "[ $RC -ne 0 ]"
assert "invalid patch leaves the tree untouched" "grep -q '^one$' '$T/a.txt'"
rm -rf "$T" "$BAD"

# --- dirty tree is refused unless --allow-dirty ---
T=$(make_repo); P=$(make_patch "$T"); echo dirty > "$T/b.txt"
( cd "$T" && bash "$RUNNER" --patch "$P" --message "nope" --test-cmd "true" ) >/dev/null 2>&1; RC=$?
assert "dirty tree → exit 1" "[ $RC -ne 0 ]"
assert "dirty tree: no commit" "[ \"\$(git -C '$T' log -1 --format=%s)\" = 'init' ]"
rm -rf "$T" "$P"

# --- dry-run: apply + test, then revert, no commit ---
T=$(make_repo); P=$(make_patch "$T")
( cd "$T" && bash "$RUNNER" --patch "$P" --message "dry" --test-cmd "true" --dry-run ) >/dev/null 2>&1; RC=$?
assert "dry-run with passing tests → exit 0" "[ $RC -eq 0 ]"
assert "dry-run reverts the patch" "grep -q '^one$' '$T/a.txt'"
assert "dry-run creates no commit" "[ \"\$(git -C '$T' log -1 --format=%s)\" = 'init' ]"
rm -rf "$T" "$P"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
