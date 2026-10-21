#!/usr/bin/env bash
# test-aas-args.sh — `aas install` threads its optional flags without expanding
# an empty array.
#
# Regression origin: `aas install --agents auto` passed `"${args[@]}"` with an
# empty `args`, which stock macOS's bash 3.2 treats as an unbound variable under
# `set -u` (`args[@]: unbound variable`). The real-interpreter proof is
# tests/test-bash32-smoke.sh (docker); this suite proves the *behavior* is
# unchanged — zero flags when none were given, one flag when asked — using a stub
# installer, so it runs everywhere.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

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

# A minimal framework root: the real CLI + the real sourced libs, a stub
# installer that reports the arguments it received.
FW="$TMP/fw"
mkdir -p "$FW/bin" "$FW/scripts/lib" "$TMP/proj" "$TMP/home"
cp "$REPO_ROOT/bin/aas" "$FW/bin/aas"
cp "$REPO_ROOT/scripts/agent-detect.sh" "$FW/scripts/agent-detect.sh"
cp "$REPO_ROOT/scripts/lib/aas.sh" "$FW/scripts/lib/aas.sh"
cp "$REPO_ROOT/VERSION" "$FW/VERSION"
cat > "$FW/scripts/init-agents.sh" <<'STUB'
#!/usr/bin/env bash
printf 'STUB_ARG_COUNT=%s\n' "$#"
printf 'STUB_ARG_1=%s\n' "${1:-<none>}"
printf 'STUB_AGENTS=%s\n' "${AAS_AGENTS:-<unset>}"
STUB

run_install() {
  ( cd "$TMP/proj" && HOME="$TMP/home" bash "$FW/bin/aas" install "$@" </dev/null 2>&1 )
}

echo ""
echo "aas install — flag threading (empty-array regression)"
echo "─────────────────────────────────────────────────────"

echo ""
echo "Group 1 — no optional flags: the installer gets zero arguments"
OUT="$(run_install --agents claude)"; RC=$?
assert "install exits 0" "[ '$RC' = '0' ]"
assert "installer receives 0 arguments" "printf '%s' \"\$OUT\" | grep -q 'STUB_ARG_COUNT=0'"
assert "the selection is threaded through AAS_AGENTS" "printf '%s' \"\$OUT\" | grep -q 'STUB_AGENTS=claude'"
assert "no unbound-variable abort" "! printf '%s' \"\$OUT\" | grep -q 'unbound variable'"

echo ""
echo "Group 2 — --skip-self-improvement: exactly one argument"
OUT="$(run_install --agents claude --skip-self-improvement)"; RC=$?
assert "install exits 0" "[ '$RC' = '0' ]"
assert "installer receives 1 argument" "printf '%s' \"\$OUT\" | grep -q 'STUB_ARG_COUNT=1'"
assert "the flag is forwarded verbatim" "printf '%s' \"\$OUT\" | grep -q 'STUB_ARG_1=--skip-self-improvement'"

echo ""
echo "Group 3 — the source uses the bash-3.2-safe expansion"
assert "bin/aas uses \${args[@]+...}" "grep -qF 'args[@]+\"\${args[@]}\"' '$REPO_ROOT/bin/aas'"
assert "bin/aas has no bare empty-array expansion" "! grep -qE 'bash \"\\\$init\" \"\\\$\\{args\\[@\\]\\}\"' '$REPO_ROOT/bin/aas'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
