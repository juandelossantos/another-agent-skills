#!/usr/bin/env bash
# test-tdd-gate-skip.sh — Verifies SKILL.md and basename skip patterns work
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$REPO_ROOT/scripts/tdd-gate.sh"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
setup() { local d="$REPO_ROOT/.tdd_skip_$$_$1"; mkdir -p "$d" && git init -q -b t "$d" 2>/dev/null; git -C "$d" config user.email "t@t.com"; git -C "$d" config user.name "T"; echo "$d"; }
cleanup() { rm -rf "$REPO_ROOT"/.tdd_skip_*_$$ 2>/dev/null; }
trap cleanup EXIT
echo -e "${YELLOW}TDD Gate Skip Pattern Test Suite${NC}"
echo "──────────────────────────────────────"
echo ""
echo "Test 1: Subdirectory SKILL.md"
D1=$(setup "1"); mkdir -p "$D1/skills/test"; touch "$D1/skills/test/SKILL.md"
git -C "$D1" add .; (cd "$D1" && bash "$GATE" > /dev/null 2>&1)
assert "SKILL.md in subdirectory → skipped" "[ $? -eq 0 ]"
echo ""
echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
