#!/usr/bin/env bash
# test-agent-detect-install-guardrails.sh — agent_guardrails_kind mapping
# (scripts/agent-detect.sh) and install.sh --guardrails-only for Claude.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# ── mapping ──
MAP="$(bash -c 'source "$1"; agent_guardrails_kind opencode; agent_guardrails_kind claude; agent_guardrails_kind gemini' _ "$REPO_ROOT/scripts/agent-detect.sh")"
[ "$MAP" = "$(printf 'plugin\nhooks')" ]; check $? "agent_guardrails_kind: opencode=plugin, claude=hooks, gemini=empty"

# ── install guardrails for claude ──
export AGENT_SKILLS_DIR="$TMP/oc"
export HOME="$TMP/home"
export AAS_AGENTS="claude"
mkdir -p "$HOME/.claude"
echo '{"theme":"dark","hooks":{"PreToolUse":[]}}' > "$HOME/.claude/settings.json"

bash "$REPO_ROOT/install.sh" --guardrails-only >/dev/null 2>&1; check $? "guardrails-only exits 0"

[ -f "$HOME/.claude/hooks/agent-discipline/commit-approval.sh" ]; check $? "claude guardrail hook installed"
[ -x "$HOME/.claude/hooks/agent-discipline/commit-approval.sh" ]; check $? "claude guardrail hook executable"

jq -e '.hooks.PreToolUse[] | select(.matcher=="Bash") | .hooks[] | select(.command | test("agent-discipline/commit-approval.sh"))' "$HOME/.claude/settings.json" >/dev/null 2>&1; check $? "hook registered in settings.json"
jq -e '.theme == "dark"' "$HOME/.claude/settings.json" >/dev/null 2>&1; check $? "existing settings preserved"

# ── idempotent: a second run must not duplicate the registration ──
bash "$REPO_ROOT/install.sh" --guardrails-only >/dev/null 2>&1
N="$(jq '[.hooks.PreToolUse[] | .hooks[] | select(.command | test("agent-discipline/commit-approval.sh"))] | length' "$HOME/.claude/settings.json")"
[ "$N" = "1" ]; check $? "idempotent (1 registration, got $N)"

exit "$fail"
