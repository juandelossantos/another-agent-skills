#!/usr/bin/env bash
# test-branch-protection-harness-approval.sh — the decision/working-tree taxonomy
# and the solo-compatible remote approval (Phase 8, P8.8 + P8.9).

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BP="$REPO_ROOT/docs/BRANCH-PROTECTION.md"
HARNESS="$REPO_ROOT/docs/HARNESS.md"

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

# --- The taxonomy: decisions remote, working-tree checks local ---
assert "has 'Which checks belong where'" "grep -q '## Which checks belong where' '$BP'"
assert "classifies decisions as remote" "grep -qi 'Decisions.*approval' '$BP'"
assert "classifies working-tree checks as local" "grep -qi 'Working-tree checks' '$BP'"
assert "states a green hook is not approval" "grep -qi 'a green hook is feedback, not approval' '$BP'"

# --- Gate 0 is labelled L1 in the model doc ---
assert "BP doc says Gate 0 is L1" "grep -q 'Gate 0 is L1' '$BP'"

# --- The solo-compatible remote approval (Environments) ---
assert "documents the environment approval pattern" "grep -q 'deployment environment with required reviewers' '$BP'"
assert "notes Prevent self-review is off by default" "grep -qi 'Prevent self-review.*off.*by default' '$BP'"
assert "warns not to enable Prevent self-review solo" "grep -qi 'keep \"Prevent self-review\" .*off.* on a solo repo' '$BP'"
assert "shows an environment-gated job snippet" "grep -q 'environment: release' '$BP'"

# --- HARNESS.md is honest about the token ---
assert "HARNESS labels the token an L1 prompt" "grep -q 'DECISION_APPROVED token (L1 prompt)' '$HARNESS'"
assert "HARNESS no longer says the hook only 'warns'" "! grep -q 'hook warns if token missing' '$HARNESS'"
assert "HARNESS says it is not enforcement" "grep -q 'not enforcement' '$HARNESS'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
