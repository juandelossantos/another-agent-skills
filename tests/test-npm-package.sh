#!/usr/bin/env bash
# test-npm-package.sh — validates the npm wrapper manifest (npm/package.json,
# Phase 9 / P9.5): name, bin, publishConfig.access, version mirrors the repo
# VERSION, and the package ships NO framework payload.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG="$REPO_ROOT/npm/package.json"
REPO_VERSION="$(cat "$REPO_ROOT/VERSION")"

if [ ! -f "$PKG" ]; then
  echo "  ✗ npm/package.json not found: $PKG"
  exit 1
fi

PKG="$PKG" REPO_VERSION="$REPO_VERSION" node -e '
const fs = require("node:fs")
let failed = 0
const check = (name, ok) => { console.log(`  ${ok ? "✓" : "✗"} ${name}`); if (!ok) failed = 1 }

let pkg
try { pkg = JSON.parse(fs.readFileSync(process.env.PKG, "utf-8")) }
catch (e) { console.log("  ✗ npm/package.json is not valid JSON:", e.message); process.exit(1) }

check("name is @juandelossantos/another-agent-skills", pkg.name === "@juandelossantos/another-agent-skills")
check("version mirrors repo VERSION (" + process.env.REPO_VERSION + ")", pkg.version === process.env.REPO_VERSION)
check("license is MIT", pkg.license === "MIT")
check("engines.node is >=18", pkg.engines && pkg.engines.node === ">=18")
check("bin exposes aas-npm -> cli.js", pkg.bin && pkg.bin["aas-npm"] === "cli.js")
check("publishConfig.access is public", pkg.publishConfig && pkg.publishConfig.access === "public")
check("repository points at another-agent-skills", typeof pkg.repository === "object" && typeof pkg.repository.url === "string" && pkg.repository.url.includes("another-agent-skills"))
check("homepage is set", typeof pkg.homepage === "string" && pkg.homepage.includes("another-agent-skills"))
check("description is set", typeof pkg.description === "string" && pkg.description.length > 0)

const files = Array.isArray(pkg.files) ? pkg.files : []
check("files includes cli.js", files.includes("cli.js"))
const payload = ["skills", "scripts", "templates", "plugins", "rules", "bin"]
const leaks = files.filter((f) => payload.some((p) => f === p || f.startsWith(p + "/")))
check("files ships no framework payload (" + payload.join(", ") + ")", leaks.length === 0)
check("files does not ship install.sh", !files.includes("install.sh"))

process.exit(failed)
'
