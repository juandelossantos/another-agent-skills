#!/usr/bin/env bash
# test-observability-skill.sh — Verifies observability-and-instrumentation is complete
# Task 2.2: stub (30 lines) → complete (≤250 lines, 2 guides)
#
# Usage: bash tests/test-observability-skill.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
SKILL="observability-and-instrumentation"
DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/$SKILL"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1)); fi
}

echo -e "${YELLOW}Observability Skill Test Suite${NC}"
echo "───────────────────────────────────────────"

assert "SKILL.md exists" "[ -f '$DIR/SKILL.md' ]"
assert "has Structured Logging section" "grep -q 'Structured Logging\|structured logging' '$DIR/SKILL.md'"
assert "has Metrics section" "grep -q 'RED\|Metrics' '$DIR/SKILL.md'"
assert "has Tracing section" "grep -q 'Tracing\|distributed tracing' '$DIR/SKILL.md'"
assert "has Alerting section" "grep -q 'Alerting\|alert' '$DIR/SKILL.md'"
assert "has Anti-Patterns section" "grep -q 'Anti-Pattern\|Anti-Patterns' '$DIR/SKILL.md'"
assert "has Verification section" "grep -q '## Verification' '$DIR/SKILL.md'"

LINES=$(wc -l < "$DIR/SKILL.md")
assert "SKILL.md ≤ 250 lines (got $LINES)" "[ $LINES -le 250 ]"

assert "guides/STRUCTURED-LOGGING.md exists" "[ -f '$DIR/guides/STRUCTURED-LOGGING.md' ]"
if [ -f "$DIR/guides/STRUCTURED-LOGGING.md" ]; then
  SL=$(wc -l < "$DIR/guides/STRUCTURED-LOGGING.md")
  assert "STRUCTURED-LOGGING.md ≥ 50 lines (got $SL)" "[ $SL -ge 50 ]"
fi

assert "guides/METRICS-AND-TRACING.md exists" "[ -f '$DIR/guides/METRICS-AND-TRACING.md' ]"
if [ -f "$DIR/guides/METRICS-AND-TRACING.md" ]; then
  MT=$(wc -l < "$DIR/guides/METRICS-AND-TRACING.md")
  assert "METRICS-AND-TRACING.md ≥ 50 lines (got $MT)" "[ $MT -ge 50 ]"
fi

bash -n "${BASH_SOURCE[0]}" 2>/dev/null
assert "syntax valid" "[ $? -eq 0 ]"

echo "───────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
[ "$FAILED" -gt 0 ] && exit 1 || exit 0
