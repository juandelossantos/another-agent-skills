#!/usr/bin/env bash
# test-install-plugin-source.sh — the OpenCode plugin SOURCE must not live under
# .opencode/plugins/. OpenCode auto-loads that dir, so a repo-local copy collides
# with the globally installed plugin: "Duplicate plugin ID: agent-discipline".
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

[ -f "$REPO_ROOT/plugins/agent-discipline/index.js" ]; check $? "plugin source at plugins/agent-discipline/index.js"
[ ! -e "$REPO_ROOT/.opencode/plugins/agent-discipline" ]; check $? "no plugin under .opencode/plugins/ (avoids auto-load collision)"
grep -q 'plugins/agent-discipline' "$REPO_ROOT/install.sh"; check $? "install.sh references the new source path"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
AGENT_SKILLS_DIR="$TMP/oc" HOME="$TMP/home" bash "$REPO_ROOT/install.sh" --plugin-only >/dev/null 2>&1; check $? "install --plugin-only works from the new source"
[ -f "$TMP/oc/plugins/agent-discipline/index.js" ]; check $? "plugin installed into the global plugins dir"

exit "$fail"
