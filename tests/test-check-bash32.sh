#!/usr/bin/env bash
# test-check-bash32.sh — the bash 3.2 guard is mechanical, and the repo passes it.
#
# Stock macOS ships bash 3.2; a bash 4-only construct that works on Linux CI is
# a crash on a real Mac. scripts/check-bash32.sh is the guard; this suite proves
# it flags each construct and does not flag the portability fixes it protects.
#
# Regression origin: `aas install --agents auto` died with
# `args[@]: unbound variable` (empty array under `set -u`), and tdd-gate used
# `${var,,}` — both invisible on bash 5.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCANNER="$REPO_ROOT/scripts/check-bash32.sh"

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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Fixture repo: the scanner only reads the fixed runtime surface under --root.
fixture() {  # name, body
  local dir="$TMP/$1"
  mkdir -p "$dir/scripts" "$dir/bin"
  printf '%s\n' '#!/usr/bin/env bash' "$2" > "$dir/scripts/candidate.sh"
  echo "$dir"
}

echo ""
echo "bash 3.2 compatibility guard"
echo "─────────────────────────────"

echo ""
echo "Group 1 — the guard exists and the framework passes"
assert "check-bash32.sh exists" "[ -f '$SCANNER' ]"
assert "check-bash32.sh is executable" "[ -x '$SCANNER' ]"
assert "framework runtime scripts pass the guard" "bash '$SCANNER' --root '$REPO_ROOT' >/dev/null 2>&1"

echo ""
echo "Group 2 — bash 4 constructs are rejected"
D="$(fixture caseconv 'x=ABC; echo "${x,,}"')"
assert "rejects \${var,,} case conversion" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture assoc 'declare -A map')"
assert "rejects declare -A" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture mapfile 'mapfile -t lines < file')"
assert "rejects mapfile" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture append 'echo hi &>> log')"
assert "rejects &>>" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture comment '# ${x,,} only in a comment')"
assert "allows a comment that names the syntax" "bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture clean 'echo ok')"
assert "allows bash 3.2 code" "bash '$SCANNER' --root '$D' >/dev/null 2>&1"

echo ""
echo "Group 3 — the portability fixes it protects"
TDD_CASE_CODE="$(grep -E '^[^#]*\$\{[a-z_]+,,}' "$REPO_ROOT/scripts/tdd-gate.sh" | wc -l | tr -d ' ')"
assert "tdd-gate has no \${var,,} in code" "[ '$TDD_CASE_CODE' = '0' ]"
assert "tdd-gate lowercases portably" "grep -q 'lower() {' '$REPO_ROOT/scripts/tdd-gate.sh'"
AAS_ARGS_GUARD="$(grep -cF 'args[@]+' "$REPO_ROOT/bin/aas" | tr -d ' ')"
assert "bin/aas guards the empty args array" "[ '$AAS_ARGS_GUARD' -ge 1 ]"
LIB_GUARD="$(grep -cF '${#files[@]}' "$REPO_ROOT/scripts/lib/aas.sh" | tr -d ' ')"
assert "aas_remove_path bails out on an empty array" "[ '$LIB_GUARD' -ge 1 ]"
assert "scripts/eval is exempt (maintainer tooling)" "grep -rq 'declare -A' '$REPO_ROOT/scripts/eval'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
