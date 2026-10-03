#!/usr/bin/env bash
# test-init-agents-dry-run.sh — `init-agents.sh --dry-run` must be truly
# side-effect-free (Phase 9/P9.7). main() ran scripts/check-update.sh BEFORE the
# dry-run branch: that script can hit the network (`git ls-remote`, with no
# timeout) and can even prompt on stdin. A dry run must neither reach out nor
# mutate. This pins the ordering with a canary.
#
# Hermetic: a minimal fake framework whose check-update.sh only writes a marker.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

export HOME="$TMP/home"; mkdir -p "$HOME"
unset AAS_DIR ANOTHER_AGENT_SKILLS_DIR AAS_AGENTS 2>/dev/null || true

# ── Minimal fake framework (resolver + init-agents need these files) ─────────
FW="$TMP/fw"
mkdir -p "$FW/scripts/git-hooks" "$FW/skills"
cp "$REPO_ROOT/scripts/init-agents.sh" "$FW/scripts/init-agents.sh"
cp "$REPO_ROOT/scripts/aas-resolve.sh" "$FW/scripts/aas-resolve.sh"
cp "$REPO_ROOT/scripts/agent-detect.sh" "$FW/scripts/agent-detect.sh"
cp "$REPO_ROOT/VERSION" "$FW/VERSION"
cp "$REPO_ROOT/AGENTS.md" "$FW/AGENTS.md"
: > "$FW/scripts/git-hooks/pre-commit"
MARKER="$TMP/check-update-ran"
cat > "$FW/scripts/check-update.sh" <<'CANARY'
#!/usr/bin/env bash
: > "${AAS_CHECK_UPDATE_MARKER:?}"
CANARY
chmod +x "$FW/scripts/check-update.sh"
export AAS_CHECK_UPDATE_MARKER="$MARKER"

# ── 1. --dry-run must not run check-update.sh and must not write files ───────
PROJ="$TMP/proj"; mkdir -p "$PROJ"
( cd "$PROJ" && bash "$FW/scripts/init-agents.sh" --dry-run ) > "$TMP/dry.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "--dry-run exits 0 (got rc=$RC)"
[ ! -e "$MARKER" ]; check $? "--dry-run does NOT run check-update.sh (no network/prompt)"
[ ! -e "$PROJ/AGENTS.md" ] && [ ! -e "$PROJ/.aas" ]; check $? "--dry-run writes nothing into the project"

# ── 2. A real (non-dry) run still runs check-update.sh (canary wiring) ───────
PROJ2="$TMP/proj2"; mkdir -p "$PROJ2"
( cd "$PROJ2" && bash "$FW/scripts/init-agents.sh" ) > "$TMP/real.log" 2>&1; RC=$?
[ "$RC" -eq 0 ]; check $? "normal run exits 0 (got rc=$RC)"
[ -e "$MARKER" ]; check $? "normal run DOES run check-update.sh"
[ -f "$PROJ2/AGENTS.md" ]; check $? "normal run creates AGENTS.md"

exit "$fail"
