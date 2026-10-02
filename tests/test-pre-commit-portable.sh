#!/usr/bin/env bash
# test-pre-commit-portable.sh — the pre-commit hook resolves the framework from
# $AAS_DIR (P9.7) instead of pointing at the project's own scripts/ copies.
#
# Framework scripts (edit-guard, skill-gate, skill-lint, eval, cadence conf)
# come from $AAS_DIR/scripts/*; project paths ($REPO_ROOT/tests/run-all.sh,
# STACK_CONFIG.md, $REPO_ROOT/.git/*) stay project-relative. When no framework
# is installed the hook still passes (never blocks a teammate without AAS).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# A valid framework dir with a controllable skill-gate.
make_fw() {
  local d="$1" gate_rc="$2"
  mkdir -p "$d/scripts/git-hooks"
  printf '6.2.0\n' > "$d/VERSION"
  printf '#!/bin/sh\nexit %s\n' "$gate_rc" > "$d/scripts/skill-gate.sh"
  chmod +x "$d/scripts/skill-gate.sh"
}

# Set up a temp git repo with the hook installed and a fresh decision token.
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
  cp "$HOOK_SRC" "$repo/.git/hooks/pre-commit"
  # The hook resolves the framework via aas-resolve.sh (SCRIPT_DIR/../ = .git/).
  # Copy it so the test is deterministic — CI does not export
  # ANOTHER_AGENT_SKILLS_DIR, so the resolver must be found here.
  cp "$REPO_ROOT/scripts/aas-resolve.sh" "$repo/.git/aas-resolve.sh"
  chmod +x "$repo/.git/hooks/pre-commit"
  printf '%s decision\n' "$(date +%Y-%m-%dT%H:%M:%S)" > "$repo/.git/DECISION_APPROVED"
  echo "note" > "$repo/a.txt"
  git -C "$repo" add a.txt
}

echo ""
echo "PRE-COMMIT — portable framework resolution (P9.7)"
echo "──────────────────────────────────────────────────"

# --- Static: framework vs project paths ---
assert "hook sources the resolver" "grep -q 'aas-resolve.sh' '$HOOK_SRC'"
assert "hook defines AAS_SCRIPTS from AAS_DIR" "grep -q 'AAS_SCRIPTS=' '$HOOK_SRC'"
assert "edit-guard comes from the framework" "grep -q 'EDIT_GUARD=\"\${AAS_SCRIPTS}/edit-guard.sh\"' '$HOOK_SRC'"
assert "skill-gate comes from the framework" "grep -q 'SKILL_GATE=\"\${AAS_SCRIPTS}/skill-gate.sh\"' '$HOOK_SRC'"
assert "skill-lint comes from the framework" "grep -q 'SKILL_LINT=\"\${AAS_SCRIPTS}/skill-lint.sh\"' '$HOOK_SRC'"
assert "no framework script is read from REPO_ROOT/scripts anymore" \
  "! grep -qE '\\\$\{REPO_ROOT\}/scripts/(edit-guard|skill-gate|skill-lint|validate-skill-table|validate-health-check)' '$HOOK_SRC'"
assert "project test runner stays project-relative" "grep -q 'TEST_RUNNER=\"\${REPO_ROOT}/tests/run-all.sh\"' '$HOOK_SRC'"
assert "STACK_CONFIG stays project-relative" "grep -q 'STACK_CONFIG=\"\${REPO_ROOT}/STACK_CONFIG.md\"' '$HOOK_SRC'"
assert "hook emits the non-blocking drift advisory" "grep -q '_aas_resolve_drift_notice' '$HOOK_SRC'"

# --- Behavioral: no framework installed → passes (never blocks) ---
R1="$TMP/repo-nofw"; make_repo "$R1"
( cd "$R1" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR HOME="$TMP/nofw-home" \
    bash .git/hooks/pre-commit ) >/dev/null 2>&1
assert "no framework → pre-commit exits 0 (teammate without AAS)" "[ $? -eq 0 ]"

# --- Behavioral: skill gate is ADVISORY in a user project (P9.8 scoping) ---
FW_BLOCK="$TMP/fw-block"; make_fw "$FW_BLOCK" 1
R2="$TMP/repo-block"; make_repo "$R2"
( cd "$R2" && AAS_DIR="$FW_BLOCK" bash .git/hooks/pre-commit ) >/dev/null 2>&1
assert "user project: failing skill-gate is advisory (exit 0)" "[ $? -eq 0 ]"

# --- Behavioral: opt-in AAS_SKILL_GATE=block blocks ---
( cd "$R2" && AAS_DIR="$FW_BLOCK" AAS_SKILL_GATE=block bash .git/hooks/pre-commit ) >/dev/null 2>&1
assert "opt-in AAS_SKILL_GATE=block: blocks (exit 1)" "[ $? -ne 0 ]"

# --- Behavioral: the framework repo blocks by default (SOUL.md + VERSION) ---
touch "$R2/SOUL.md" "$R2/VERSION"
( cd "$R2" && AAS_DIR="$FW_BLOCK" bash .git/hooks/pre-commit ) >/dev/null 2>&1
assert "framework repo (SOUL.md+VERSION): blocks by default" "[ $? -ne 0 ]"
rm -f "$R2/SOUL.md" "$R2/VERSION"

# --- Behavioral: passing framework gate → hook passes ---
FW_OK="$TMP/fw-ok"; make_fw "$FW_OK" 0
R3="$TMP/repo-ok"; make_repo "$R3"
( cd "$R3" && AAS_DIR="$FW_OK" bash .git/hooks/pre-commit ) >/dev/null 2>&1
assert "passing framework gate → pre-commit exits 0" "[ $? -eq 0 ]"

# --- Behavioral: hook run from the dev source resolves the source tree ---
R4="$TMP/repo-src"; make_repo "$R4"
# Place the hook next to a real resolver so SCRIPT_DIR/../aas-resolve.sh exists.
mkdir -p "$R4/fw/scripts/git-hooks"
cp "$REPO_ROOT/scripts/aas-resolve.sh" "$R4/fw/scripts/aas-resolve.sh"
printf '6.2.0\n' > "$R4/fw/VERSION"
printf '#!/bin/sh\nexit 0\n' > "$R4/fw/scripts/skill-gate.sh"
( cd "$R4" && env -u AAS_DIR -u ANOTHER_AGENT_SKILLS_DIR HOME="$TMP/src-home" \
    bash .git/hooks/pre-commit ) >/dev/null 2>&1
assert "hook still exits 0 when only the project resolver is present" "[ $? -eq 0 ]"

# --- Behavioral: drift advisory is printed and non-blocking ---
R5="$TMP/repo-drift"; make_repo "$R5"
mkdir -p "$R5/.aas"
printf '{ "version": "0.0.1" }\n' > "$R5/.aas/config"
OUT5="$( cd "$R5" && AAS_DIR="$FW_OK" bash .git/hooks/pre-commit 2>&1 )"; RC5=$?
assert "drift advisory is printed" "echo '$OUT5' | grep -q 'advisory'"
assert "drift advisory is non-blocking (exit 0)" "[ $RC5 -eq 0 ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
