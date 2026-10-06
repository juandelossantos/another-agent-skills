#!/usr/bin/env bash
# test-init-agents-rule12-footer.sh — B7 regression: the footer AAS merges into
# AGENTS.md/CLAUDE.md must carry the binding NON-NEGOTIABLES (Rule 12: the agent
# never commits/pushes), so the rule is in the agent's auto-injected context —
# not only in rules/common/*.md, which the agent may never read.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INIT="$REPO_ROOT/scripts/init-agents.sh"

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

# --- Static: the footer carries the binding rule ---
assert "footer has a NON-NEGOTIABLES block" "grep -q 'NON-NEGOTIABLES' '$INIT'"
assert "footer states the agent NEVER runs git commit" "grep -q 'NEVER runs \`git commit\`' '$INIT'"
assert "footer names Rule 12" "grep -q 'Rule 12' '$INIT'"
assert "footer points at rules/common/enforcement.md" "grep -q 'rules/common/enforcement.md' '$INIT'"
assert "footer resolves the skill-vs-rule conflict" "grep -q 'OVERRIDES any skill that assumes the agent commits' '$INIT'"

# --- Behavioral: merge into an existing AGENTS.md ---
T="$(mktemp -d)"
( cd "$T" && git init -q && git config user.email t@t.t && git config user.name t \
  && echo a > a.txt && git add a.txt && git commit -qm init \
  && printf '# TEAM AGENTS\n\nTEAM RULES — MUST KEEP\n' > AGENTS.md \
  && AAS_DIR="$REPO_ROOT" bash "$INIT" > out.log 2>&1 )

assert "team AGENTS.md preserved" "grep -q 'TEAM RULES — MUST KEEP' '$T/AGENTS.md'"
assert "merged: NON-NEGOTIABLES present" "grep -q 'NON-NEGOTIABLES' '$T/AGENTS.md'"
assert "merged: Rule 12 'NEVER runs git commit' present" "grep -q 'NEVER runs \`git commit\`' '$T/AGENTS.md'"
assert "merged: approval requirement present" "grep -q 'explicit user approval' '$T/AGENTS.md'"

# Idempotent: a second run must not duplicate the footer.
N1="$(grep -c 'NON-NEGOTIABLES' "$T/AGENTS.md")"
( cd "$T" && AAS_DIR="$REPO_ROOT" bash "$INIT" > out2.log 2>&1 )
N2="$(grep -c 'NON-NEGOTIABLES' "$T/AGENTS.md")"
assert "idempotent: footer not duplicated on re-run" "[ \"\$N1\" = \"\$N2\" ] && [ \"\$N2\" = \"1\" ]"
rm -rf "$T"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
