#!/usr/bin/env bash
# test-validate-health-check.sh — Gate 11's validator parses the linter summary
# and HEALTH-CHECK.md without GNU-only syntax.
#
# Regression origin: every extraction used `grep -oP` (PCRE). BSD/macOS grep has
# no -P, the pipelines failed silently, HC_WARNINGS/HC_OVERALL fell back to
# "unknown", and the check could never pass on a Mac regardless of the file.
#
# The suite runs the real validator against a hermetic project (a stub
# scripts/skill-lint.sh) and asserts PASS and both FAIL directions.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VALIDATE="$REPO_ROOT/scripts/validate-health-check.sh"

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

# A hermetic project: the validator runs `bash scripts/skill-lint.sh` from CWD.
make_project() {  # dir, linter line, errors, warnings, overall
  local dir="$1"
  mkdir -p "$dir/scripts"
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "%s"\n' "$2" > "$dir/scripts/skill-lint.sh"
  cat > "$dir/HEALTH-CHECK.md" <<EOF
# Health Check

| Check | Value |
|---|---|
| Errors (Check 14) | **$3** (guide violations) |
| Warnings | **$4** |
| Overall | **$5** |
EOF
}

run_project() {  # dir -> "rc<TAB>output"
  ( cd "$1" && bash "$VALIDATE" 2>&1 ); echo "RC=$?"
}

echo ""
echo "Gate 11 validator — portable parsing (macOS/BSD)"
echo "───────────────────────────────────────────────"

echo ""
echo "Group 1 — the script is portable"
assert "validator exists" "[ -f '$VALIDATE' ]"
assert "no grep -P in the validator" "! grep -E 'grep -[a-zA-Z]*P' '$VALIDATE' | grep -vE '^[[:space:]]*#' | grep -q ."
assert "validator is POSIX sh" "sh -n '$VALIDATE' >/dev/null 2>&1"

echo ""
echo "Group 2 — matching state passes"
P="$TMP/pass"; make_project "$P" "0 errors, 2 warning(s)" 0 2 "🟡 DEGRADED"
OUT="$(cd "$P" && bash "$VALIDATE" 2>&1)"; RC=$?
assert "matching HEALTH-CHECK.md exits 0" "[ '$RC' = '0' ]"
assert "reports PASS" "printf '%s' \"\$OUT\" | grep -q 'PASS'"
assert "parses the linter summary (0 errors, 2 warnings)" "printf '%s' \"\$OUT\" | grep -q 'Linter: 0 errors, 2 warnings'"
assert "parses the health values (no 'unknown')" "printf '%s' \"\$OUT\" | grep -q 'errors=0, warnings=2, status=DEGRADED'"

echo ""
echo "Group 3 — drift fails in both directions"
P="$TMP/warn"; make_project "$P" "0 errors, 5 warning(s)" 0 2 "🟡 DEGRADED"
OUT="$(cd "$P" && bash "$VALIDATE" 2>&1)"; RC=$?
assert "warning drift exits 1" "[ '$RC' = '1' ]"
assert "names the warning mismatch" "printf '%s' \"\$OUT\" | grep -q 'claims 2 warnings but linter shows 5'"

P="$TMP/status"; make_project "$P" "3 errors, 1 warning(s)" 0 2 "🟡 DEGRADED"
OUT="$(cd "$P" && bash "$VALIDATE" 2>&1)"; RC=$?
assert "error drift exits 1" "[ '$RC' = '1' ]"
assert "expects DEGRADED from the error count" "printf '%s' \"\$OUT\" | grep -q 'Expected status: DEGRADED'"
assert "names the error mismatch" "printf '%s' \"\$OUT\" | grep -q 'claims 0 errors but linter shows 3'"

echo ""
echo "Group 4 — missing file is a hard fail"
P="$TMP/missing"; mkdir -p "$P/scripts"
printf '#!/usr/bin/env bash\necho "0 errors, 0 warning(s)"\n' > "$P/scripts/skill-lint.sh"
OUT="$(cd "$P" && bash "$VALIDATE" 2>&1)"; RC=$?
assert "missing HEALTH-CHECK.md exits 1" "[ '$RC' = '1' ]"
assert "says the file is missing" "printf '%s' \"\$OUT\" | grep -q 'not found'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
