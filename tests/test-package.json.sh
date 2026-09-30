#!/usr/bin/env bash
# test-package.json.sh — validates the agent-discipline plugin manifest
# (plugins/agent-discipline/package.json).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG="$REPO_ROOT/plugins/agent-discipline/package.json"

if [ ! -f "$PKG" ]; then
  echo "  ✗ package.json not found: $PKG"
  exit 1
fi

PKG="$PKG" node -e '
const fs = require("node:fs")
let failed = 0
const check = (name, ok) => { console.log(`  ${ok ? "✓" : "✗"} ${name}`); if (!ok) failed = 1 }

let pkg
try { pkg = JSON.parse(fs.readFileSync(process.env.PKG, "utf-8")) }
catch (e) { console.log("  ✗ package.json is not valid JSON:", e.message); process.exit(1) }

check("type is module", pkg.type === "module")
check("main points to index.js", pkg.main === "index.js")
check("exports entry is index.js", pkg.exports && pkg.exports["."] === "./index.js")
check("engines.opencode includes 1.18.29", typeof pkg.engines?.opencode === "string" && pkg.engines.opencode.includes("1.18.29"))

process.exit(failed)
'
