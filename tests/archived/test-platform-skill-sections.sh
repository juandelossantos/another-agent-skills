#!/usr/bin/env bash
# test-platform-skill-sections.sh — Verifies platform skills declare DESIGN.md output (P6.9)
set -uo pipefail
SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)/skills"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Platform Skill Sections Test Suite${NC}"
echo "──────────────────────────────────────"
for skill in frontend-web frontend-mobile frontend-desktop frontend-pwa; do
  FILE="$SKILLS_DIR/$skill/SKILL.md"
  assert "$skill: SKILL.md exists" "[ -f '$FILE' ]"
  assert "$skill: has DESIGN.md Output section" "grep -qi 'DESIGN.md' '$FILE'"
  assert "$skill: mentions sections 13-17" "grep -q '13.*17\|platform-specific' '$FILE'"
done
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
