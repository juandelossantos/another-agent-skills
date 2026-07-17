#!/usr/bin/env bash
# test-SKILL.sh — Validates engineering-fundamentals SKILL.md structure
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_FILE="$REPO_ROOT/skills/engineering-fundamentals/SKILL.md"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; NC=$'\033[0m'
PASSED=0; FAILED=0; TOTAL=0
assert() { TOTAL=$((TOTAL+1)); if eval "$2"; then PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} $1"; else FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
assert "SKILL.md exists" "[ -f '$SKILL_FILE' ]"
assert "References DESIGN-MD-SCHEMA" "grep -q 'DESIGN-MD-SCHEMA' '$SKILL_FILE'"
assert "Has Phase 2B" "grep -q '2B' '$SKILL_FILE'"
echo ""; echo "Results: $PASSED passed, $FAILED failed, $TOTAL total"; [ $FAILED -eq 0 ] || exit 1
