#!/usr/bin/env bash
# test-agent-discipline-shell-tool-id.sh — B6 regression: OpenCode v2 renamed
# the shell tool `bash` → `shell` ("bash is now shell", migrate-v1). The
# agent-discipline plugin must enforce on the real v2 id (`shell`) and stay
# back-compatible with the v1 id (`bash`). Before the fix it filtered by `bash`
# only, so the guardrail silently evaluated nothing in v2.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="$REPO_ROOT/plugins/agent-discipline/index.js"

if [ ! -f "$PLUGIN" ]; then
  echo "  ✗ plugin not found: $PLUGIN"
  exit 1
fi
if ! node --check "$PLUGIN" 2>/dev/null; then
  echo "  ✗ plugin has a syntax error"
  exit 1
fi

# Static: the source must not filter on a single hard-coded `bash` id anymore.
if grep -qE '!==\s*"bash"' "$PLUGIN"; then
  echo "  ✗ plugin still hard-codes the v1 tool id (bash) — the v2 guardrail is inert"
  exit 1
fi
if ! grep -q 'SHELL_TOOL_IDS' "$PLUGIN"; then
  echo "  ✗ SHELL_TOOL_IDS constant missing"
  exit 1
fi

PLUGIN="$PLUGIN" node --input-type=module <<'JS'
const plugin = (await import(process.env.PLUGIN)).default
let failed = 0
const check = (name, ok, detail = "") => {
  console.log(`  ${ok ? "✓" : "✗"} ${name}${detail ? ` — ${detail}` : ""}`)
  if (!ok) failed = 1
}

// ── v1 contract: server() returns hooks that run on the v1 id (`bash`) ──
const hooks = await plugin.server()
const v1 = async (tool, command) => {
  try { await hooks["tool.execute.before"]({ tool }, { args: { command } }); return "allowed" }
  catch { return "blocked" }
}
check("v1 blocks git commit on `bash`", (await v1("bash", "git commit -m x")) === "blocked")
check("v1 blocks git push on `bash`", (await v1("bash", "git push")) === "blocked")
check("v1 also blocks on `shell` (dual-id back-compat)", (await v1("shell", "git commit -m x")) === "blocked")
check("v1 allows git status on `bash`", (await v1("bash", "git status")) === "allowed")
check("v1 ignores a non-shell tool (`read`)", (await v1("read", "git commit -m x")) === "allowed")

// ── v2 contract: setup(ctx) registers execute.before; event.tool is `shell` ──
let executeBefore = null
const ctx = {
  app: { log: () => {} },
  tool: { hook: async (name, fn) => { if (name === "execute.before") executeBefore = fn } },
  session: { hook: async () => {} },
  event: { subscribe: () => ({ [Symbol.asyncIterator]: async function* () {} }) },
}
const cleanup = await plugin.setup(ctx)
check("v2 registers execute.before", typeof executeBefore === "function")
const v2 = (tool, command) => {
  try { executeBefore({ tool, input: { command } }); return "allowed" }
  catch { return "blocked" }
}
check("v2 blocks git commit on the real v2 id (`shell`)", v2("shell", "git commit -m x") === "blocked")
check("v2 blocks git push on the real v2 id (`shell`)", v2("shell", "git push") === "blocked")
check("v2 blocks compound `cd x && git commit` on `shell`", v2("shell", "cd x && git commit -m x") === "blocked")
check("v2 still blocks on the legacy id (`bash`)", v2("bash", "git commit -m x") === "blocked")
check("v2 allows git status on `shell`", v2("shell", "git status") === "allowed")
check("v2 ignores a non-shell tool (`read`)", v2("read", "git commit -m x") === "allowed")

if (typeof cleanup === "function") cleanup()
process.exit(failed)
JS
