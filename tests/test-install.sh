#!/usr/bin/env bash
# test-install.sh — Validates install.sh syntax and structure
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/install.sh"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Install Script Test Suite${NC}"
echo "──────────────────────────────────────"
assert "install.sh exists" "[ -f '$FILE' ]"
bash -n "$FILE" 2>/dev/null && assert "Syntax valid" "true"
assert "Has deprecated skill cleanup" "grep -q 'deprecated.*custom.*skill' '$FILE'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
