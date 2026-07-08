#!/usr/bin/env bash
# test-performance-skill.sh — Verifies performance-optimization skill is complete
# Task 2.1: stub (30 lines) → complete (≤250 lines, 2 guides, workflow)
#
# Usage: bash tests/test-performance-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/performance-optimization"
SKILL_MD="$SKILL_DIR/SKILL.md"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Performance Optimization Skill Test Suite${NC}"
echo "───────────────────────────────────────────────────"

# ─── Structure ───
assert "SKILL.md exists" "[ -f '$SKILL_MD' ]"

# ─── Section headers ───
assert "has Profiling Workflow section" "grep -q '## Profiling Workflow' '$SKILL_MD'"
assert "has Core Web Vitals section" "grep -q 'Core Web Vitals' '$SKILL_MD'"
assert "has Caching Strategies section" "grep -q 'Caching' '$SKILL_MD'"
assert "has Anti-Patterns section" "grep -q 'Anti-Patterns\|Anti-Patterns' '$SKILL_MD'"
assert "has Verification section" "grep -q '## Verification' '$SKILL_MD'"

# ─── Line count (≤250) ───
LINES=$(wc -l < "$SKILL_MD")
assert "SKILL.md ≤ 250 lines (got $LINES)" "[ $LINES -le 250 ]"

# ─── Guides exist and are substantial ───
assert "guides/PROFILING-WORKFLOW.md exists" "[ -f '$SKILL_DIR/guides/PROFILING-WORKFLOW.md' ]"
if [ -f "$SKILL_DIR/guides/PROFILING-WORKFLOW.md" ]; then
  PW=$(wc -l < "$SKILL_DIR/guides/PROFILING-WORKFLOW.md")
  assert "PROFILING-WORKFLOW.md ≥ 50 lines (got $PW)" "[ $PW -ge 50 ]"
fi

assert "guides/CACHING-STRATEGIES.md exists" "[ -f '$SKILL_DIR/guides/CACHING-STRATEGIES.md' ]"
if [ -f "$SKILL_DIR/guides/CACHING-STRATEGIES.md" ]; then
  CS=$(wc -l < "$SKILL_DIR/guides/CACHING-STRATEGIES.md")
  assert "CACHING-STRATEGIES.md ≥ 50 lines (got $CS)" "[ $CS -ge 50 ]"
fi

# ─── Syntax ───
bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo ""
echo "───────────────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
