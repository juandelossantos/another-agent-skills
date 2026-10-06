#!/usr/bin/env bash
# test-init-agents-shim-safety.sh — review iteration (suggestions #5/#6/#7):
#   #7 write_shim must refuse an untrusted delegate/resolver (the generated shim
#      interpolates them into an executable `exec`/source line);
#   #6 resolver_rel_for must return empty for an absolute hooks dir;
#   #5 an absolute core.hooksPath must warn that the hooks go outside the project.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"

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

# --- Static guards ---
assert "write_shim refuses an untrusted delegate/resolver" \
  "grep -q 'refusing untrusted delegate' '$INIT'"
assert "resolver_rel_for handles an absolute dir (empty)" \
  "awk '/^resolver_rel_for\(\)/,/^}/' '$INIT' | grep -q '/\*)'"
assert "install_hook_shims warns on an absolute core.hooksPath" \
  "grep -q 'go OUTSIDE this project' '$INIT'"

# --- Behavioral: absolute core.hooksPath outside the project ---
T="$(mktemp -d)"
ABSDIR="$(mktemp -d)"
( cd "$T" && git init -q && git config user.email t@t.t && git config user.name t \
  && echo a > a.txt && git add a.txt && git commit -qm init \
  && git config core.hooksPath "$ABSDIR" \
  && AAS_DIR="$REPO_ROOT" bash "$INIT" > out.log 2>&1 )
assert "absolute hooksPath: warns it goes outside the project" "grep -qi 'outside this project' '$T/out.log'"
assert "absolute hooksPath: installs the shim in that dir" "[ -f '$ABSDIR/pre-commit' ]"
assert "absolute hooksPath: shim has NO relative project resolver" \
  "! grep -q 'aas-resolve.sh' '$ABSDIR/pre-commit' 2>/dev/null"
assert "absolute hooksPath: shim is still a portable shim (walks up)" \
  "grep -q '_AAS_WALK' '$ABSDIR/pre-commit' 2>/dev/null"
rm -rf "$T" "$ABSDIR"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
