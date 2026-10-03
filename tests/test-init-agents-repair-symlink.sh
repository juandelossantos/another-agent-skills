#!/usr/bin/env bash
# test-init-agents-repair-symlink.sh — init-agents must never write THROUGH an
# agent-config symlink (Phase 9/P9.7/P9.8).
#
# A legacy project can have `AGENTS.md` as a symlink (e.g. to an absolute path
# outside the project). `merge_into_file` appended the footer with `cat >>`,
# which follows the symlink and mutates the file it points at — silently
# contaminating a user's file outside the project. `--repair` is documented as
# non-destructive ("never loses a user's AGENTS.md"); it must materialize the
# symlink into a real project file instead.
#
# Hermetic: a minimal fake framework, temp projects, no network.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

export HOME="$TMP/home"; mkdir -p "$HOME"
unset AAS_DIR ANOTHER_AGENT_SKILLS_DIR AAS_AGENTS 2>/dev/null || true

FW="$TMP/fw"; mkdir -p "$FW/scripts/git-hooks" "$FW/skills/self-improvement"
cp "$REPO_ROOT/scripts/init-agents.sh" "$FW/scripts/init-agents.sh"
cp "$REPO_ROOT/scripts/aas-resolve.sh" "$FW/scripts/aas-resolve.sh"
cp "$REPO_ROOT/scripts/agent-detect.sh" "$FW/scripts/agent-detect.sh"
cp "$REPO_ROOT/VERSION" "$FW/VERSION"
cp "$REPO_ROOT/AGENTS.md" "$FW/AGENTS.md"
cp "$REPO_ROOT/skills/self-improvement/SKILL.md" "$FW/skills/self-improvement/SKILL.md"
: > "$FW/scripts/git-hooks/pre-commit"
# check-update must not run (keep the test offline/deterministic).
cat > "$FW/scripts/check-update.sh" <<'CANARY'
#!/usr/bin/env bash
exit 0
CANARY
INIT="$FW/scripts/init-agents.sh"

# ── 1. --repair with AGENTS.md symlinked to an EXTERNAL file ─────────────────
EXT="$TMP/external-AGENTS.md"
printf '# External user rules\n\nDO NOT TOUCH.\n' > "$EXT"
EXT_BEFORE="$(cat "$EXT")"
P1="$TMP/p1"; mkdir -p "$P1"; git -C "$P1" init -q
ln -s "$EXT" "$P1/AGENTS.md"
( cd "$P1" && bash "$INIT" --repair ) > "$TMP/p1.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "--repair exits 0 (got rc=$RC)"
[ "$(cat "$EXT")" = "$EXT_BEFORE" ]; check $? "external file is NOT modified (no write-through)"
[ ! -L "$P1/AGENTS.md" ]; check $? "project AGENTS.md is now a regular file"
[ -f "$P1/AGENTS.md" ]; check $? "project AGENTS.md exists as a file"
grep -q 'DO NOT TOUCH.' "$P1/AGENTS.md"; check $? "user content is preserved in the project"
grep -q 'another-agent-skills-rules' "$P1/AGENTS.md"; check $? "AAS footer merged into the project file"

# ── 2. Normal run with a symlinked AGENTS.md also must not write through ─────
EXT2="$TMP/external2.md"
printf '# Another external file\n' > "$EXT2"
EXT2_BEFORE="$(cat "$EXT2")"
P2="$TMP/p2"; mkdir -p "$P2"; git -C "$P2" init -q
ln -s "$EXT2" "$P2/AGENTS.md"
( cd "$P2" && bash "$INIT" ) > "$TMP/p2.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "normal run exits 0 (got rc=$RC)"
[ "$(cat "$EXT2")" = "$EXT2_BEFORE" ]; check $? "normal run does NOT modify the symlink target"
[ ! -L "$P2/AGENTS.md" ] && grep -q 'another-agent-skills-rules' "$P2/AGENTS.md"; check $? "normal run materializes a real AGENTS.md"

# ── 3. Dangling AGENTS.md symlink: no write outside the project ──────────────
P3="$TMP/p3"; mkdir -p "$P3"; git -C "$P3" init -q
ln -s "$TMP/does-not-exist-target.md" "$P3/AGENTS.md"
( cd "$P3" && bash "$INIT" ) > "$TMP/p3.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "dangling-symlink run exits 0 (got rc=$RC)"
[ ! -e "$TMP/does-not-exist-target.md" ]; check $? "no file created at the dangling target"
[ -f "$P3/AGENTS.md" ] && [ ! -L "$P3/AGENTS.md" ]; check $? "dangling symlink replaced with a real AGENTS.md"

exit "$fail"
