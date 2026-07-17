#!/usr/bin/env bash
# test-pr-review-checklist.sh — Validates PR review checklist script
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKLIST_FILE="$REPO_ROOT/scripts/pr-review-checklist.sh"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; NC=$'\033[0m'
PASSED=0; FAILED=0; TOTAL=0
assert() { TOTAL=$((TOTAL+1)); if eval "$2"; then PASSED=$((PASSED+1)); echo -e "  ${GREEN}✓${NC} $1"; else FAILED=$((FAILED+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
assert "pr-review-checklist.sh exists" "[ -f '$CHECKLIST_FILE' ]"
bash -n "$CHECKLIST_FILE" 2>/dev/null && assert "Syntax valid" "true" || assert "Syntax valid" "false"
echo ""; echo "Results: $PASSED passed, $FAILED failed, $TOTAL total"; [ $FAILED -eq 0 ] || exit 1
