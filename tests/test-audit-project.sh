#!/usr/bin/env bash
# test-audit-project.sh — scripts/audit-project.sh must be a RELATIVE symlink.
# It used to point at an absolute, machine-specific path — valid on the
# machine that created it, a dangling symlink on any other checkout
# (including CI, where it broke install.sh --agent claude's `cp scripts/*.sh`
# under `set -e`). See tests/test-no-absolute-symlinks.sh for the general
# sweep this specific regression motivated.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LINK="$REPO_ROOT/scripts/audit-project.sh"

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

assert "scripts/audit-project.sh is a symlink" "[ -L '$LINK' ]"
TARGET="$(readlink "$LINK")"
assert "its target is relative, not an absolute path" "[[ '$TARGET' != /* ]]"
assert "the symlink resolves to an existing, executable file" "[ -x '$LINK' ]"
assert "it points at universal-audit.sh" "[ '$TARGET' = 'universal-audit.sh' ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
