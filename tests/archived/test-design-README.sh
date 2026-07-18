#!/usr/bin/env bash
# test-design-dir-rules.sh — Validates design/ directory rules (P6.5)
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
echo -e "${YELLOW}Design Dir Rules Test Suite${NC}"
echo "──────────────────────────────────────"
assert "design/prototype/ in .gitignore" "grep -q 'design/prototype' '$REPO_ROOT/.gitignore'"
assert "design/README.md exists" "[ -f '$REPO_ROOT/design/README.md' ]"
assert "README documents prototype role" "grep -qi 'prototype' '$REPO_ROOT/design/README.md'"
assert "README documents approved role" "grep -qi 'approved' '$REPO_ROOT/design/README.md'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
