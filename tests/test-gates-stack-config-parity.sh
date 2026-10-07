#!/usr/bin/env bash
# test-gates-stack-config-parity.sh — B12 iteration: templates/gates.yml's
# read_cmd() must behave EXACTLY like the single source scripts/stack-config-cmd.sh
# on the resolution cases (exact row, first row, backticks, no-backtick fallback).
# gates.yml runs in CI WITHOUT the framework, so it MIRRORS the parser — this
# test catches any future drift between the mirror and the source.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CMD="$REPO_ROOT/scripts/stack-config-cmd.sh"
TEMPLATE="$REPO_ROOT/templates/gates.yml"
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

# Fixtures
cat > "$TMP/exact.md" <<'EOF'
| Action | Command |
|---|---|
| Test | `npm test` |
| Lint | `npm run lint` |
EOF
cat > "$TMP/multi.md" <<'EOF'
| Action | Command |
|---|---|
| Test (all) | `npm test` |
| Lint | `npm run lint` |
EOF
cat > "$TMP/nobt.md" <<'EOF'
| Action | Command |
|---|---|
| Test | npm test |
EOF

# Extract the read_cmd() function from the YAML run-block.
sed -n '/^          read_cmd() {$/,/^          }$/p' "$TEMPLATE" | sed 's/^          //' > "$TMP/read_cmd.sh"
assert "extracted the gates.yml read_cmd() function" "grep -q 'read_cmd() {' '$TMP/read_cmd.sh' && [ \"\$(wc -l < '$TMP/read_cmd.sh')\" -ge 6 ]"

for f in exact multi nobt; do
  d="$TMP/gate-$f"; mkdir -p "$d"; cp "$TMP/$f.md" "$d/STACK_CONFIG.md"
  got="$( cd "$d" && . "$TMP/read_cmd.sh" && read_cmd Test )"
  want="$( bash "$CMD" Test "$TMP/$f.md" )"
  assert "parity ($f): gates.yml read_cmd == script" "[ \"\$got\" = \"\$want\" ]"
done

# The `<configure: …>` placeholder is filtered SEPARATELY in the workflow step.
assert "gates.yml still filters the <configure:> placeholder" "grep -qF '\"<configure:\"' '$TEMPLATE'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
