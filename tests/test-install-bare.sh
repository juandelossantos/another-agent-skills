#!/usr/bin/env bash
# test-install-bare.sh — bare `install.sh` (no flags) must run to completion
# under `set -e` even when a shell-config branch increments its counter from 0.
# Regression: `((count++))` evaluates to 0 (exit 1) at count=0 and, under
# `set -e`, aborted the run mid-way before "All done!".
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

export HOME="$TMP/home"
# Control SHELL so only .zshrc is processed: with SHELL=bash (as in CI), install.sh
# also creates a .bashrc, making the counter 2. Deterministic → always 1.
unset SHELL
export AGENT_SKILLS_DIR="$TMP/oc"
export CLAUDE_SKILLS_DIR="$TMP/claude-skills"
export AAS_AGENTS="opencode"   # deterministic: no other agents to detect
mkdir -p "$HOME"
touch "$HOME/.zshrc"

# Stub `git` so the remote-skill step never touches the network: `clone`
# materializes a tiny fake remote, `pull` is a no-op, everything else passes
# through to the real binary.
REAL_GIT="$(command -v git)"
export REAL_GIT
SHIM="$TMP/bin"
mkdir -p "$SHIM"
cat > "$SHIM/git" <<'GIT'
#!/usr/bin/env bash
case "${1:-}" in
  clone)
    dir="${@: -1}"
    mkdir -p "$dir/.opencode/skills/official-dummy"
    printf '# dummy\n' > "$dir/.opencode/skills/official-dummy/SKILL.md"
    ;;
  pull) exit 0 ;;
  *) exec "$REAL_GIT" "$@" ;;
esac
GIT
chmod +x "$SHIM/git"

LOG="$TMP/install.log"
PATH="$SHIM:$PATH" bash "$REPO_ROOT/install.sh" >"$LOG" 2>&1
RC=$?
[ "$RC" -eq 0 ]; check $? "bare install.sh exits 0 (got $RC)"
grep -q "All done!" "$LOG"; check $? "bare install.sh reaches 'All done!'"
grep -q "Shell configuration updated (1 file(s))." "$LOG"; check $? "shell config counter reached 1 (not aborted at 0)"
grep -q "another-agent-skills-config" "$HOME/.zshrc"; check $? "managed block written to .zshrc"
grep -q "Installed agent-discipline plugin" "$LOG"; check $? "OpenCode plugin installed"

# The plugin must be installed exactly once per run (no duplicate invocation).
INSTALLS="$(grep -c "Installing OpenCode agent-discipline plugin" "$LOG" || true)"
[ "$INSTALLS" -eq 1 ]; check $? "OpenCode plugin installed exactly once (got $INSTALLS)"

if [ "$RC" -ne 0 ]; then
  echo "  --- install.sh output ---"
  sed 's/^/  /' "$LOG"
  echo "  --- end output ---"
fi

exit "$fail"
