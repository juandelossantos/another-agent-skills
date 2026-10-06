#!/usr/bin/env bash
# test-pr-review-gate-chain.sh — B8: the PR review gate (Rule 12b) is chained to
# the PR flow. The OpenCode plugin WARNS (emits the checklist reminder) on
# `gh pr create` / `gh pr merge`, and the merged footer carries the Rule 12b
# requirement so it lives in the agent's auto-injected context.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="$REPO_ROOT/plugins/agent-discipline/index.js"
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

# --- Static ---
assert "plugin classifies the gh pr flow (warn-pr)" "grep -q 'warn-pr' '$PLUGIN'"
assert "plugin names Rule 12b" "grep -q 'RULE 12b' '$PLUGIN'"
assert "footer carries the PR review gate" "grep -q 'pr-review-checklist.sh' '$INIT'"

# --- Behavioral: the plugin warns (not blocks) on the PR flow ---
PLUGIN="$PLUGIN" node --input-type=module <<'JS'
const plugin = (await import(process.env.PLUGIN)).default
let failed = 0
const check = (name, ok) => { console.log(`  ${ok ? "✓" : "✗"} ${name}`); if (!ok) failed = 1 }
let executeBefore = null
const ctx = {
  app: { log: () => {} },
  tool: { hook: async (n, fn) => { if (n === "execute.before") executeBefore = fn } },
  session: { hook: async () => {} },
  event: { subscribe: () => ({ [Symbol.asyncIterator]: async function* () {} }) },
}
await plugin.setup(ctx)
const v2 = (tool, command) => { try { executeBefore({ tool, input: { command } }); return "allowed" } catch { return "blocked" } }

check("git commit is still blocked", v2("shell", "git commit -m x") === "blocked")
check("gh pr create is allowed (warn, not block)", v2("shell", "gh pr create --base main") === "allowed")
check("gh pr merge is allowed (warn, not block)", v2("shell", "gh pr merge 42 --squash") === "allowed")
check("gh pr view is allowed (no warn)", v2("shell", "gh pr view 42") === "allowed")

const warns = []
const orig = console.warn
console.warn = (m) => { warns.push(String(m)) }
v2("shell", "gh pr create --base main")
v2("shell", "gh pr merge 42 --squash")
console.warn = orig
check("gh pr create emits the Rule 12b reminder",
  warns.some((w) => w.includes("RULE 12b") && w.includes("pr-review-checklist")))
check("gh pr merge emits the Rule 12b reminder",
  warns.some((w) => w.includes("RULE 12b") && w.includes("pr-review-checklist")))
process.exit(failed)
JS
node_rc=$?
assert "plugin: PR-flow behavior + emitted reminder" "[ $node_rc -eq 0 ]"

# --- Behavioral: the merged footer carries Rule 12b ---
T="$(mktemp -d)"
( cd "$T" && git init -q && git config user.email t@t.t && git config user.name t \
  && echo a > a.txt && git add a.txt && git commit -qm init \
  && printf '# TEAM AGENTS\n' > AGENTS.md \
  && AAS_DIR="$REPO_ROOT" bash "$INIT" > out.log 2>&1 )
assert "merged AGENTS.md carries the PR review gate" "grep -q 'pr-review-checklist.sh' '$T/AGENTS.md'"
assert "merged AGENTS.md names Rule 12b" "grep -q 'Rule 12b' '$T/AGENTS.md'"
rm -rf "$T"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
