#!/usr/bin/env bash
# test-init-agents-hookspath.sh — B5 regression: init-agents must install the
# portable hook shims where git ACTUALLY runs them. When `core.hooksPath` is set
# (husky/lefthook/custom), `.git/hooks/*` is ignored by git, so the shims must
# land in the effective dir (husky: `.husky/`), and --check-env must report it.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

mkfixture() {
  local d; d="$(mktemp -d)"
  ( cd "$d" && git init -q && git config user.email t@t.t && git config user.name t \
    && echo a > a.txt && git add a.txt && git commit -qm init ) >/dev/null 2>&1
  printf '%s' "$d"
}

# --- Static: the script knows about core.hooksPath ---
assert "init-agents defines effective_hooks_dir()" "grep -q 'effective_hooks_dir()' '$INIT'"
assert "init-agents reads core.hooksPath" "grep -q 'core.hooksPath' '$INIT'"
assert "init-agents detects husky (.husky/_)" "grep -q 'husky/_)' '$INIT'"

# ── Case 1: husky (core.hooksPath=.husky/_) — the real courtside case ──
H="$(mkfixture)"
( cd "$H" && mkdir -p .husky/_ && git config core.hooksPath .husky/_ \
  && AAS_DIR="$REPO_ROOT" bash "$INIT" > out.log 2>&1 )
assert "husky: warns about core.hooksPath" "grep -qi 'core.hooksPath' '$H/out.log'"
assert "husky: installs .husky/pre-commit (effective dir)" "[ -f '$H/.husky/pre-commit' ]"
assert "husky: installs .husky/commit-msg" "[ -f '$H/.husky/commit-msg' ]"
assert "husky: pre-commit is a portable shim (walks up)" "grep -q '_AAS_WALK' '$H/.husky/pre-commit' 2>/dev/null"
assert "husky: shim resolver path is depth-1 (../.aas/...)" "grep -qF '../.aas/aas-resolve.sh' '$H/.husky/pre-commit' 2>/dev/null"
assert "husky: shim is executable" "[ -x '$H/.husky/pre-commit' ]"
# The shim must run cleanly (husky executes it with `sh -e`) and never block a
# machine without AAS (clean env, no `aas`, no framework install under HOME).
assert "husky: shim runs and exits 0 without AAS (never blocks)" \
  "( cd '$H' && env -i PATH=/usr/bin:/bin HOME='$H' sh -e .husky/pre-commit ) >/dev/null 2>&1"
# --check-env reports the effective dir + the active hooks.
CE="$(cd "$H" && AAS_DIR="$REPO_ROOT" bash "$INIT" --check-env 2>/dev/null)"
assert "check-env: reports core.hooksPath value" "printf '%s' \"\$CE\" | grep -q 'hooks-path=.husky/_'"
assert "check-env: pre-commit active in the effective dir" "printf '%s' \"\$CE\" | grep -qF 'hook-pre-commit=./.husky/pre-commit (active)'"
rm -rf "$H"

# ── Case 2: no core.hooksPath → default .git/hooks (unchanged behavior) ──
D="$(mkfixture)"
( cd "$D" && AAS_DIR="$REPO_ROOT" bash "$INIT" > out.log 2>&1 )
assert "default: installs .git/hooks/pre-commit" "[ -f '$D/.git/hooks/pre-commit' ]"
assert "default: shim resolver path is depth-2 (../../.aas/...)" "grep -qF '../../.aas/aas-resolve.sh' '$D/.git/hooks/pre-commit' 2>/dev/null"
CE2="$(cd "$D" && AAS_DIR="$REPO_ROOT" bash "$INIT" --check-env 2>/dev/null)"
assert "default: check-env reports (default .git/hooks)" "printf '%s' \"\$CE2\" | grep -qF 'hooks-path=(default .git/hooks)'"
assert "default: check-env reports the active pre-commit" "printf '%s' \"\$CE2\" | grep -qF 'hook-pre-commit=./.git/hooks/pre-commit (active)'"
rm -rf "$D"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
