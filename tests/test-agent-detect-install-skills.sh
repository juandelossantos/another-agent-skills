#!/usr/bin/env bash
# test-agent-detect-install-skills.sh — the agent→skills-dir mapping
# (scripts/agent-detect.sh) and per-agent skills install
# (install.sh --skills-only).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# ── agent_skills_dir mapping ──
MAP="$(bash -c 'source "$1"; agent_skills_dir claude; agent_skills_dir gemini; agent_skills_dir opencode; agent_skills_dir cursor' _ "$REPO_ROOT/scripts/agent-detect.sh")"
EXPECTED="$(printf '.claude/skills\n.gemini/skills\n.config/opencode/skills')"
[ "$MAP" = "$EXPECTED" ]; check $? "agent_skills_dir maps known agents, empty for unknown"

# ── per-agent skills install ──
export AGENT_SKILLS_DIR="$TMP/oc"
export HOME="$TMP/home"
export AAS_AGENTS="claude,gemini"
mkdir -p "$HOME"

bash "$REPO_ROOT/install.sh" --skills-only >/dev/null 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "install --skills-only exits 0"

[ -f "$AGENT_SKILLS_DIR/skills/frontend-web/SKILL.md" ]; check $? "canonical skills installed (opencode)"
[ -e "$HOME/.claude/skills/frontend-web/SKILL.md" ]; check $? "claude skills installed"
[ -e "$HOME/.gemini/skills/frontend-web/SKILL.md" ]; check $? "gemini skills installed"

# ── idempotency: second run must not duplicate entries ──
BEFORE="$(find "$HOME/.claude/skills" -maxdepth 1 -mindepth 1 | wc -l | tr -d ' ')"
bash "$REPO_ROOT/install.sh" --skills-only >/dev/null 2>&1
AFTER="$(find "$HOME/.claude/skills" -maxdepth 1 -mindepth 1 | wc -l | tr -d ' ')"
[ "$BEFORE" = "$AFTER" ]; check $? "idempotent (claude entries: $BEFORE → $AFTER)"

# ── agent without a known skills path is skipped cleanly ──
AAS_AGENTS="cursor" bash "$REPO_ROOT/install.sh" --skills-only >/dev/null 2>&1; check $? "unknown-path agent skipped cleanly"

exit "$fail"
