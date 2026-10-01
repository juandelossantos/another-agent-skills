#!/usr/bin/env bash
# test-agent-discipline-index.sh — the agent-discipline OpenCode plugin
# (plugins/agent-discipline/index.js): dual contract (v1 + v2) and
# philosophy A — the agent NEVER runs git commit/push (no token bypass).
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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
if ! (cd "$TMP" && git init -q && git config user.email t@t.t && git config user.name t && echo a > a.txt && git add a.txt && git commit -qm init); then
  echo "  ✗ could not create temp git repo"
  exit 1
fi

PLUGIN="$PLUGIN" TEST_REPO="$TMP" node --input-type=module <<'JS'
import * as fs from "node:fs"
import * as path from "node:path"

const plugin = (await import(process.env.PLUGIN)).default
let failed = 0
const check = (name, ok, detail = "") => {
  console.log(`  ${ok ? "✓" : "✗"} ${name}${detail ? ` — ${detail}` : ""}`)
  if (!ok) failed = 1
}

// ── Dual contract shape ──
check("default export has id", plugin.id === "agent-discipline", String(plugin.id))
check("v2 setup() present", typeof plugin.setup === "function")
check("v1 server() present", typeof plugin.server === "function")

const hooks = await plugin.server()
check("v1 exposes tool.execute.before", typeof hooks["tool.execute.before"] === "function")
check("v1 exposes experimental.session.compacting", typeof hooks["experimental.session.compacting"] === "function")

// ── Philosophy A: mutations are always blocked ──
const dir = process.env.TEST_REPO
process.chdir(dir)
const run = async (command) => {
  try {
    await hooks["tool.execute.before"]({ tool: "bash" }, { args: { command } })
    return "allowed"
  } catch {
    return "blocked"
  }
}

// Bypass shapes flagged by review: prefixes, separators, flags, double space.
const BYPASS_CASES = [
  ["cd x && git commit -m x", "compound &&"],
  ["true; git push origin main", "compound ;"],
  ["git status | git commit -m x", "compound |"],
  ["FOO=bar git commit -m x", "NAME=val prefix"],
  ["env git commit -m x", "env prefix"],
  ["env FOO=bar git commit -m x", "env + NAME=val prefix"],
  ["sudo git commit -m x", "sudo prefix"],
  ["git -C dir commit -m x", "flags-aware -C"],
  ["git --git-dir=/tmp/x commit -m x", "flags-aware --git-dir"],
  ["git  commit -m x", "double space"],
]
const ALLOWED_CASES = [
  ["git status", "status"],
  ["git diff", "diff"],
  ["git add a.txt", "add"],
  ["git log --oneline", "log"],
  ["git commit-tree abc123", "commit-tree plumbing"],
  ["git pushx origin main", "pushx word boundary"],
  ["git branch --list", "branch list"],
]

for (const [cmd, label] of BYPASS_CASES) {
  check(`v1 blocks git mutation (${label}): ${cmd}`, (await run(cmd)) === "blocked")
}
for (const [cmd, label] of ALLOWED_CASES) {
  check(`v1 allows (${label}): ${cmd}`, (await run(cmd)) === "allowed")
}

// A decision token must NOT re-enable committing.
fs.writeFileSync(path.join(dir, ".git/DECISION_APPROVED"), `user approved ${new Date().toISOString()}`)
check("git commit stays blocked with a fresh token", (await run("git commit -m x")) === "blocked")
check("compound commit stays blocked with a fresh token", (await run("cd x && git commit -m x")) === "blocked")

// v1 compaction: the documented output field is `context: string[]`.
const v1Context = []
await hooks["experimental.session.compacting"]({}, { context: v1Context })
check("v1 compaction pushes a reminder onto output.context", v1Context.length === 1 && typeof v1Context[0] === "string")

// ── v2 path: setup(ctx) registers hooks and enforces identically ──
const calls = []
let v2ExecuteBefore = null
let v2Compaction = null
const ctx = {
  app: { log: () => {} },
  tool: { hook: async (name, fn) => { calls.push(`tool:${name}`); if (name === "execute.before") v2ExecuteBefore = fn } },
  session: { hook: async (name, fn) => { calls.push(`session:${name}`); if (name === "compaction") v2Compaction = fn } },
  event: { subscribe: () => ({ [Symbol.asyncIterator]: async function* () {} }) },
}
const cleanup = await plugin.setup(ctx)
check("v2 setup registers tool.execute.before", calls.includes("tool:execute.before"))
check("v2 setup registers session.compaction", calls.includes("session:compaction"))
check("v2 setup returns a cleanup function", typeof cleanup === "function")

const runV2 = (command) => {
  try { v2ExecuteBefore({ tool: "bash", input: { command } }); return "allowed" }
  catch { return "blocked" }
}
for (const [cmd, label] of BYPASS_CASES) {
  check(`v2 blocks git mutation (${label}): ${cmd}`, runV2(cmd) === "blocked")
}
for (const [cmd, label] of ALLOWED_CASES) {
  check(`v2 allows (${label}): ${cmd}`, runV2(cmd) === "allowed")
}

// v2 compaction: documented `event.system` is a SystemPart[] (`{type,text}`).
const system = []
v2Compaction({ system })
check(
  "v2 compaction injects a documented SystemPart reminder",
  system.length === 1 && system[0].type === "text" && typeof system[0].text === "string",
)

if (typeof cleanup === "function") cleanup()

process.exit(failed)
JS
