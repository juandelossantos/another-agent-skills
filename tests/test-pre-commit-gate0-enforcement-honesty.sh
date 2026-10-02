#!/usr/bin/env bash
# test-pre-commit-gate0-enforcement-honesty.sh — Gate 0 is an L1 prompt, not
# enforcement (Phase 8, P8.8).
#
# The DECISION_APPROVED token is written by the agent, so Gate 0 can only be
# fast feedback: it makes the DECISION POINT visible. It is NOT the approval
# authority (the human running `git commit` is). This suite guards the honesty
# of the hook message and the enforcement docs.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$REPO_ROOT/scripts/git-hooks/pre-commit"
HTML="$REPO_ROOT/docs/enforcement.html"
EN="$REPO_ROOT/docs/i18n/en.json"
ES="$REPO_ROOT/docs/i18n/es.json"

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

# --- The hook no longer calls Gate 0 an "approval" ---
assert "Gate 0 header no longer says 'Decision approval'" "! grep -q 'Gate 0: Decision approval' '$HOOK'"
assert "Gate 0 header calls it an L1 prompt" "grep -q 'Gate 0: Decision prompt — L1' '$HOOK'"
assert "hook says it is not the approval authority" "grep -q 'not the approval authority' '$HOOK'"
assert "hook says the human running git commit is the approval" "grep -q 'the human running git commit is the approval' '$HOOK'"
assert "no longer prints 'Decision approval fresh'" "! grep -q 'Decision approval fresh' '$HOOK'"

# --- The docs stop calling it a warning / stop implying enforcement ---
assert "enforcement.html no longer says Gate 0 'warns'" "! grep -q 'checks .git/DECISION_APPROVED and warns' '$HTML'"
assert "enforcement.html labels Gate 0 as an L1 prompt" "grep -q 'L1 prompt (advisory)' '$HTML'"
assert "en.json labels Gate 0 as an L1 prompt" "grep -q 'L1 prompt (advisory)' '$EN'"
assert "es.json labels Gate 0 as a prompt L1" "grep -q 'prompt L1 (advisory)' '$ES'"
assert "en.json level3 notes the agent writes the token" "grep -q 'the agent writes the token' '$EN'"
assert "es.json level3 notes the agent writes the token" "grep -q 'el token lo escribe el agente' '$ES'"

# --- i18n stays valid ---
assert "en.json is valid JSON" "jq empty '$EN' 2>/dev/null"
assert "es.json is valid JSON" "jq empty '$ES' 2>/dev/null"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
