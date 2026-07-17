#!/usr/bin/env bash
# test-design-md-schema.sh — Validates DESIGN-MD-SCHEMA.md has all 17 sections
# Each task that creates or modifies the schema must extend this test.
#
# Usage: bash tests/test-design-md-schema.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMA="$REPO_ROOT/skills/engineering-fundamentals/guides/DESIGN-MD-SCHEMA.md"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Design MD Schema Test Suite${NC}"
echo "─────────────────────────────────────────"

# Test 1: File exists
assert "DESIGN-MD-SCHEMA.md exists" "[ -f '$SCHEMA' ]"

# Test 2: All 17 sections documented (## Section N: format)
SECTION_COUNT=$(grep -c '^## Section' "$SCHEMA" 2>/dev/null || echo 0)
assert "All 17 sections documented (found $SECTION_COUNT)" "[ $SECTION_COUNT -eq 17 ]"

# Test 3: Each section has required fields table (sections 1-12 use "Required", 13-17 use "Filled By")
BOTH=$(grep -cE '\| Field \| (Required|Filled By)' "$SCHEMA" 2>/dev/null || echo 0)
assert "All 17 sections have required/filled-by fields (found $BOTH)" "[ $BOTH -eq 17 ]"

# Test 4: Checkable/felt split documented
assert "Checkable validation mentioned" "grep -qi 'checkable' '$SCHEMA'"
assert "Felt review mentioned" "grep -qi 'felt' '$SCHEMA'"

# Test 5: Universal vs Platform-Specific split documented
assert "Universal sections labeled" "grep -qi 'universal' '$SCHEMA'"
assert "Platform-Specific sections labeled" "grep -qi 'platform-specific' '$SCHEMA'"

# Test 6: Direction skill mappings exist
assert "industrial-brutalist-ui mapped" "grep -qi 'industrial-brutalist-ui' '$SCHEMA'"
assert "minimalist-ui mapped" "grep -qi 'minimalist-ui' '$SCHEMA'"
assert "soft-premium-ui mapped" "grep -qi 'soft-premium-ui' '$SCHEMA'"

# Test 7: Platform skill mappings exist
assert "frontend-web mapped" "grep -qi 'frontend-web' '$SCHEMA'"
assert "frontend-mobile mapped" "grep -qi 'frontend-mobile' '$SCHEMA'"
assert "frontend-desktop mapped" "grep -qi 'frontend-desktop' '$SCHEMA'"
assert "frontend-pwa mapped" "grep -qi 'frontend-pwa' '$SCHEMA'"

# Test 8: engineering-fundamentals SKILL.md references the schema
SKILL="$REPO_ROOT/skills/engineering-fundamentals/SKILL.md"
assert "SKILL.md references DESIGN-MD-SCHEMA" "grep -q 'DESIGN-MD-SCHEMA' '$SKILL'"

# Test 9: At least 10 sections are checkable (automated block)
BLOCK_COUNT=$(grep -c 'Block if' "$SCHEMA" 2>/dev/null || echo 0)
assert "At least 10 sections have block conditions (found $BLOCK_COUNT)" "[ $BLOCK_COUNT -ge 10 ]"

echo ""
echo "─────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
