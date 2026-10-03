#!/usr/bin/env bash
# test-pre-commit-skill-gate-tdd-gate-macos.sh — macOS/BSD portability of the
# enforcement hooks and gates.
#
# Pre-existing bug found in the Phase 9 review: pre-commit Gate 0 used GNU-only
# `grep -oP` and `date -d` — on macOS/BSD both fail, so the token timestamp was
# unparseable and EVERY commit was blocked. skill-gate/tdd-gate used GNU-only
# `stat -c`. All now have BSD fallbacks.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"

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

# --- Static: no GNU-only constructs left in the hot paths ---
assert "pre-commit has no grep -oP" "! grep -q 'grep -oP' '$HOOK'"
assert "pre-commit has a BSD date fallback" "grep -q 'date -j -f' '$HOOK'"
assert "pre-commit parses the timestamp with sed" "grep -q \"sed -n 's/.*\" '$HOOK'"
assert "skill-gate has a BSD stat fallback" "grep -q 'stat -f' '$REPO_ROOT/scripts/skill-gate.sh'"
assert "tdd-gate has a BSD stat fallback" "grep -q \"stat -f '%m'\" '$REPO_ROOT/scripts/tdd-gate.sh'"

# --- Behavioral: Gate 0 parses a fresh token (does not block) ---
TMP=$(mktemp -d)
(
  cd "$TMP"
  git init -q
  git checkout -q -b work 2>/dev/null || true
  git config user.email t@t.com
  git config user.name T
  git config commit.gpgsign false
  echo "# init" > README.md && git add README.md && git commit -q -m init
  mkdir -p .git/hooks
  cp "$HOOK" .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
  printf '%s decision\n' "$(date -u +%Y-%m-%dT%H:%M:%S)" > .git/DECISION_APPROVED
  echo "note" > a.txt && git add a.txt
) >/dev/null 2>&1

OUT_FRESH=$(cd "$TMP" && AAS_DIR="$REPO_ROOT" bash .git/hooks/pre-commit 2>&1 || true)
assert "fresh token: Gate 0 reports fresh (timestamp parsed)" "echo \"\$OUT_FRESH\" | grep -q 'Decision prompt fresh'"

# --- Behavioral: a stale token is detected and blocks ---
printf '2020-01-01T00:00:00 decision\n' > "$TMP/.git/DECISION_APPROVED"
OUT_STALE=$(cd "$TMP" && AAS_DIR="$REPO_ROOT" bash .git/hooks/pre-commit 2>&1); RC=$?
assert "stale token: Gate 0 blocks (exit != 0)" "[ $RC -ne 0 ]"
assert "stale token: reports 'stale'" "echo \"\$OUT_STALE\" | grep -qi 'stale'"

# --- Behavioral: a token with no timestamp is detected (not silently ignored) ---
printf 'no timestamp here\n' > "$TMP/.git/DECISION_APPROVED"
OUT_NOTS=$(cd "$TMP" && AAS_DIR="$REPO_ROOT" bash .git/hooks/pre-commit 2>&1); RC2=$?
assert "no-timestamp token: Gate 0 blocks" "[ $RC2 -ne 0 ]"
assert "no-timestamp token: reports 'no valid timestamp'" "echo \"\$OUT_NOTS\" | grep -qi 'no valid timestamp'"

rm -rf "$TMP"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
