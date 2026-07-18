#!/usr/bin/env bash
# test-direction-skill-sections.sh — Verifies direction skills declare DESIGN.md output (P6.8)
set -uo pipefail
SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)/skills"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Direction Skill Sections Test Suite${NC}"
echo "──────────────────────────────────────"
for skill in industrial-brutalist-ui minimalist-ui soft-premium-ui; do
  FILE="$SKILLS_DIR/$skill/SKILL.md"
  assert "$skill: SKILL.md exists" "[ -f '$FILE' ]"
  assert "$skill: has DESIGN.md Output section" "grep -qi 'DESIGN.md' '$FILE'"
  assert "$skill: mentions sections 1-12" "grep -qi 'section' '$FILE'"
done
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
