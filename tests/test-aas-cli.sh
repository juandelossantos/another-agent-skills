#!/usr/bin/env bash
# test-aas-cli.sh — hermetic tests for the `aas` CLI (bin/aas + scripts/lib/aas.sh)
# covering Phase 9 P9.3 (install/upgrade/doctor/uninstall) and P9.4 (agent
# selection: --agents, TTY-only prompting, non-TTY never blocks).
#
# No network: upgrade uses a fake pinned release under a temp dir and a mocked
# `gh`. Install/doctor reuse the real scripts/init-agents.sh in a temp project.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

export HOME="$TMP/home"; mkdir -p "$HOME"
export AAS_HOME="$TMP/data"
export AAS_BIN_DIR="$TMP/bin"
unset AAS_AGENTS AAS_LATEST_VERSION
AAS="$REPO_ROOT/bin/aas"
REPO_VERSION="$(cat "$REPO_ROOT/VERSION")"

# ── 1. aas --version ─────────────────────────────────────────────────────────
OUT="$(bash "$AAS" --version 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "aas --version exits 0 (got $RC)"
[ "$OUT" = "$REPO_VERSION" ]; check $? "aas --version prints repo VERSION ($REPO_VERSION)"

# ── 2. aas install --agents claude (non-TTY: must never prompt) ──────────────
PROJ="$TMP/proj"; mkdir -p "$PROJ"
( cd "$PROJ" && bash "$AAS" install --agents claude </dev/null > "$TMP/install.log" 2>&1 )
RC=$?
[ "$RC" -eq 0 ]; check $? "aas install --agents claude exits 0 in non-TTY (got $RC)"
[ -f "$PROJ/AGENTS.md" ]; check $? "aas install runs the project install (AGENTS.md created)"
grep -q "Agents: claude" "$TMP/install.log"; check $? "--agents claude is threaded to the installer"
grep -q "Select agents" "$TMP/install.log"; check $([ $? -ne 0 ] && echo 0 || echo 1) "non-TTY install does not prompt"

# ── 3. aas install with no --agents in non-TTY also never blocks ─────────────
PROJ2="$TMP/proj2"; mkdir -p "$PROJ2"
( cd "$PROJ2" && bash "$AAS" install </dev/null > "$TMP/install2.log" 2>&1 )
RC=$?
[ "$RC" -eq 0 ]; check $? "aas install (auto, non-TTY) exits 0 (got $RC)"
grep -q "Select agents" "$TMP/install2.log"; check $([ $? -ne 0 ] && echo 0 || echo 1) "auto non-TTY install does not prompt"

# ── 4. Unknown agent in --agents is rejected ─────────────────────────────────
( cd "$PROJ" && bash "$AAS" install --agents bogus-agent </dev/null > "$TMP/bad.log" 2>&1 )
RC=$?
[ "$RC" -ne 0 ]; check $? "unknown --agents value rejected (got rc=$RC)"

# ── 4b. --agents all expands to every supported agent ────────────────────────
PROJ3="$TMP/proj3"; mkdir -p "$PROJ3"
( cd "$PROJ3" && bash "$AAS" install --agents all </dev/null > "$TMP/install3.log" 2>&1 )
RC=$?
[ "$RC" -eq 0 ]; check $? "aas install --agents all exits 0 (got $RC)"
grep -q "Agents: opencode" "$TMP/install3.log"; check $? "--agents all expands to the supported list"

# ── 5. aas doctor ────────────────────────────────────────────────────────────
OUT="$(bash "$AAS" doctor 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "aas doctor exits 0 (got $RC)"
echo "$OUT" | grep -q "^agents="; check $? "aas doctor reports detected agents (check-env)"

