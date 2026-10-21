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

# --- npm README release guard ---
GUARD="$(awk '/^check_npm_readme_release\(\)/,/^}/' "$C")"
[ -n "$GUARD" ] || { echo "  ✗ could not extract the npm README guard"; exit 1; }

GUARD_RESULTS=""
check() { GUARD_RESULTS+="$2 "; }
eval "$GUARD"
run_guard() { GUARD_RESULTS=""; check_npm_readme_release "$1"; printf '%s' "$GUARD_RESULTS"; }

R1="$(run_guard 'VERSION')"
assert "release without npm/README.md warns" "[ '$R1' = 'warn ' ]"
R2="$(run_guard $'VERSION\nnpm/README.md')"
assert "release with npm/README.md passes" "[ '$R2' = 'ok ' ]"
R3="$(run_guard 'RELEASE-NOTES.md')"
assert "RELEASE-NOTES.md triggers the guard" "[ '$R3' = 'warn ' ]"
R4="$(run_guard 'npm/package.json')"
assert "npm/package.json triggers the guard" "[ '$R4' = 'warn ' ]"
R5="$(run_guard 'README.md')"
assert "non-release change does not trigger the guard" "[ -z '$R5' ]"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
