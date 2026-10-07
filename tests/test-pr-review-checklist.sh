#!/usr/bin/env bash
# test-pr-review-checklist.sh — B18: the PR review checklist detects code by
# TYPE, not a narrow list. Before the fix, a `.sh`-only PR was reported as
# "No code files changed" (a false OK). This extracts the real classification
# block from the script and runs it on sample paths.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
C="$REPO_ROOT/scripts/pr-review-checklist.sh"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  TOTAL=$((TOTAL + 1))
  if eval "$2"; then
    echo -e "  ${GREEN}✓${NC} $1"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $1"; FAILED=$((FAILED + 1))
  fi
}

# Extract the live classification block and run it on a given file list.
BLOCK="$(awk '/^HAS_CODE=0$/,/^done$/' "$C")"
[ -n "$BLOCK" ] || { echo "  ✗ could not extract the classification block"; exit 1; }

is_code() {  # file -> "yes" if HAS_CODE becomes 1
  local PR_FILES="$1" HAS_CODE=0 HAS_TESTS=0
  eval "$BLOCK"
  [ "$HAS_CODE" = 1 ] && echo yes || echo no
}

assert "detects .sh as code (B18)" "[ \"\$(is_code scripts/foo.sh)\" = yes ]"
assert "detects .mjs as code" "[ \"\$(is_code npm/cli.mjs)\" = yes ]"
assert "detects .rb as code" "[ \"\$(is_code lib/x.rb)\" = yes ]"
assert "detects .py as code" "[ \"\$(is_code src/x.py)\" = yes ]"
assert "detects .ts as code" "[ \"\$(is_code src/x.ts)\" = yes ]"
assert "detects .html as code" "[ \"\$(is_code docs/page.html)\" = yes ]"
assert "a .md file is NOT code" "[ \"\$(is_code docs/x.md)\" = no ]"
assert "a .json file is NOT code" "[ \"\$(is_code package.json)\" = no ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
