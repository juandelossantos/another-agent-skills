#!/usr/bin/env bash
# test-claude-commit-approval.sh — the Claude guardrail hook (philosophy A)
# denies git commit/push unconditionally and ignores everything else.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/.claude-plugin/agent-discipline/hooks/commit-approval.sh"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

if [ ! -f "$HOOK" ]; then echo "  ✗ hook not found: $HOOK"; exit 1; fi

run_hook() { echo "$1" | bash "$HOOK"; }

OUT="$(run_hook '{"tool_input":{"command":"git commit -m x"}}')"
echo "$OUT" | grep -q '"permissionDecision": "deny"'; check $? "denies git commit"

OUT="$(run_hook '{"tool_input":{"command":"git push origin main"}}')"
echo "$OUT" | grep -q '"permissionDecision": "deny"'; check $? "denies git push"

OUT="$(run_hook '{"tool_input":{"command":"git -C /repo commit -m x"}}')"
echo "$OUT" | grep -q '"permissionDecision": "deny"'; check $? "denies git with flags"

OUT="$(run_hook '{"tool_input":{"command":"git status"}}')"
[ -z "$OUT" ]; check $? "allows git status (no deny output)"

OUT="$(run_hook '{"tool_input":{"command":"git commit-graph write"}}')"
[ -z "$OUT" ]; check $? "does not match git commit-graph"

OUT="$(run_hook '{"tool_input":{"command":"gh pr merge 42"}}')"
echo "$OUT" | grep -q '"permissionDecision": "deny"'; check $? "denies gh pr merge (Rule 12b)"

OUT="$(run_hook '{"tool_input":{"command":"gh -R owner/repo pr merge 42"}}')"
echo "$OUT" | grep -q '"permissionDecision": "deny"'; check $? "denies gh pr merge with flags"

OUT="$(run_hook '{"tool_input":{"command":"gh pr create --base main"}}')"
[ -z "$OUT" ]; check $? "allows gh pr create (only merge is gated)"

exit "$fail"
