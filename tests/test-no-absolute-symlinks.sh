#!/usr/bin/env bash
# test-no-absolute-symlinks.sh — No git-tracked symlink may point to an
# absolute path. `scripts/audit-project.sh` used to point at
# `/home/<one specific user>/.../universal-audit.sh` — valid on that one
# machine, a dangling symlink everywhere else, including CI (this is exactly
# what broke `install.sh --agent claude` in CI: `cp` failed on the dangling
# symlink, and under `set -e` the whole script aborted before wiring hooks).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

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

cd "$REPO_ROOT"
ABSOLUTE_SYMLINKS=""
while IFS= read -r -d '' path; do
  [ -L "$path" ] || continue
  target="$(readlink "$path")"
  case "$target" in
    /*) ABSOLUTE_SYMLINKS="${ABSOLUTE_SYMLINKS}${path} -> ${target}\n" ;;
  esac
done < <(git ls-files -z 2>/dev/null)

assert "no git-tracked symlink points to an absolute (machine-specific) path" "[ -z '$ABSOLUTE_SYMLINKS' ]"
[ -n "$ABSOLUTE_SYMLINKS" ] && echo -e "  Found:\n${ABSOLUTE_SYMLINKS}"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
