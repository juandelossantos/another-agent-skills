#!/usr/bin/env bash
# test-pre-flight.sh — Pre-flight hook test suite
# Verifies main branch protection and basic git state checks
#
# Usage: bash tests/test-pre-flight.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/pre-flight.sh"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${GREEN}Pre-Flight Hook Test Suite${NC}"
echo "─────────────────────────────────"

# ─── Test 1: Blocks on main without MAIN_ALLOWED (current branch is main-like)
echo ""
echo "Test 1: Blocks on main"
TMP=$(mktemp -d)
(cd "$TMP" && git init -q && git config user.email "t@t.com" && git config user.name "T")
touch "$TMP/README.md" "$TMP/.gitignore" "$TMP/.env.example"
(cd "$TMP" && git add README.md .gitignore .env.example && git commit -q -m "init")
# Git's default branch might be master or main
DEFAULT=$(cd "$TMP" && git branch --show-current)
SKIP_UPSTREAM_CHECK=true bash "$SCRIPT" 2>/dev/null; RC=$?
# Should block (exit 1) if on main/master
if [ "$DEFAULT" = "main" ] || [ "$DEFAULT" = "master" ]; then
  assert "blocks on $DEFAULT without MAIN_ALLOWED" "[ $RC -eq 1 ]"
else
  assert "skipped (branch: $DEFAULT)" "[ $RC -eq 0 ]"
fi
rm -rf "$TMP"

# ─── Test 2: Passes on feature branch ───
echo ""
echo "Test 2: Passes on feature branch"
TMP2=$(mktemp -d)
(cd "$TMP2" && git init -q -b feat/test && git config user.email "t@t.com" && git config user.name "T")
touch "$TMP2/README.md" "$TMP2/.gitignore" "$TMP2/.env.example"
(cd "$TMP2" && git add README.md .gitignore .env.example && git commit -q -m "init")
(cd "$TMP2" && SKIP_UPSTREAM_CHECK=true bash "$SCRIPT" > /dev/null 2>&1); RC=$?
assert "passes on feat/test" "[ $RC -eq 0 ]"
rm -rf "$TMP2"

# ─── Test 3: Passes on main with MAIN_ALLOWED ───
echo ""
echo "Test 3: Passes on main with MAIN_ALLOWED"
TMP3=$(mktemp -d)
(cd "$TMP3" && git init -q && git config user.email "t@t.com" && git config user.name "T")
touch "$TMP3/README.md" "$TMP3/.gitignore" "$TMP3/.env.example"
(cd "$TMP3" && git add README.md .gitignore .env.example && git commit -q -m "init")
DEFAULT=$(cd "$TMP3" && git branch --show-current)
if [ "$DEFAULT" = "main" ] || [ "$DEFAULT" = "master" ]; then
  (cd "$TMP3" && MAIN_ALLOWED=true SKIP_UPSTREAM_CHECK=true bash "$SCRIPT" > /dev/null 2>&1); RC=$?
  assert "passes with MAIN_ALLOWED=true" "[ $RC -eq 0 ]"
else
  assert "skipped (branch: $DEFAULT)" "[ $RC -eq 0 ]"
fi
rm -rf "$TMP3"

# ─── Test 4: Syntax valid ───
echo ""
echo "Test 4: Syntax valid"
bash -n "$SCRIPT" 2>/dev/null
assert "bash -n passes" "[ $? -eq 0 ]"

# ─── Summary ───
echo ""
echo "─────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
