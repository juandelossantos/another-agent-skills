#!/usr/bin/env bash
# test-stack-config-cmd.sh — B12: the STACK_CONFIG.md command reader resolves the
# EXACT `| <field> |` row (else the FIRST `| <field> … |` row), strips backticks,
# and never returns a non-command. Regression: the old pre-commit parser
# (`grep -A1 '^| Test' | tail -1`) returned the line AFTER the last Test row
# (lint) → the gate ran lint and reported "All tests passed" → a FALSE PASS.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CMD="$REPO_ROOT/scripts/stack-config-cmd.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

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
get() { bash "$CMD" "$1" "$2" 2>/dev/null; }

# ── Exact `| <field> |` row ──
cat > "$TMP/exact.md" <<'EOF'
| Action | Command |
|---|---|
| Test | `npm test` |
| Lint | `npm run lint` |
EOF
assert "exact | Test | row → npm test" "[ \"\$(get Test '$TMP/exact.md')\" = 'npm test' ]"
assert "exact | Lint | row → npm run lint" "[ \"\$(get Lint '$TMP/exact.md')\" = 'npm run lint' ]"

# ── Multi-row (courtside-like): first Test row wins, NOT lint ──
cat > "$TMP/multi.md" <<'EOF'
| Action | Command |
|---|---|
| Test (all) | `npm test` |
| Test (shared) | `npm run test --workspace packages/shared` |
| Test (server) | `npm run test --workspace packages/server` |
| Lint | `npm run lint` |
EOF
assert "multi-row: first Test row (Test (all)) → npm test" "[ \"\$(get Test '$TMP/multi.md')\" = 'npm test' ]"
assert "multi-row: NOT lint (the old false-PASS bug)" "[ \"\$(get Test '$TMP/multi.md')\" != 'npm run lint' ]"

# ── Backticks stripped; no backticks → raw cell ──
cat > "$TMP/nobt.md" <<'EOF'
| Action | Command |
|---|---|
| Test | npm test |
EOF
assert "no backticks → raw cell" "[ \"\$(get Test '$TMP/nobt.md')\" = 'npm test' ]"

# ── `<configure: …>` placeholder → empty ──
cat > "$TMP/cfg.md" <<'EOF'
| Action | Command |
|---|---|
| Test | `<configure: your test command>` |
EOF
assert "placeholder → empty" "[ -z \"\$(get Test '$TMP/cfg.md')\" ]"

# ── Absent field / file → empty ──
assert "absent field → empty" "[ -z \"\$(get Build '$TMP/exact.md')\" ]"
assert "missing file → empty" "[ -z \"\$(get Test '$TMP/nope.md')\" ]"

# ── Single source + parity (gates.yml mirrors it; it runs in CI w/o the framework) ──
assert "pre-commit uses the single source" "grep -qF 'stack-config-cmd.sh' '$REPO_ROOT/scripts/git-hooks/pre-commit'"
assert "gates.yml mirrors the parser (read_cmd)" "grep -q 'read_cmd()' '$REPO_ROOT/templates/gates.yml'"
assert "gates.yml has the first-row fallback" "grep -qF 'field}[[:space:]]' '$REPO_ROOT/templates/gates.yml'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
