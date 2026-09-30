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

check("git commit is blocked", (await run("git commit -m x")) === "blocked")
check("git push is blocked", (await run("git push origin main")) === "blocked")
check("git reset --hard is blocked", (await run("git reset --hard")) === "blocked")
check("git rebase is blocked", (await run("git rebase main")) === "blocked")

// A decision token must NOT re-enable committing.
fs.writeFileSync(path.join(dir, ".git/DECISION_APPROVED"), `user approved ${new Date().toISOString()}`)
check("git commit stays blocked with a fresh token", (await run("git commit -m x")) === "blocked")

check("git status is allowed", (await run("git status")) === "allowed")
check("git diff is allowed", (await run("git diff")) === "allowed")
check("git add is allowed", (await run("git add a.txt")) === "allowed")

process.exit(failed)
JS
