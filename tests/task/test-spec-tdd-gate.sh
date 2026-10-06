#!/usr/bin/env bash
# test-spec-tdd-gate-phase13.sh — SPEC-TDD-GATE.md records the Phase 13
# (type-aware verification) redesign and the drift it fixes.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SPEC="$REPO_ROOT/development/SPEC-TDD-GATE.md"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1))
  fi
}

assert "SPEC has the Phase 13 section" "grep -q '## Phase 13 — Type-aware verification' '$SPEC'"
assert "SPEC names the drift (v1.1.0 says docs/config SKIP)" "grep -q 'The drift this fixes' '$SPEC'"
assert "SPEC has the redesign (verify by TYPE, not NAME)" "grep -q 'verify by TYPE, not by NAME' '$SPEC'"
assert "SPEC lists the docs-honesty validator" "grep -q 'docs-honesty' '$SPEC'"
assert "SPEC lists the config-consistency validator" "grep -q 'config-consistency' '$SPEC'"
assert "SPEC lists the open mechanisms" "grep -q 'Open mechanisms' '$SPEC'"
assert "SPEC points at P13.1–P13.9" "grep -q 'P13.1–P13.9' '$SPEC'"
assert "SPEC lists the docs to update (EN/ES)" "grep -q 'Docs to update (EN/ES)' '$SPEC'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
