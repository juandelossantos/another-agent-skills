#!/usr/bin/env bash
# test-critique-visual-dimensions.sh — Verifies critique-skill has visual design pass (P6.11)
set -uo pipefail
FILE="$(cd "$(dirname "$0")/.." && pwd)/skills/critique-skill/SKILL.md"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Critique Visual Dimensions Test Suite${NC}"
echo "──────────────────────────────────────"
assert "critique-skill exists" "[ -f '$FILE' ]"
assert "Has visual design pass" "grep -qi 'visual design' '$FILE'"
assert "Has color harmony dimension" "grep -qi 'color harmony' '$FILE'"
assert "Has typographic craft dimension" "grep -qi 'typographic' '$FILE'"
assert "Has visual hierarchy dimension" "grep -qi 'visual hierarchy' '$FILE'"
assert "Has spatial accuracy dimension" "grep -qi 'spatial' '$FILE'"
assert "Has mood/tone dimension" "grep -qi 'mood.*tone\|tone.*mood' '$FILE'"
assert "Dimensions marked as felt" "grep -qi 'felt\|human review\|flag' '$FILE'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
