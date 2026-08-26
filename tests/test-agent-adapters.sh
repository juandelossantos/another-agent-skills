#!/usr/bin/env bash
# test-agent-adapters.sh — Content checks for docs/AGENT-ADAPTERS.md: the
# manual-JSON-wiring instructions are gone, replaced with the automatic
# hook-wiring documentation that matches what install.sh now actually does.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="$REPO_ROOT/docs/AGENT-ADAPTERS.md"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

assert "no longer instructs manual settings.json wiring as the primary path" "! grep -q 'wire the hooks manually via' '$FILE'"
assert "documents hooks as wired automatically" "grep -qi 'wired automatically' '$FILE'"
assert "documents the jq-based idempotent merge" "grep -q 'idempotent' '$FILE'"
assert "Claude Code compatibility row says auto-wired" "grep -q 'Bash (auto-wired)' '$FILE'"
assert "still documents the plugin-structure known limitation" "grep -q 'Known limitation' '$FILE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
