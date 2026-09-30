#!/usr/bin/env bash
# test-install-plugin-path.sh — install.sh must reference the relocated plugin
# source (plugins/agent-discipline), never the old auto-loaded path.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

grep -q 'plugin_src="${SCRIPT_DIR}/plugins/agent-discipline"' "$REPO_ROOT/install.sh"; check $? "install.sh points plugin_src at plugins/agent-discipline"

if grep -q '\.opencode/plugins/agent-discipline' "$REPO_ROOT/install.sh"; then
  echo "  ✗ install.sh still references the old path"; fail=1
else
  echo "  ✓ no old-path reference in install.sh"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
AGENT_SKILLS_DIR="$TMP/oc" HOME="$TMP/home" bash "$REPO_ROOT/install.sh" --plugin-only >/dev/null 2>&1; check $? "install --plugin-only exits 0"
[ -f "$TMP/oc/plugins/agent-discipline/index.js" ]; check $? "plugin installed from the relocated source"

exit "$fail"
