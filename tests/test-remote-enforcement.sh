#!/usr/bin/env bash
# test-remote-enforcement.sh — End-to-end verification of the remote layer (P8.7).
#
# Proves the model in docs/BRANCH-PROTECTION.md actually holds:
#   L1 (local hooks) is bypassable; L2 (remote required check) is the authority.
#
# Three groups:
#   1. Static  — the workflow + CODEOWNERS are the L2/L3 controls.
#   2. Live    — read-only branch-protection state via `gh` (skipped without gh).
#   3. Bypass  — demonstrate a local-hook bypass, then show the remote gate's
#                command still catches the same change.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATES="$REPO_ROOT/.github/workflows/gates.yml"
CODEOWNERS="$REPO_ROOT/CODEOWNERS"

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

echo "╔════════════════════════════════════════════╗"
echo "║  REMOTE ENFORCEMENT — E2E VERIFICATION     ║"
echo "╚════════════════════════════════════════════╝"

# ─── Group 1: Static — L2 workflow + L3 config ───
echo ""
echo "Group 1 — Workflow + config (static)"
assert "gates.yml exists" "[ -f '$GATES' ]"
assert "job is named 'gates' (the required check)" "grep -q '^  gates:' '$GATES'"
assert "workflow is read-only" "grep -q 'contents: read' '$GATES' && ! grep -qE 'contents: write|pull-requests: write' '$GATES'"
assert "runs the real TDD gate" "grep -q 'tdd-gate.sh' '$GATES'"
assert "runs the project suite" "grep -q 'tests/run-all.sh' '$GATES'"
assert "never pushes or commits" "! grep -qE 'git (push|commit)' '$GATES'"
assert "CODEOWNERS protects the workflow dir" "grep -q '\.github/workflows' '$CODEOWNERS'"
assert "CODEOWNERS protects the gate scripts" "grep -qE 'scripts/\*gate\*|scripts/tdd-gate' '$CODEOWNERS'"

# ─── Group 2: Live — read-only branch protection (skipped without gh) ───
echo ""
echo "Group 2 — Live branch protection (read-only)"
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  REPO_SLUG=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
  if [ -n "$REPO_SLUG" ]; then
    PROT=$(gh api "repos/$REPO_SLUG/branches/main/protection" 2>/dev/null || true)
    if [ -n "$PROT" ]; then
      assert "main requires the 'gates' status check" "echo '$PROT' | grep -q '\"gates\"'"
      assert "main requires pull requests" "echo '$PROT' | grep -q 'required_pull_request_reviews'"
      assert "force pushes are disabled" "echo '$PROT' | grep -A2 'allow_force_pushes' | grep -q 'false'"
      assert "deletions are disabled" "echo '$PROT' | grep -A2 'allow_deletions' | grep -q 'false'"
      echo -e "  ${YELLOW}ℹ${NC} repo: $REPO_SLUG — protection is live"
    else
      echo -e "  ${YELLOW}−${NC} branch protection not readable (not admin / not protected) — skipped"
    fi
  else
    echo -e "  ${YELLOW}−${NC} could not resolve repo slug — skipped"
  fi
else
  echo -e "  ${YELLOW}−${NC} gh not available/authenticated — live checks skipped"
fi

# ─── Group 3: Bypass demo — L1 is bypassable, L2 still catches ───
echo ""
echo "Group 3 — Local bypass vs remote authority"
TMP=$(mktemp -d)
EMPTY=$(mktemp -d)
(
  cd "$TMP"
  git init -q
  git checkout -q -b work 2>/dev/null || true
  git config user.email t@t.com
  git config user.name T
  git config commit.gpgsign false
  # Initial commit BEFORE installing the hooks (so HEAD exists).
  echo "# init" > README.md
  git add README.md && git commit -q -m init
  mkdir -p .git/hooks scripts
  cp "$REPO_ROOT/scripts/git-hooks/pre-commit" .git/hooks/pre-commit
  cp "$REPO_ROOT/scripts/git-hooks/commit-msg" .git/hooks/commit-msg
  cp "$REPO_ROOT/scripts/tdd-gate.sh" scripts/tdd-gate.sh
  chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
  printf '%s decision\n' "$(date +%Y-%m-%dT%H:%M:%S)" > .git/DECISION_APPROVED
) >/dev/null 2>&1

# A code change with no matching test → the local TDD hook blocks it.
( cd "$TMP" && echo 'echo hi' > foo.sh && git add foo.sh )
( cd "$TMP" && git commit -q -m "code without test" ) >/dev/null 2>&1
HOOK_EXIT=$?
assert "local hooks block code without a test (L1 active)" "[ $HOOK_EXIT -ne 0 ]"

# Repoint core.hooksPath to an empty dir → the same commit succeeds (L1 bypassed).
( cd "$TMP" && git config core.hooksPath "$EMPTY" && git commit -q -m "code without test" ) >/dev/null 2>&1
BYPASS_EXIT=$?
assert "core.hooksPath bypasses the local hooks (L1 is advisory)" "[ $BYPASS_EXIT -eq 0 ]"

# The remote gate runs tdd-gate.sh, which still fails on the same change.
( cd "$TMP" && echo 'echo more' >> foo.sh && git add foo.sh )
( cd "$TMP" && bash "$REPO_ROOT/scripts/tdd-gate.sh" ) >/dev/null 2>&1
REMOTE_EXIT=$?
assert "the remote gate's command still catches it (L2 authority)" "[ $REMOTE_EXIT -ne 0 ]"

rm -rf "$TMP" "$EMPTY"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
