#!/usr/bin/env bash
# test-customize-opencode-skill.sh — Verifies customize-opencode is complete
# Task 2.12: stub (34 lines) → complete (≤120 lines, 2 guides)
#
# Usage: bash tests/test-customize-opencode-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="customize-opencode"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Customize OpenCode Test Suite${NC}"
echo "─────────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has config workflow or process" "grep -qi 'phase\|step\|workflow\|assess\|edit\|validate' '$DIR/SKILL.md'"
assert "mentions opencode.json schema" "grep -qi 'opencode\.json\|config.*schema\|permission\|mcp' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 120 lines (got $LINES)" "[ $LINES -le 120 ]"

mkdir -p "$DIR/guides"
assert "guides/CONFIG-SCHEMA.md exists" "[ -f '$DIR/guides/CONFIG-SCHEMA.md' ]"
if [ -f "$DIR/guides/CONFIG-SCHEMA.md" ]; then
  CS=$(wc -l < "$DIR/guides/CONFIG-SCHEMA.md")
  assert "CONFIG-SCHEMA.md ≥ 50 lines (got $CS)" "[ $CS -ge 50 ]"
fi

assert "guides/PLUGIN-PATTERNS.md exists" "[ -f '$DIR/guides/PLUGIN-PATTERNS.md' ]"
if [ -f "$DIR/guides/PLUGIN-PATTERNS.md" ]; then
  PP=$(wc -l < "$DIR/guides/PLUGIN-PATTERNS.md")
  assert "PLUGIN-PATTERNS.md ≥ 50 lines (got $PP)" "[ $PP -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "─────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
