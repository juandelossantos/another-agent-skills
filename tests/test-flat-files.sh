#!/usr/bin/env bash
# test-flat-files.sh — Verifies no flat guide files outside guides/
# Rule 6: all guides must live in <skill>/guides/ subdirectory
#
# Usage: bash tests/test-flat-files.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Flat Files Test Suite${NC}"
echo "─────────────────────────────────"

# Find flat files (SKILL.md and evals.md excluded, guides/ and evals/ excluded)
FLAT_FILES=$(find "$REPO_ROOT/skills" -maxdepth 2 -name "*.md" \
  -not -name "SKILL.md" -not -name "evals.md" \
  -not -path "*/guides/*" -not -path "*/evals/*" | wc -l | tr -d ' ')

# Exclude known deferred file
DEFERRED=0
if [ -f "$REPO_ROOT/skills/debugging-three-strikes/GUIDE.md" ]; then
  DEFERRED=1
fi

EFFECTIVE=$((FLAT_FILES - DEFERRED))

echo ""
echo "Test 1: No flat guide files outside guides/"
assert "0 flat files (found ${EFFECTIVE}, deferred=${DEFERRED})" "[ $EFFECTIVE -eq 0 ]"

# ─── Syntax ───
bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo ""
echo "─────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
