#!/usr/bin/env bash
# test-tdd-gate-skill-skip.sh — Verifies SKILL.md is skipped by TDD gate
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$REPO_ROOT/scripts/tdd-gate.sh"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }

setup() {
  local d="$REPO_ROOT/.tdd_skill_$$_$1"
  mkdir -p "$d" && git init -q -b t "$d" 2>/dev/null
  git -C "$d" config user.email "t@t.com" 2>/dev/null
  git -C "$d" config user.name "T" 2>/dev/null
  echo "$d"
}
cleanup() { rm -rf "$REPO_ROOT"/.tdd_skill_*_$$ 2>/dev/null; }
trap cleanup EXIT

echo -e "${YELLOW}TDD Gate Skill Skip Test Suite${NC}"
echo "──────────────────────────────────────"

# Test: SKILL.md staged without test → should PASS (skipped)
echo ""
echo "Test 1: SKILL.md staged alone (expect PASS — skip pattern)"
D1=$(setup "1")
touch "$D1/SKILL.md"
git -C "$D1" add SKILL.md
(cd "$D1" && bash "$GATE" > /dev/null 2>&1)
assert "SKILL.md alone → PASS" "[ $? -eq 0 ]"

# Test: SKILL.md + code file → should BLOCK (code needs test)
echo ""
echo "Test 2: SKILL.md + code file (expect BLOCK — code needs test)"
D2=$(setup "2")
touch "$D2/SKILL.md" "$D2/app.js"
git -C "$D2" add .
(cd "$D2" && bash "$GATE" > /dev/null 2>&1)
assert "SKILL.md + code → BLOCK" "[ $? -eq 1 ]"

echo ""
echo "──────────────────────────────────────"
echo -e "Results: ${GREEN}$P passed${NC}, ${RED}$F failed${NC}, $T total"
echo ""
[ $F -eq 0 ] || exit 1
