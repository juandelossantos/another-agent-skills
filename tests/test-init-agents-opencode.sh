#!/usr/bin/env bash
# test-init-agents-opencode.sh — init-agents --check-env detects the OpenCode
# version and flags a legacy (v1-only) agent-discipline plugin.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# Fake opencode reporting v2.
mkdir -p "$TMP/bin"
cat > "$TMP/bin/opencode" <<'EOF'
#!/usr/bin/env bash
[ "${1:-}" = "--version" ] && echo "opencode v2.0.20"
EOF
chmod +x "$TMP/bin/opencode"

export AGENT_SKILLS_DIR="$TMP/opencode"

# Case 1: legacy plugin present.
mkdir -p "$AGENT_SKILLS_DIR/plugins/agent-discipline/src"
echo '{}' > "$AGENT_SKILLS_DIR/plugins/agent-discipline/plugin.json"

OUT="$(PATH="$TMP/bin:$PATH" bash "$REPO_ROOT/scripts/init-agents.sh" --check-env 2>&1)"
echo "$OUT" | grep -q "opencode=2.0.20";          check $? "detects opencode version"
echo "$OUT" | grep -q "agent-discipline=legacy";  check $? "flags legacy plugin"
echo "$OUT" | grep -q "install.sh --plugin-only"; check $? "suggests the fix"

# Case 2: dual-contract plugin present.
rm -rf "$AGENT_SKILLS_DIR/plugins/agent-discipline"
mkdir -p "$AGENT_SKILLS_DIR/plugins/agent-discipline"
echo 'export default {id:"agent-discipline",setup(){},server(){}}' > "$AGENT_SKILLS_DIR/plugins/agent-discipline/index.js"

OUT2="$(PATH="$TMP/bin:$PATH" bash "$REPO_ROOT/scripts/init-agents.sh" --check-env 2>&1)"
echo "$OUT2" | grep -q "agent-discipline=dual-contract"; check $? "recognizes dual-contract plugin"
if echo "$OUT2" | grep -qi "legacy"; then echo "  ✗ false legacy warning"; fail=1; else echo "  ✓ no false legacy warning"; fi

exit "$fail"
