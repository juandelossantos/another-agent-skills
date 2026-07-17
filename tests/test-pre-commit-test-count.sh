#!/usr/bin/env bash
# test-pre-commit-test-count.sh — Validates pre-commit test count gate (max 11 tests)
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_FILE="$REPO_ROOT/scripts/git-hooks/pre-commit"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
assert "pre-commit hook exists" "[ -f '$HOOK_FILE' ]"
assert "Has test count gate" "grep -q 'TEST COUNT' '$HOOK_FILE'"
assert "Max tests is 11" "grep -q 'MAX_TESTS=11' '$HOOK_FILE'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
