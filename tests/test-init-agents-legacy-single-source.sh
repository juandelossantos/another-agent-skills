#!/usr/bin/env bash
# test-init-agents-legacy-single-source.sh — review regression: the legacy
# reference lists (docs + scripts) must have a SINGLE source of truth, shared by
# repair_legacy, install_legacy_equivalents and run_dry_run, so they cannot drift
# (the same class of bug the B7 classifier lesson warns about: a list copied
# across call sites gets updated in one place and forgotten in another).
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"

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

# --- Single source of truth exists ---
assert "defines AAS_LEGACY_DOCS" "grep -q 'AAS_LEGACY_DOCS=' '$INIT'"
assert "defines AAS_LEGACY_SCRIPTS" "grep -q 'AAS_LEGACY_SCRIPTS=' '$INIT'"

# The literal script list must appear exactly once (in the constant) — not
# re-typed in repair_legacy / install_legacy_equivalents / run_dry_run.
assert "legacy script list literal appears exactly once" \
  "[ \"\$(grep -c 'skill-gate.sh edit-guard.sh task-manifest.sh' '$INIT')\" -eq 1 ]"

# --- Every consumer references the constants, not a re-typed list ---
assert "repair_legacy uses AAS_LEGACY_SCRIPTS" \
  "awk '/^repair_legacy\(\)/,/^}/' '$INIT' | grep -q 'AAS_LEGACY_SCRIPTS'"
assert "repair_legacy uses AAS_LEGACY_DOCS" \
  "awk '/^repair_legacy\(\)/,/^}/' '$INIT' | grep -q 'AAS_LEGACY_DOCS'"
assert "install_legacy_equivalents uses AAS_LEGACY_SCRIPTS" \
  "awk '/^install_legacy_equivalents\(\)/,/^}/' '$INIT' | grep -q 'AAS_LEGACY_SCRIPTS'"
assert "install_legacy_equivalents uses AAS_LEGACY_DOCS" \
  "awk '/^install_legacy_equivalents\(\)/,/^}/' '$INIT' | grep -q 'AAS_LEGACY_DOCS'"
assert "run_dry_run uses AAS_LEGACY_SCRIPTS" \
  "awk '/^run_dry_run\(\)/,/^}/' '$INIT' | grep -q 'AAS_LEGACY_SCRIPTS'"
assert "run_dry_run uses AAS_LEGACY_DOCS" \
  "awk '/^run_dry_run\(\)/,/^}/' '$INIT' | grep -q 'AAS_LEGACY_DOCS'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
