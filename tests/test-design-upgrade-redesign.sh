#!/usr/bin/env bash
# test-redesign-flow.sh — Verifies design-upgrade → redesign-skill flow (P6.10)
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Redesign Flow Test Suite${NC}"
echo "──────────────────────────────────────"
assert "redesign-skill references design-upgrade" "grep -q 'design-upgrade' '$REPO_ROOT/skills/redesign-skill/SKILL.md'"
assert "design-upgrade.sh references redesign" "grep -qi 'redesign' '$REPO_ROOT/scripts/design-upgrade.sh'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
