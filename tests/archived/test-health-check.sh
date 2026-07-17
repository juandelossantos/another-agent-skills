#!/usr/bin/env bash
# test-health-check.sh — Validates HEALTH-CHECK.md is synced with linter
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; NC=$'\033[0m'
P=0; F=0; T=0
assert() { T=$((T+1)); if eval "$2"; then P=$((P+1)); echo -e "  ${GREEN}✓${NC} $1"; else F=$((F+1)); echo -e "  ${RED}✗${NC} $1"; fi; }
assert "HEALTH-CHECK.md exists" "[ -f '$REPO_ROOT/HEALTH-CHECK.md' ]"
assert "HEALTH-CHECK.md has status line" "grep -q 'Status.*HEALTHY\|DEGRADED\|FAILING' '$REPO_ROOT/HEALTH-CHECK.md'"
echo ""; echo "Results: $P passed, $F failed, $T total"; [ $F -eq 0 ] || exit 1
