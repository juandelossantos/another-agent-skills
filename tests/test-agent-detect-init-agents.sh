#!/usr/bin/env bash
# test-agent-detect-init-agents.sh — the agent detection engine
# (scripts/agent-detect.sh) and its wiring into init-agents
# (--list-agents, --check-env).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# Controlled PATH: only our fake binaries + coreutils (no real opencode/claude).
BIN="$TMP/bin"; mkdir -p "$BIN"
for b in opencode claude; do printf '#!/usr/bin/env bash\nexit 0\n' > "$BIN/$b"; chmod +x "$BIN/$b"; done
SAFE_PATH="$BIN:/usr/bin:/bin"
EMPTY_BIN="$TMP/emptybin"; mkdir -p "$EMPTY_BIN"   # no agent binaries at all
BASH_BIN="$(command -v bash)"

# Use an absolute bash so PATH can be fully controlled (incl. an empty PATH).
detect() { ( cd "$1" && HOME="$2" PATH="$3" "$BASH_BIN" "$REPO_ROOT/scripts/agent-detect.sh" ); }

# Case 1 — multi-agent: global dirs + binaries.
HOME_A="$TMP/home-a"; mkdir -p "$HOME_A/.config/opencode" "$HOME_A/.claude" "$HOME_A/.gemini"
CWD_A="$TMP/cwd-a"; mkdir -p "$CWD_A"
OUT="$(detect "$CWD_A" "$HOME_A" "$SAFE_PATH")"
echo "$OUT" | grep -qx "opencode"; check $? "detects opencode (binary + dir)"
echo "$OUT" | grep -qx "claude";   check $? "detects claude (binary + dir)"
echo "$OUT" | grep -qx "gemini";   check $? "detects gemini (dir)"

# Case 2 — project-only signal.
HOME_B="$TMP/home-b"; mkdir -p "$HOME_B"
CWD_B="$TMP/cwd-b"; mkdir -p "$CWD_B"; touch "$CWD_B/.cursorrules"
OUT2="$(detect "$CWD_B" "$HOME_B" "$EMPTY_BIN")"
echo "$OUT2" | grep -qx "cursor"; check $? "detects cursor from project file"
[ "$(echo "$OUT2" | grep -c .)" -eq 1 ]; check $? "project-only yields exactly one agent"

# Case 3 — explicit override wins.
OUT3="$( cd "$CWD_A" && HOME="$HOME_A" AAS_AGENTS="cursor,kiro" bash "$REPO_ROOT/scripts/agent-detect.sh" )"
[ "$OUT3" = "$(printf 'cursor\nkiro')" ]; check $? "AAS_AGENTS override wins"

# Case 4 — empty environment yields no agents.
HOME_C="$TMP/home-c"; mkdir -p "$HOME_C"; CWD_C="$TMP/cwd-c"; mkdir -p "$CWD_C"
OUT4="$(detect "$CWD_C" "$HOME_C" "$EMPTY_BIN")"
[ -z "$OUT4" ]; check $? "empty env → no agents"

# Case 5 — init-agents --list-agents.
LIST="$(HOME="$HOME_A" PATH="$SAFE_PATH" bash "$REPO_ROOT/scripts/init-agents.sh" --list-agents 2>&1)"
echo "$LIST" | grep -q "opencode"; check $? "--list-agents lists opencode"
echo "$LIST" | grep -q "claude";   check $? "--list-agents lists claude"
echo "$LIST" | grep -q "gemini";   check $? "--list-agents lists gemini"

# Case 6 — init-agents --check-env reports detected agents.
ENVOUT="$( cd "$CWD_A" && HOME="$HOME_A" AGENT_SKILLS_DIR="$TMP/none" PATH="$SAFE_PATH" bash "$REPO_ROOT/scripts/init-agents.sh" --check-env 2>&1 )"
echo "$ENVOUT" | grep -q "^agents="; check $? "--check-env prints agents="
echo "$ENVOUT" | grep -q "opencode"; check $? "--check-env includes opencode"

exit "$fail"
