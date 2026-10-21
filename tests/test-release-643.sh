#!/usr/bin/env bash
# test-release-643.sh — v6.4.3 release contract: macOS bash 3.2 compatibility.
#
# Keeps the Phase 15 assertions (they still hold) and adds the compatibility
# artifacts: the static guard, the real-3.2 smoke in the required gates check,
# the installer fixes and the npm README.
#
# Version surfaces are covered by the version-agnostic test-release-640.sh.
# This suite guards the Phase 15 artifacts and the claims that ship with them.
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

echo ""
echo "v6.4.3 — macOS BSD userland compatibility contract"
echo "─────────────────────────────────────"

assert "VERSION is 6.4.3" "[ \"\$(tr -d '[:space:]' < '$REPO_ROOT/VERSION')\" = '6.4.3' ]"
assert "approve.sh exists and is executable" "[ -x '$REPO_ROOT/scripts/approve.sh' ]"
assert "approve.sh binds the staged tree" "grep -q 'git write-tree' '$REPO_ROOT/scripts/approve.sh'"
assert "pre-commit validates the approved tree" "grep -q 'APPROVED_TREE' '$REPO_ROOT/scripts/git-hooks/pre-commit'"
assert "pre-commit consumes the approval" "grep -q 'Approval consumed' '$REPO_ROOT/scripts/git-hooks/pre-commit'"
assert "check-approved-tree.sh exists and is executable" "[ -x '$REPO_ROOT/scripts/check-approved-tree.sh' ]"
assert "gates.yml runs the L2 approval check" "grep -q 'scripts/check-approved-tree.sh' '$REPO_ROOT/.github/workflows/gates.yml'"
assert "gates.yml checks out the PR head" "grep -q 'github.event.pull_request.head.sha' '$REPO_ROOT/.github/workflows/gates.yml'"
assert "agent-runner.sh exists and is executable" "[ -x '$REPO_ROOT/scripts/agent-runner.sh' ]"
assert "Rule 12 says the human runs approve.sh" "grep -q 'bash scripts/approve.sh' '$REPO_ROOT/rules/common/enforcement.md'"
assert "RELEASE-NOTES names approval binding" "grep -qi 'Approval binding' '$REPO_ROOT/RELEASE-NOTES.md'"
assert "check-bash32.sh exists and is executable" "[ -x '$REPO_ROOT/scripts/check-bash32.sh' ]"
assert "gates.yml runs the static bash 3.2 guard" "grep -q 'scripts/check-bash32.sh' '$REPO_ROOT/.github/workflows/gates.yml'"
assert "gates.yml runs the bash:3.2 smoke" "grep -q 'tests/test-bash32-smoke.sh' '$REPO_ROOT/.github/workflows/gates.yml'"
assert "bin/aas guards the empty args array" "grep -qF 'args[@]+' '$REPO_ROOT/bin/aas'"
assert "aas_remove_path guards the empty files array" "grep -qF '${#files[@]}' '$REPO_ROOT/scripts/lib/aas.sh'"
assert "tdd-gate lowercases without bash 4" "grep -q 'lower() {' '$REPO_ROOT/scripts/tdd-gate.sh'"
assert "RELEASE-NOTES names the macOS bash 3.2 fix" "grep -qi 'macOS bash 3.2' '$REPO_ROOT/RELEASE-NOTES.md'"
assert "npm/README documents v6.4.3" "grep -qF \"What's new in v6.4.3\" '$REPO_ROOT/npm/README.md'"
assert "blog EN explains the binding" "grep -q 'What an approval actually binds' '$REPO_ROOT/web/src/content/blog/the-human-in-command.en.md'"
assert "blog ES explains the binding" "grep -q 'Lo que una aprobación ata de verdad' '$REPO_ROOT/web/src/content/blog/the-human-in-command.es.md'"
assert "web docs mention the human-approved digest (EN)" "grep -qi 'human-approved digest' '$REPO_ROOT/web/src/content/docs/enforcement.en.md'"
assert "web docs mention the approved digest (ES)" "grep -qi 'digest aprobado' '$REPO_ROOT/web/src/content/docs/enforcement.es.md'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
