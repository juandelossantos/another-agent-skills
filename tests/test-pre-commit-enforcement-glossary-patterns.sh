#!/usr/bin/env bash
# test-pre-commit-enforcement-glossary-patterns.sh — the skill gate is scoped:
# BLOCKING in the framework repo / opt-in, ADVISORY in a user project. Also
# guards the docs (enforcement.md / GLOSSARY / PATTERNS) after project-pre-commit
# was removed.

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

# --- project-pre-commit removed; docs point at the framework hook ---
assert "scripts/project-pre-commit is gone" "[ ! -e '$REPO_ROOT/scripts/project-pre-commit' ]"
assert "enforcement.md no longer references it" "! grep -q 'project-pre-commit' '$REPO_ROOT/rules/common/enforcement.md'"
assert "GLOSSARY.md no longer references it" "! grep -q 'project-pre-commit' '$REPO_ROOT/GLOSSARY.md'"
assert "PATTERNS.md no longer references it" "! grep -q 'project-pre-commit' '$REPO_ROOT/PATTERNS.md'"
assert "docs point at scripts/git-hooks/pre-commit" "grep -q 'scripts/git-hooks/pre-commit' '$REPO_ROOT/GLOSSARY.md' && grep -q 'scripts/git-hooks/pre-commit' '$REPO_ROOT/rules/common/enforcement.md'"

# --- Static: the skill-gate scope logic exists ---
assert "hook computes SKILL_GATE_MODE" "grep -q 'SKILL_GATE_MODE=' '$HOOK'"
assert "AAS_SKILL_GATE overrides" "grep -q 'AAS_SKILL_GATE' '$HOOK'"
assert "framework repo is blocking" "grep -q 'the framework repo itself' '$HOOK'"
assert "user projects opt in via .aas/config" "grep -q '\"skill_gate\"' '$HOOK'"
assert "advisory path exists" "grep -q 'Skill gate (advisory)' '$HOOK'"

# --- Behavioral: advisory in a user project, blocking on opt-in ---
TMP=$(mktemp -d)
(
  cd "$TMP"
  git init -q
  git checkout -q -b work 2>/dev/null || true
  git config user.email t@t.com
  git config user.name T
  git config commit.gpgsign false
  echo "# init" > README.md && git add README.md && git commit -q -m init
  mkdir -p .git/hooks tests
  cp "$HOOK" .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
  printf '%s d\n' "$(date +%Y-%m-%dT%H:%M:%S)" > .git/DECISION_APPROVED
  echo 'echo x' > foo.sh
  touch tests/test_foo.sh
  git add foo.sh tests/test_foo.sh
) >/dev/null 2>&1

OUT_ADV=$(cd "$TMP" && AAS_DIR="$REPO_ROOT" bash .git/hooks/pre-commit 2>&1 || true)
assert "user project: skill gate is advisory (not blocked)" "echo \"\$OUT_ADV\" | grep -q 'Skill gate (advisory)'"
assert "user project: no SKILL GATE BLOCKED" "! echo \"\$OUT_ADV\" | grep -q 'SKILL GATE BLOCKED'"

OUT_BLOCK=$(cd "$TMP" && AAS_DIR="$REPO_ROOT" AAS_SKILL_GATE=block bash .git/hooks/pre-commit 2>&1 || true)
assert "opt-in AAS_SKILL_GATE=block: blocks" "echo \"\$OUT_BLOCK\" | grep -q 'SKILL GATE BLOCKED'"

rm -rf "$TMP"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
