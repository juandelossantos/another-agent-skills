#!/usr/bin/env bash
# test-pre-commit-scoping.sh — Verifies pre-commit hook scoping (P6.9 cleanup)
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/scripts/git-hooks/pre-commit"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Pre-Commit Scoping Test Suite${NC}"
echo "──────────────────────────────────────"
assert "pre-commit hook exists" "[ -f '$FILE' ]"
assert "Skill lint scoped to changed skills" "grep -q 'while.*read.*skill_file' '$FILE'"
assert "Skill lint no longer lints all" "! grep -q 'SKILL_LINT.*skills' '$FILE'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
