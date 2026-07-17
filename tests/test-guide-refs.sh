#!/usr/bin/env bash
# test-guide-refs.sh — Verifies consolidates guide files have correct SKILL.md refs
# Proves the fix: moved files are discoverable via updated SKILL.md references
#
# Usage: bash tests/test-guide-refs.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${GREEN}Guide Reference Resolution Test${NC}"
echo "─────────────────────────────────────────"

# Test the 5 SKILL.md references we updated
assert "cli-tools → guides/ANTI-SLOP-GUIDE.md" "grep -q 'guides/ANTI-SLOP-GUIDE' skills/cli-tools/SKILL.md"
assert "cli-tools → guides/LANGUAGE-GUIDE.md" "grep -q 'guides/LANGUAGE-GUIDE' skills/cli-tools/SKILL.md"
assert "engineering-fundamentals → guides/PLATFORM-SKILL-TEMPLATE" "grep -q 'guides/PLATFORM-SKILL-TEMPLATE' skills/engineering-fundamentals/SKILL.md"
assert "engineering-fundamentals → guides/DESIGN-MD-SCHEMA" "grep -q 'guides/DESIGN-MD-SCHEMA' skills/engineering-fundamentals/SKILL.md"
assert "multi-agent-orchestration → guides/GUIDE.md" "grep -q 'guides/GUIDE.md' skills/multi-agent-orchestration/SKILL.md"
assert "spec-driven-development → multi-agent-orchestration/guides/GUIDE.md" "grep -q 'guides/GUIDE.md' skills/spec-driven-development/SKILL.md"

# Test the moved files actually exist in guides/
assert "BREAKPOINT-GUIDE.md in guides/" "[ -f skills/adapt-skill/guides/BREAKPOINT-GUIDE.md ]"
assert "TOUCH-GUIDE.md in guides/" "[ -f skills/adapt-skill/guides/TOUCH-GUIDE.md ]"
assert "ANTI-SLOP-GUIDE.md in guides/" "[ -f skills/cli-tools/guides/ANTI-SLOP-GUIDE.md ]"
assert "LANGUAGE-GUIDE.md in guides/" "[ -f skills/cli-tools/guides/LANGUAGE-GUIDE.md ]"
assert "memory.md in guides/" "[ -f skills/debugging-and-error-recovery/guides/memory.md ]"
assert "AESTHETIC-DIRECTIONS.md in guides/" "[ -f skills/engineering-fundamentals/guides/AESTHETIC-DIRECTIONS.md ]"
assert "PLATFORM-SKILL-TEMPLATE.md in guides/" "[ -f skills/engineering-fundamentals/guides/PLATFORM-SKILL-TEMPLATE.md ]"
assert "DESIGN-MD-SCHEMA.md in guides/" "[ -f skills/engineering-fundamentals/guides/DESIGN-MD-SCHEMA.md ]"
assert "DISCOVERY-GUIDE.md in guides/" "[ -f skills/engineering-fundamentals/guides/DISCOVERY-GUIDE.md ]"
assert "GUIDE.md in guides/" "[ -f skills/multi-agent-orchestration/guides/GUIDE.md ]"
assert "BOTTLENECK-GUIDE.md in guides/" "[ -f skills/optimize-skill/guides/BOTTLENECK-GUIDE.md ]"
assert "SPACING-GUIDE.md in guides/" "[ -f skills/polish-skill/guides/SPACING-GUIDE.md ]"

# Test 0 flat files outside guides/
FLAT=$(find skills/ -maxdepth 2 -name "*.md" -not -name "SKILL.md" -not -name "evals.md" \
  -not -path "*/guides/*" -not -path "*/evals/*" | grep -v "debugging-three-strikes" | wc -l | tr -d ' ')
assert "0 flat files outside guides/ (found $FLAT)" "[ $FLAT -eq 0 ]"

echo ""
echo "─────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