# ── 6. aas upgrade = atomic self-update from the latest pinned release ───────
# 6a. An "already installed" old version dir (contains the real CLI + lib).
OLD_VERSION="6.2.0"
OLD_DIR="$AAS_HOME/$OLD_VERSION"
mkdir -p "$OLD_DIR/bin" "$OLD_DIR/scripts/lib"
cp "$REPO_ROOT/bin/aas" "$OLD_DIR/bin/aas"; chmod +x "$OLD_DIR/bin/aas"
cp "$REPO_ROOT/scripts/lib/aas.sh" "$OLD_DIR/scripts/lib/aas.sh"
cp "$REPO_ROOT/scripts/agent-detect.sh" "$OLD_DIR/scripts/agent-detect.sh"
printf '%s\n' "$OLD_VERSION" > "$OLD_DIR/VERSION"
mkdir -p "$AAS_BIN_DIR"
ln -s "$OLD_DIR/bin/aas" "$AAS_BIN_DIR/aas"

# 6b. A fake release for a newer version (local dir + checksums).
NEW_VERSION="9.9.9"
REL="$TMP/releases"
NEW_ASSET="another-agent-skills-v${NEW_VERSION}.tar.gz"
NEW_DIR="$REL/v${NEW_VERSION}"
mkdir -p "$NEW_DIR"
NEW_SRC="$TMP/new-src"
mkdir -p "$NEW_SRC/bin" "$NEW_SRC/scripts/lib"
printf '%s\n' "$NEW_VERSION" > "$NEW_SRC/VERSION"
cp "$REPO_ROOT/bin/aas" "$NEW_SRC/bin/aas"; chmod +x "$NEW_SRC/bin/aas"
cp "$REPO_ROOT/scripts/lib/aas.sh" "$NEW_SRC/scripts/lib/aas.sh"
cp "$REPO_ROOT/scripts/agent-detect.sh" "$NEW_SRC/scripts/agent-detect.sh"
tar -czf "$NEW_DIR/$NEW_ASSET" -C "$NEW_SRC" .
( cd "$NEW_DIR" && sha256sum "$NEW_ASSET" > checksums.txt )

MOCKBIN="$TMP/mockbin"; mkdir -p "$MOCKBIN"
printf '#!/usr/bin/env bash\necho v%s\n' "$NEW_VERSION" > "$MOCKBIN/gh"
chmod +x "$MOCKBIN/gh"

export AAS_RELEASE_BASE_URL="$REL"
# Invoke through the symlink: bin/aas must resolve its own real path.
OUT="$(PATH="$MOCKBIN:$PATH" "$AAS_BIN_DIR/aas" upgrade 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "aas upgrade exits 0 (got $RC)"
echo "$OUT" | grep -q "$OLD_VERSION"; check $? "upgrade reports version before ($OLD_VERSION)"
echo "$OUT" | grep -q "$NEW_VERSION"; check $? "upgrade reports version after ($NEW_VERSION)"
[ -f "$AAS_HOME/$NEW_VERSION/VERSION" ]; check $? "upgrade installs the new version dir"
[ "$(readlink "$AAS_BIN_DIR/aas")" = "$AAS_HOME/$NEW_VERSION/bin/aas" ]; check $? "upgrade re-points the symlink atomically"
# Old version dir is preserved (upgrade is not uninstall).
[ -d "$AAS_HOME/$OLD_VERSION" ]; check $? "upgrade preserves the previous version dir"

# 6c. Idempotent: already on latest → reports up to date, no error.
OUT2="$(PATH="$MOCKBIN:$PATH" "$AAS_BIN_DIR/aas" upgrade 2>&1)"; RC=$?
[ "$RC" -eq 0 ]; check $? "second aas upgrade exits 0 (got $RC)"
echo "$OUT2" | grep -qiE "up[- ]?to[- ]?date|already"; check $? "second aas upgrade reports already up to date"

# ── 7. aas uninstall removes install root + symlink ──────────────────────────
bash "$AAS" uninstall > "$TMP/uninstall.log" 2>&1
RC=$?
[ "$RC" -eq 0 ]; check $? "aas uninstall exits 0 (got $RC)"
[ ! -e "$AAS_HOME" ]; check $? "aas uninstall removes install root"
[ ! -e "$AAS_BIN_DIR/aas" ] && [ ! -L "$AAS_BIN_DIR/aas" ]; check $? "aas uninstall removes symlink"

exit "$fail"
