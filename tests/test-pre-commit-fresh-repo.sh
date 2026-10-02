#!/usr/bin/env bash
# test-pre-commit-fresh-repo.sh — regression: pre-commit must not block commits
# in a brand-new repository (unborn HEAD) and must report a malformed
# DECISION_APPROVED token instead of aborting on a raw git error.
#
# Two bugs found in Phase 8 review:
#   1. Gate 3 ran `LOCAL=$(git rev-parse HEAD)` under `set -euo pipefail`. In a
#      fresh repo HEAD is unborn, so the hook aborted with exit 128 and the
#      first commit was blocked — even on a feature branch.
#   2. The Gate 0 timestamp pipeline (`grep -oP ...`) failed when the token had
#      no timestamp, so `set -e` aborted before the "no valid timestamp"
#      message could print (dead error path).
#
# This is a persistent behavioral contract for both.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_SRC="$REPO_ROOT/scripts/git-hooks/pre-commit"

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

echo ""
echo "pre-commit — fresh repo (unborn HEAD) + malformed token"
echo "────────────────────────────────────────────────────────"

# ── Static: the guards are present ──
assert "Gate 3 guards the unborn HEAD" "grep -q 'git rev-parse HEAD 2>/dev/null' '$HOOK_SRC'"
assert "Gate 3 skips when LOCAL is empty" "grep -q 'if \[ -n \"\$LOCAL\" \]' '$HOOK_SRC'"
assert "Gate 0 timestamp pipeline is guarded" "grep -q 'grep -oP .*| head -1 || true' '$HOOK_SRC'"

# ── Behavioral: first commit in a brand-new repo on a feature branch ──
TMP=$(mktemp -d)
(
  cd "$TMP"
  git init -q
  # Branch before the first commit (unborn HEAD) so Gate 1 (main) is not what
  # we are testing here.
  git checkout -q -b work 2>/dev/null || true
  git config user.email t@t.com
  git config user.name T
  git config commit.gpgsign false
  mkdir -p .git/hooks
  cp "$HOOK_SRC" .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  printf '%s decision\n' "$(date +%Y-%m-%dT%H:%M:%S)" > .git/DECISION_APPROVED
  echo "note" > a.txt
  git add a.txt
) >/dev/null 2>&1

assert "temp repo really has an unborn HEAD" "! git -C '$TMP' rev-parse --verify HEAD >/dev/null 2>&1"
( cd "$TMP" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR bash .git/hooks/pre-commit ) >/dev/null 2>&1
HOOK_EXIT=$?
assert "pre-commit exits 0 with an unborn HEAD (no false block)" "[ $HOOK_EXIT -eq 0 ]"
rm -rf "$TMP"

# ── Behavioral: malformed token reports, does not abort ──
TMP2=$(mktemp -d)
(
  cd "$TMP2"
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
  printf 'yes approved\n' > .git/DECISION_APPROVED   # exists, no timestamp
  echo "note" > a.txt
  git add a.txt
) >/dev/null 2>&1

OUT=$( cd "$TMP2" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR bash .git/hooks/pre-commit 2>&1 ); MAL_EXIT=$?
assert "malformed token still blocks (exit 1)" "[ $MAL_EXIT -eq 1 ]"
assert "malformed token prints the friendly reason" "echo \"\$OUT\" | grep -q 'no valid timestamp'"
rm -rf "$TMP2"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
