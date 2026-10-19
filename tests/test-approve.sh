#!/usr/bin/env bash
# test-approve.sh — Phase 15: the approval is bound to the exact staged tree
# and consumed once. Guards the two defects the dev.to review found:
#   - laundering: approve A, commit B (the index is writable in between)
#   - replay: one approval covering more than one commit
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_SRC="$REPO_ROOT/scripts/git-hooks/pre-commit"
APPROVE="$REPO_ROOT/scripts/approve.sh"

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

make_repo() {
  local d
  d=$(mktemp -d)
  (
    cd "$d" || exit 1
    git init -q
    git checkout -q -b work 2>/dev/null || true
    git config user.email t@t.com
    git config user.name T
    git config commit.gpgsign false
    echo "# init" > README.md
    git add README.md && git commit -q -m init
    mkdir -p .git/hooks
    cp "$HOOK_SRC" .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
  ) >/dev/null 2>&1
  echo "$d"
}

run_hook() {
  ( cd "$1" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR bash .git/hooks/pre-commit ) >/dev/null 2>&1
}

echo ""
echo "APPROVAL BINDING — exact tree + one-time (Phase 15)"
echo "────────────────────────────────────────────────────"

# --- approve.sh refuses an empty index ---
T=$(make_repo)
( cd "$T" && bash "$APPROVE" --yes ) >/dev/null 2>&1; RC=$?
assert "approve.sh refuses with nothing staged" "[ $RC -ne 0 ]"

# --- approve.sh writes timestamp + tree ---
echo note > "$T/a.txt"; ( cd "$T" && git add a.txt )
( cd "$T" && bash "$APPROVE" --yes ) >/dev/null 2>&1; RC=$?
assert "approve.sh succeeds with staged changes" "[ $RC -eq 0 ]"
assert "token carries a timestamp" "grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' '$T/.git/DECISION_APPROVED'"
assert "token is bound to a tree" "grep -qE '^tree=[0-9a-f]{40,64}$' '$T/.git/DECISION_APPROVED'"

# --- matching tree: the hook passes, and consumes the approval (one-time) ---
run_hook "$T"; RC=$?
assert "pre-commit passes when the tree matches the approval" "[ $RC -eq 0 ]"
assert "approval is consumed after a successful pre-commit" "[ ! -f '$T/.git/DECISION_APPROVED' ]"
run_hook "$T"; RC=$?
assert "a second commit without a fresh approval is blocked (anti-replay)" "[ $RC -ne 0 ]"
rm -rf "$T"

# --- laundering: stage after approval -> blocked ---
T=$(make_repo)
echo note > "$T/a.txt"; ( cd "$T" && git add a.txt )
( cd "$T" && bash "$APPROVE" --yes ) >/dev/null 2>&1
echo evil > "$T/b.txt"; ( cd "$T" && git add b.txt )
OUT=$( cd "$T" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR bash .git/hooks/pre-commit 2>&1 ); RC=$?
assert "changing the staged tree after approval is blocked (anti-laundering)" "[ $RC -ne 0 ]"
assert "the block explains the tree changed" "echo \"\$OUT\" | grep -q 'staged tree changed after approval'"
rm -rf "$T"

# --- unbound token (timestamp only) -> blocked ---
T=$(make_repo)
echo note > "$T/a.txt"; ( cd "$T" && git add a.txt )
printf '%s\n' "$(date -Iseconds)" > "$T/.git/DECISION_APPROVED"
OUT=$( cd "$T" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR bash .git/hooks/pre-commit 2>&1 ); RC=$?
assert "a timestamp-only token is blocked" "[ $RC -ne 0 ]"
assert "the block asks for approve.sh (no silent pass)" "echo \"\$OUT\" | grep -q 'not bound to a tree'"
rm -rf "$T"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
