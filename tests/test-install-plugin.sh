#!/usr/bin/env bash
# test-install-plugin.sh — global plugin install (install.sh --plugin-only).
# Proves the installer replaces a legacy install, drops stale artifacts
# (plugin.json/src/dist/node_modules), quarantines backup dirs, and leaves
# exactly one dual-contract instance that loads.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export AGENT_SKILLS_DIR="$TMP/opencode"
PLUGINS="$AGENT_SKILLS_DIR/plugins"
LEGACY="$PLUGINS/agent-discipline"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# Seed a legacy install with artifacts the new plugin must not carry, plus a backup dir.
mkdir -p "$LEGACY/src" "$LEGACY/dist" "$LEGACY/node_modules" \
         "$PLUGINS/agent-discipline.backup.20260101000000"
echo '{"hooks":{}}'                 > "$LEGACY/plugin.json"
echo 'export function register(){}' > "$LEGACY/src/index.ts"
echo 'module.exports={}'            > "$LEGACY/dist/index.js"
echo 'export function register(){}' > "$LEGACY/index.js"
echo 'old'                          > "$PLUGINS/agent-discipline.backup.20260101000000/index.js"

OUT="$(bash "$REPO_ROOT/install.sh" --plugin-only 2>&1)"
RC=$?
if [ "$RC" -eq 0 ]; then echo "  ✓ install --plugin-only exits 0"; else echo "  ✗ install --plugin-only exit=$RC"; echo "$OUT" | sed 's/^/      /'; fail=1; fi

[ -f "$LEGACY/index.js" ];        check $? "plugin entrypoint installed"
[ -f "$LEGACY/package.json" ];    check $? "package.json installed"
[ ! -e "$LEGACY/plugin.json" ];   check $? "legacy plugin.json removed"
[ ! -d "$LEGACY/src" ];           check $? "legacy src/ removed"
[ ! -d "$LEGACY/dist" ];          check $? "legacy dist/ removed"
[ ! -d "$LEGACY/node_modules" ];  check $? "legacy node_modules removed"

COUNT="$(find "$PLUGINS" -maxdepth 1 -type d -name 'agent-discipline*' | wc -l | tr -d ' ')"
[ "$COUNT" -eq 1 ]; check $? "exactly one agent-discipline dir (found $COUNT)"

[ -d "$AGENT_SKILLS_DIR/.plugin-backups" ]; check $? "legacy backup quarantined to .plugin-backups"

if diff -q "$LEGACY/index.js" "$REPO_ROOT/plugins/agent-discipline/index.js" >/dev/null 2>&1; then
  echo "  ✓ installed plugin matches repo source"
else
  echo "  ✗ installed plugin differs from repo source"; fail=1
fi

if node --input-type=module -e "const p=(await import('$LEGACY/index.js')).default; process.exit(p.id==='agent-discipline'&&typeof p.setup==='function'&&typeof p.server==='function'?0:1)"; then
  echo "  ✓ installed plugin loads (id + setup + server)"
else
  echo "  ✗ installed plugin does not load"; fail=1
fi

# ── Cursor adapter manifest (philosophy A) ──
CURSOR_JSON="$REPO_ROOT/.cursor-plugin/agent-discipline/plugin.json"
if jq -e '.hooks.beforeShellExecution' "$CURSOR_JSON" >/dev/null 2>&1; then
  echo "  ✓ Cursor plugin.json registers the documented beforeShellExecution event"
else
  echo "  ✗ Cursor plugin.json missing beforeShellExecution"; fail=1
fi
if grep -q 'COMMIT_APPROVED\|onCommit\|approve-commit' "$CURSOR_JSON"; then
  echo "  ✗ Cursor plugin.json still references the retired token/onCommit"; fail=1
else
  echo "  ✓ Cursor plugin.json has no retired token/onCommit reference"
fi

exit "$fail"
