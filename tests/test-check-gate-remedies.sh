#!/usr/bin/env bash
# test-check-gate-remedies.sh — B15 guard regression: check-gate-remedies.sh must
# PASS on the repo (every cited remedy is installed) and FAIL when a gate message
# tells the user to run a script init-agents does not install.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK="$REPO_ROOT/scripts/check-gate-remedies.sh"

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

mkfixture() {
  local d; d="$(mktemp -d)"
  mkdir -p "$d/scripts/git-hooks"
  cat > "$d/scripts/init-agents.sh" <<'EOF'
AAS_LEGACY_SCRIPTS="skill-gate.sh tdd-gate.sh"
AAS_VALIDATOR_SCRIPTS="validate-skill-table.sh generate-health-check.sh"
EOF
  printf '%s' "$d"
}

# ── Case 1: the real repo passes (B15 remedies are installed) ──
OUT="$(bash "$CHECK" 2>&1)"; RC=$?
assert "real repo: check exits 0" "[ $RC -eq 0 ]"
assert "real repo: reports PASS" "printf '%s' \"\$OUT\" | grep -q 'PASS:'"

# ── Case 2: a fixture citing an INSTALLED remedy passes ──
F="$(mkfixture)"
printf 'echo "Run: bash scripts/validate-skill-table.sh"\n' > "$F/scripts/git-hooks/pre-commit"
OUT2="$(bash "$CHECK" --root "$F" 2>&1)"; RC2=$?
assert "installed remedy: exits 0" "[ $RC2 -eq 0 ]"
rm -rf "$F"

# ── Case 3: a fixture citing an UNINSTALLED remedy fails ──
G="$(mkfixture)"
printf 'echo "Run: bash scripts/not-installed.sh"\n' > "$G/scripts/git-hooks/pre-commit"
OUT3="$(bash "$CHECK" --root "$G" 2>&1)"; RC3=$?
assert "uninstalled remedy: exits 1" "[ $RC3 -eq 1 ]"
assert "uninstalled remedy: names the script" "printf '%s' \"\$OUT3\" | grep -q 'not-installed.sh'"
rm -rf "$G"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
