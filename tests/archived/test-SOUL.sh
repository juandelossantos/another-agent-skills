#!/usr/bin/env bash
# test-SOUL.sh — Verifies SOUL.md references current commit-msg version
set -uo pipefail
SOUL_FILE="$(cd "$(dirname "$0")/.." && pwd)/SOUL.md"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; FAIL=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else FAIL=$((FAIL+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}SOUL Test Suite${NC}"
echo "──────────────────────────────────────"
assert "References commit-msg v6" "grep -q 'commit-msg v6' '$SOUL_FILE'"
echo ""; echo "Results: $P passed, $FAIL failed, $T total"; [ $FAIL -eq 0 ] || exit 1
