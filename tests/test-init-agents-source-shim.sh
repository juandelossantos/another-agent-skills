#!/usr/bin/env bash
# test-init-agents-source-shim.sh — the portable hook shim self-resolves inside
# the framework source tree (P9.7b): a fresh clone of the framework repo works
# without installing anything, and a plain repo without AAS is never blocked.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"

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

# --- Static: the shim template walks up to the framework source ---
assert "shim template has the source-tree walk" "grep -q '_AAS_WALK' '$INIT'"
assert "walk checks VERSION + scripts/git-hooks/pre-commit" "grep -q 'scripts/git-hooks/pre-commit' '$INIT'"
assert "framework source repo is detected" "grep -q 'is_framework_repo()' '$INIT'"

# --- Behavioral: a framework source repo self-resolves without env ---
FW=$(mktemp -d)
(
  cd "$FW"
  git init -q
  printf '6.2.0\n' > VERSION
  printf 'soul\n' > SOUL.md
  mkdir -p scripts/git-hooks
  printf '#!/bin/sh\necho "DELEGATED $*"\n' > scripts/git-hooks/pre-commit
  chmod +x scripts/git-hooks/pre-commit
  bash "$INIT" sync-hooks >/dev/null 2>&1
) >/dev/null 2>&1
assert "sync-hooks wrote a shim" "[ -f '$FW/.git/hooks/pre-commit' ]"
assert "generated shim has the walk" "grep -q '_AAS_WALK' '$FW/.git/hooks/pre-commit' 2>/dev/null"
assert "framework repo: no .aas/config project layer" "[ ! -f '$FW/.aas/config' ]"
OUT_FW=$(cd "$FW" && env -u ANOTHER_AGENT_SKILLS_DIR -u AAS_DIR bash .git/hooks/pre-commit 2>&1 || true)
assert "source repo: shim delegates (no install, no env)" "echo \"\$OUT_FW\" | grep -q 'DELEGATED'"
rm -rf "$FW"

# --- Behavioral: a plain repo without AAS is never blocked ---
PLAIN=$(mktemp -d)
(
  cd "$PLAIN"
  git init -q
  bash "$INIT" sync-hooks >/dev/null 2>&1
) >/dev/null 2>&1
# Isolate HOME too: a machine that happens to have a global AAS install must not
# make the resolver find a framework. This case simulates a teammate with none.
( cd "$PLAIN" && env -u ANOTHER_AGENT_SKILLS_DIR -u AAS_DIR HOME="$PLAIN" bash .git/hooks/pre-commit ) >/dev/null 2>&1
assert "plain repo without AAS: shim exits 0 (never blocks)" "[ $? -eq 0 ]"
rm -rf "$PLAIN"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
