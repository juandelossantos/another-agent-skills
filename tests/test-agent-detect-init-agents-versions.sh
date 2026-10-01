#!/usr/bin/env bash
# test-agent-detect-init-agents-versions.sh — per-agent version detection
# (agent_version) and its reporting in init-agents --check-env.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

BIN="$TMP/bin"; mkdir -p "$BIN"
printf '#!/usr/bin/env bash\necho "opencode v2.0.20"\n' > "$BIN/opencode"
printf '#!/usr/bin/env bash\necho "claude 1.0.0"\n'    > "$BIN/claude"
printf '#!/usr/bin/env bash\necho "gemini 0.5.0"\n'    > "$BIN/gemini"
chmod +x "$BIN"/*
export PATH="$BIN:/usr/bin:/bin"
export HOME="$TMP/home"; mkdir -p "$HOME"
export AAS_AGENTS="opencode,claude,gemini"

V="$(bash -c 'source "$1"; agent_version opencode' _ "$REPO_ROOT/scripts/agent-detect.sh")"
[ "$V" = "2.0.20" ]; check $? "agent_version opencode → 2.0.20 (got '$V')"

B="$(bash -c 'source "$1"; agent_binary claude' _ "$REPO_ROOT/scripts/agent-detect.sh")"
[ "$B" = "claude" ]; check $? "agent_binary claude → claude"

OUT="$(bash "$REPO_ROOT/scripts/init-agents.sh" --check-env 2>&1)"
echo "$OUT" | grep -q "agent:opencode=2.0.20"; check $? "check-env reports opencode version"
echo "$OUT" | grep -q "agent:claude=1.0.0";    check $? "check-env reports claude version"
echo "$OUT" | grep -q "agent:gemini=0.5.0";    check $? "check-env reports gemini version"

exit "$fail"
