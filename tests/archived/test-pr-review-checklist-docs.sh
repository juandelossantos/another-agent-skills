#!/usr/bin/env bash
# test-docs-v6.sh — Verifies doc references updated from commit-msg v4/v5 to v6
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; FAIL=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else FAIL=$((FAIL+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Docs v6 Reference Test Suite${NC}"
echo "──────────────────────────────────────"
assert "README.md references v6" "grep -q 'commit-msg v6' '$ROOT/README.md'"
assert "PATTERNS.md no v4 refs" "! grep -q 'commit-msg v4' '$ROOT/PATTERNS.md'"
assert "HARNESS.md references v6" "grep -q 'commit-msg.*v6' '$ROOT/docs/HARNESS.md'"
assert "enforcement.html references v6" "grep -q 'commit-msg v6' '$ROOT/docs/enforcement.html'"
echo ""; echo "Results: $P passed, $FAIL failed, $T total"; [ $FAIL -eq 0 ] || exit 1
