#!/usr/bin/env bash
# test-docs-v6.sh — Verifies doc references updated from commit-msg v4/v5 to v6
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Docs v6 Reference Test Suite${NC}"
echo "──────────────────────────────────────"
assert "AGENTS.md references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/AGENTS.md'"
assert "SOUL.md references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/SOUL.md'"
assert "README.md references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/README.md'"
assert "index.html references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/index.html'"
assert "enforcement.html references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/docs/enforcement.html'"
assert "HARNESS.md references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/docs/HARNESS.md'"
assert "i18n EN references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/i18n/en.json'"
assert "i18n ES references v6" "grep -q 'commit-msg v6' '$REPO_ROOT/i18n/es.json'"
assert "PATTERNS.md no v4 refs" "! grep -q 'commit-msg v4' '$REPO_ROOT/PATTERNS.md'"
assert "README.md no override bypass" "! grep -q 'OVERRIDE: reason' '$REPO_ROOT/README.md'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
