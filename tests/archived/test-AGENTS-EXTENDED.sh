#!/usr/bin/env bash
# test-AGENTS-EXTENDED.sh — Verifies AGENTS-EXTENDED.md has no override flow refs
set -uo pipefail
EXTENDED_FILE="$(cd "$(dirname "$0")/.." && pwd)/AGENTS-EXTENDED.md"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; FAIL=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else FAIL=$((FAIL+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}AGENTS-EXTENDED Test Suite${NC}"
echo "──────────────────────────────────────"
assert "No override flow section" "! grep -q 'Override flow' '$EXTENDED_FILE'"
assert "Has TDD no override" "grep -q 'no override' '$EXTENDED_FILE'"
assert "Uses v6" "grep -q 'commit-msg v6\|TDD gate' '$EXTENDED_FILE'"
echo ""; echo "Results: $P passed, $FAIL failed, $T total"; [ $FAIL -eq 0 ] || exit 1
