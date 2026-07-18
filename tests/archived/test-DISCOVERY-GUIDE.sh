#!/usr/bin/env bash
# test-design-discovery.sh — Validates discovery produces design-discovery.md artifact (P6.6)
set -uo pipefail
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)/skills/engineering-fundamentals"
GUIDE="$SKILL_DIR/guides/DISCOVERY-GUIDE.md"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Design Discovery Test Suite${NC}"
echo "──────────────────────────────────────"
assert "DISCOVERY-GUIDE.md exists" "[ -f '$GUIDE' ]"
assert "Discovery writes design-discovery.md" "grep -q 'design-discovery' '$GUIDE'"
assert "Discovery has template fields" "grep -qi 'Three Dials\|Intent\|Direction\|Approval' '$GUIDE'"
assert "Template has user approval step" "grep -qi 'User Approval\|confirmed' '$GUIDE'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
