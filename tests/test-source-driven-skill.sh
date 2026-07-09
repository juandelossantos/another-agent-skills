#!/usr/bin/env bash
# test-source-driven-skill.sh — Verifies source-driven-development is complete
# Task 2.8: stub (31 lines) → complete (≤150 lines, 2 guides)
#
# Usage: bash tests/test-source-driven-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="source-driven-development"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Source-Driven Development Test Suite${NC}"
echo "───────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Verification Workflow section" "grep -qi 'Workflow\|Find.*Verify\|Verify.*Implement' '$DIR/SKILL.md'"
assert "has Doc Freshness section" "grep -qi 'Freshness\|version\|changelog\|publication date' '$DIR/SKILL.md'"
assert "has API Surface section" "grep -qi 'API surface\|syntax\|signature' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 150 lines (got $LINES)" "[ $LINES -le 150 ]"

mkdir -p "$DIR/guides"
assert "guides/DOC-VERIFICATION-PATTERNS.md exists" "[ -f '$DIR/guides/DOC-VERIFICATION-PATTERNS.md' ]"
if [ -f "$DIR/guides/DOC-VERIFICATION-PATTERNS.md" ]; then
  DV=$(wc -l < "$DIR/guides/DOC-VERIFICATION-PATTERNS.md")
  assert "DOC-VERIFICATION-PATTERNS.md ≥ 50 lines (got $DV)" "[ $DV -ge 50 ]"
fi

assert "guides/FRESHNESS-CHECKS.md exists" "[ -f '$DIR/guides/FRESHNESS-CHECKS.md' ]"
if [ -f "$DIR/guides/FRESHNESS-CHECKS.md" ]; then
  FC=$(wc -l < "$DIR/guides/FRESHNESS-CHECKS.md")
  assert "FRESHNESS-CHECKS.md ≥ 50 lines (got $FC)" "[ $FC -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "───────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
