#!/usr/bin/env bash
# test-install-global-validators.sh — B21 regression: install.sh's
# install_global_framework must copy the FULL set of scripts a project shim may
# delegate to — the 10 legacy scripts + the audit/ADR helpers + the 3 remediation
# validators — so the global dir (~/.config/opencode, a legacy $AAS_DIR fallback)
# can satisfy every shim. Before the fix it copied only the 10 legacy scripts.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO_ROOT/install.sh"

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

# Extract the function and run it in a sandbox with stubbed logging.
FUNC="$(awk '/^install_global_framework\(\) \{/,/^}/' "$INSTALL")"
assert "extracted install_global_framework" "[ -n \"\$FUNC\" ]"

GLOBAL="$(mktemp -d)"
SANDBOX="$(mktemp -d)"
cat > "$SANDBOX/run.sh" <<EOF
set -uo pipefail
SCRIPT_DIR="$REPO_ROOT"
AGENT_SKILLS_DIR="$GLOBAL"
info() { :; }; ok() { :; }; warn() { :; }; error() { :; }
$FUNC
install_global_framework
EOF
bash "$SANDBOX/run.sh" >/dev/null 2>&1

# The remediation validators (B15) must be present in the global fallback.
for v in validate-skill-table.sh validate-health-check.sh generate-health-check.sh; do
  assert "global install has scripts/${v}" "[ -x '$GLOBAL/scripts/${v}' ]"
done
# The audit/ADR helpers a project shim also delegates to.
assert "global install has scripts/audit-project.sh" "[ -x '$GLOBAL/scripts/audit-project.sh' ]"
assert "global install has scripts/generate-adr.sh" "[ -x '$GLOBAL/scripts/generate-adr.sh' ]"
# The 10 legacy scripts are still there (no regression).
for s in skill-gate.sh edit-guard.sh tdd-gate.sh skill-lint.sh; do
  assert "global install still has scripts/${s}" "[ -x '$GLOBAL/scripts/${s}' ]"
done

rm -rf "$GLOBAL" "$SANDBOX"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
