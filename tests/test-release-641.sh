#!/usr/bin/env bash
# test-release-641.sh — v6.4.1 Phase 15 release contract: approval integrity.
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
echo "v6.4.1 — approval integrity contract"
echo "─────────────────────────────────────"

assert "VERSION is 6.4.1" "[ \"\$(tr -d '[:space:]' < '$REPO_ROOT/VERSION')\" = '6.4.1' ]"
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
assert "blog EN explains the binding" "grep -q 'What an approval actually binds' '$REPO_ROOT/web/src/content/blog/the-human-in-command.en.md'"
assert "blog ES explains the binding" "grep -q 'Lo que una aprobación ata de verdad' '$REPO_ROOT/web/src/content/blog/the-human-in-command.es.md'"
assert "web docs mention the human-approved digest (EN)" "grep -qi 'human-approved digest' '$REPO_ROOT/web/src/content/docs/enforcement.en.md'"
assert "web docs mention the approved digest (ES)" "grep -qi 'digest aprobado' '$REPO_ROOT/web/src/content/docs/enforcement.es.md'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
