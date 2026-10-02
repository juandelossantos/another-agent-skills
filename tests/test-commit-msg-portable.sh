#!/usr/bin/env bash
# test-commit-msg-portable.sh — the commit-msg hook resolves the framework's
# TDD gate from $AAS_DIR/scripts/tdd-gate.sh (P9.7) instead of the project's own
# scripts/tdd-gate.sh. With the framework present the gate still blocks a
# code-without-test commit; with no framework it skips cleanly.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_SRC="$REPO_ROOT/scripts/git-hooks/commit-msg"

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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

make_fw() {
  local d="$1" gate_rc="$2"
  mkdir -p "$d/scripts/git-hooks"
  printf '6.2.0\n' > "$d/VERSION"
  printf '#!/bin/sh\nexit %s\n' "$gate_rc" > "$d/scripts/tdd-gate.sh"
  chmod +x "$d/scripts/tdd-gate.sh"
}

make_repo() {
  local repo="$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" checkout -q -b work 2>/dev/null || true
  git -C "$repo" config user.email t@t.com
  git -C "$repo" config user.name T
  git -C "$repo" config commit.gpgsign false
  echo "# init" > "$repo/README.md"
  git -C "$repo" add README.md && git -C "$repo" commit -q -m init
  mkdir -p "$repo/.git/hooks"
  cp "$HOOK_SRC" "$repo/.git/hooks/commit-msg"
  chmod +x "$repo/.git/hooks/commit-msg"
}

echo ""
echo "COMMIT-MSG — portable framework resolution (P9.7)"
echo "──────────────────────────────────────────────────"

# --- Static ---
assert "hook sources the resolver" "grep -q 'aas-resolve.sh' '$HOOK_SRC'"
assert "TDD gate comes from the framework" "grep -q 'TDD_GATE=\"\${AAS_SCRIPTS}/tdd-gate.sh\"' '$HOOK_SRC'"
assert "no REPO_ROOT/scripts/tdd-gate.sh left" "! grep -q 'REPO_ROOT}/scripts/tdd-gate.sh' '$HOOK_SRC'"
assert "approval log stays project-relative" "grep -q 'APPROVAL_LOG=\"\${REPO_ROOT}/.git/APPROVAL_LOG\"' '$HOOK_SRC'"
assert "hook emits the non-blocking drift advisory" "grep -q '_aas_resolve_drift_notice' '$HOOK_SRC'"

# --- Behavioral: framework TDD gate blocks code without a test ---
FW_BLOCK="$TMP/fw-block"; make_fw "$FW_BLOCK" 1
R1="$TMP/repo-block"; make_repo "$R1"
echo 'export const x = 1' > "$R1/foo.js"
git -C "$R1" add foo.js
printf 'code without test\n' > "$TMP/msg1.txt"
( cd "$R1" && AAS_DIR="$FW_BLOCK" bash .git/hooks/commit-msg "$TMP/msg1.txt" ) >/dev/null 2>&1
assert "framework TDD gate from \$AAS_DIR blocks (exit 1)" "[ $? -ne 0 ]"

# --- Behavioral: passing framework TDD gate allows the commit ---
FW_OK="$TMP/fw-ok"; make_fw "$FW_OK" 0
R2="$TMP/repo-ok"; make_repo "$R2"
echo 'export const x = 1' > "$R2/foo.js"
git -C "$R2" add foo.js
( cd "$R2" && AAS_DIR="$FW_OK" bash .git/hooks/commit-msg "$TMP/msg1.txt" ) >/dev/null 2>&1
assert "passing framework TDD gate allows (exit 0)" "[ $? -eq 0 ]"

# --- Behavioral: no framework → skip, never block ---
R3="$TMP/repo-nofw"; make_repo "$R3"
echo 'export const x = 1' > "$R3/foo.js"
git -C "$R3" add foo.js
( cd "$R3" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR HOME="$TMP/nofw-home" \
    bash .git/hooks/commit-msg "$TMP/msg1.txt" ) >/dev/null 2>&1
assert "no framework → commit-msg exits 0 (never blocks)" "[ $? -eq 0 ]"

# --- Behavioral: the real dev-repo gate still enforces ---
R4="$TMP/repo-real"; make_repo "$R4"
echo 'export const x = 1' > "$R4/foo.js"
git -C "$R4" add foo.js
( cd "$R4" && AAS_DIR="$REPO_ROOT" bash .git/hooks/commit-msg "$TMP/msg1.txt" ) >/dev/null 2>&1
assert "dev-repo TDD gate blocks code without a test" "[ $? -ne 0 ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
