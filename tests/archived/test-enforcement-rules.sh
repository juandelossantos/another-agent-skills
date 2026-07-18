#!/usr/bin/env bash
# test-enforcement-rules.sh — Validates enforcement.md structure
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENF_FILE="$REPO_ROOT/rules/common/enforcement.md"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; NC=$'\033[0m'
PASSED=0; FAILED=0; TOTAL=0
assert() { TOTAL=$((TOTAL+1)); if eval "$2"; then PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} $1"; else FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
assert "enforcement.md exists" "[ -f '$ENF_FILE' ]"
assert "Has Rule 12" "grep -q 'Rule 12' '$ENF_FILE'"
assert "Has DECISION_APPROVED" "grep -q 'DECISION_APPROVED' '$ENF_FILE'"
assert "No OVERRIDE_APPROVED" "! grep -q 'OVERRIDE_APPROVED' '$ENF_FILE'"
echo ""; echo "Results: $PASSED passed, $FAILED failed, $TOTAL total"; [ $FAILED -eq 0 ] || exit 1
