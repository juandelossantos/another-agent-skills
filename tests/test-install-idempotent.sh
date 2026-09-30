#!/usr/bin/env bash
# test-install-idempotent.sh — re-running the skills install must be a no-op:
# no backup dirs, no churn when the installed skill already matches the source.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export AGENT_SKILLS_DIR="$TMP/oc"
export HOME="$TMP/home"
export AAS_AGENTS="cursor"   # no known skills path → only the canonical dir is exercised
mkdir -p "$HOME"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

bash "$REPO_ROOT/install.sh" --skills-only >/dev/null 2>&1; check $? "first run exits 0"
CANON="$AGENT_SKILLS_DIR/skills"
FIRST="$(find "$CANON" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')"

bash "$REPO_ROOT/install.sh" --skills-only >/dev/null 2>&1; check $? "second run exits 0"
SECOND="$(find "$CANON" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')"

BACKUPS="$(find "$CANON" -maxdepth 1 -name '*.backup.*' | wc -l | tr -d ' ')"
[ "$BACKUPS" -eq 0 ]; check $? "no backup dirs created on re-run (found $BACKUPS)"
[ "$FIRST" = "$SECOND" ]; check $? "skill count stable ($FIRST → $SECOND)"

# ── quarantine: a diverging real dir must be moved OUTSIDE the skills dir ──
export AAS_AGENTS="claude"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST/frontend-web"
echo "OLD CONTENT" > "$DEST/frontend-web/OLD.txt"

bash "$REPO_ROOT/install.sh" --skills-only >/dev/null 2>&1; check $? "install with a diverging skill exits 0"
[ -L "$DEST/frontend-web" ]; check $? "diverging skill replaced by a symlink"
[ -d "$HOME/.claude/skills.backups" ]; check $? "diverging skill quarantined outside the skills dir"
INLINE="$(find "$DEST" -maxdepth 1 -name '*.backup.*' | wc -l | tr -d ' ')"
[ "$INLINE" -eq 0 ]; check $? "no backup dirs inside the skills dir (found $INLINE)"

exit "$fail"
