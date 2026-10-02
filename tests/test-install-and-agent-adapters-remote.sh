#!/usr/bin/env bash
# test-install-and-agent-adapters-remote.sh — install.sh ships the L2 config script,
# and docs/AGENT-ADAPTERS.md documents how to turn the remote layer on (P8.6).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO_ROOT/install.sh"
DOC="$REPO_ROOT/docs/AGENT-ADAPTERS.md"

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

# --- install.sh distributes the branch-protection script globally ---
assert "install.sh copies setup-branch-protection.sh" "grep -q 'setup-branch-protection.sh' '$INSTALL'"
assert "the script exists in the repo" "[ -f '$REPO_ROOT/scripts/setup-branch-protection.sh' ]"

# --- The doc has the checklist ---
assert "AGENT-ADAPTERS has the Remote Enforcement (L2) section" "grep -q '## Remote Enforcement (L2)' '$DOC'"
assert "documents that local hooks are not authority" "grep -qi 'not enforcement' '$DOC'"
assert "checklist previews with --dry-run" "grep -q 'setup-branch-protection.sh --dry-run' '$DOC'"
assert "checklist applies with setup-branch-protection.sh" "grep -q 'setup-branch-protection.sh$' '$DOC'"
assert "explains solo maintainers are not locked out" "grep -qi 'not locked out' '$DOC'"
assert "links the three-layer model" "grep -q 'BRANCH-PROTECTION.md' '$DOC'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
