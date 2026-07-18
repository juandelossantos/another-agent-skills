#!/usr/bin/env bash
# test-ANTI-PATTERNS.md.sh — Verifies ANTI-PATTERNS.md references commit-msg v6
set -uo pipefail
FILE="$(cd "$(dirname "$0")/.." && pwd)/ANTI-PATTERNS.md"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; NC=$'\033[0m'
P=0; FAIL=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else FAIL=$((FAIL+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}ANTI-PATTERNS Test Suite${NC}"
echo "──────────────────────────────────────"
assert "References commit-msg v6" "grep -q 'commit-msg v6' '$FILE'"
echo ""; echo "Results: $P passed, $FAIL failed, $T total"; [ $FAIL -eq 0 ] || exit 1
