#!/usr/bin/env bash
# agent-runner.sh — external runner for agent patches (Phase 15: capability boundary).
#
# The agent produces a patch. This runner — invoked by the HUMAN or a host, not
# by the agent — applies it, runs the test suite, and commits only if green. The
# commit capability stays outside the agent's tool budget.
#
# IMPORTANT: this is a reference, not a sandbox, and not a boundary on its own.
# It only helps if the agent cannot invoke this script (restricted tool budget /
# sandboxed host). If the agent can run it, it is convenience, not enforcement.
# Applying an untrusted patch can write hooks or scripts; run it inside a
# container or VM for untrusted input.
#
# Usage:
#   bash scripts/agent-runner.sh --patch <file|-> --message "msg" \
#     [--test-cmd "cmd"] [--sign] [--allow-dirty] [--dry-run]
#
# Exit: 0 committed (or dry-run passed), 1 failed (patch reverted, no commit).

set -euo pipefail

PATCH=""; MESSAGE=""; TEST_CMD=""; SIGN=false; ALLOW_DIRTY=false; DRY_RUN=false
while [ $# -gt 0 ]; do
  case "$1" in
    --patch)       PATCH="${2:-}"; shift 2 ;;
    --message)     MESSAGE="${2:-}"; shift 2 ;;
    --test-cmd)    TEST_CMD="${2:-}"; shift 2 ;;
    --sign)        SIGN=true; shift ;;
    --allow-dirty) ALLOW_DIRTY=true; shift ;;
    --dry-run)     DRY_RUN=true; shift ;;
    -h|--help)
      sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "agent-runner: unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -n "$PATCH" ]   || { echo "agent-runner: --patch is required (file or -)" >&2; exit 1; }
[ -n "$MESSAGE" ] || { echo "agent-runner: --message is required" >&2; exit 1; }

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
[ -n "$ROOT" ] || { echo "agent-runner: not inside a git repository" >&2; exit 1; }
cd "$ROOT"

if [ "$ALLOW_DIRTY" = false ] && [ -n "$(git status --porcelain)" ]; then
  echo "agent-runner: working tree is dirty. Commit/stash first, or pass --allow-dirty." >&2
  exit 1
fi

if [ -z "$TEST_CMD" ]; then
  if [ -f tests/run-all.sh ]; then
    TEST_CMD="bash tests/run-all.sh"
  else
    echo "agent-runner: no --test-cmd and no tests/run-all.sh (fail closed)." >&2
    exit 1
  fi
fi

TMP_PATCH=$(mktemp)
trap 'rm -f "$TMP_PATCH"' EXIT
if [ "$PATCH" = "-" ]; then cat > "$TMP_PATCH"; else cp "$PATCH" "$TMP_PATCH"; fi

if ! git apply --check "$TMP_PATCH" 2>/dev/null; then
  echo "agent-runner: patch does not apply cleanly." >&2
  exit 1
fi
git apply "$TMP_PATCH"

cleanup() {
  git apply -R "$TMP_PATCH" 2>/dev/null || true
}
trap 'cleanup; rm -f "$TMP_PATCH"' EXIT

echo "agent-runner: running: $TEST_CMD"
if ! bash -c "$TEST_CMD"; then
  echo "agent-runner: tests failed; patch reverted, no commit." >&2
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  echo "agent-runner: dry-run; patch applied and tests passed (reverting, no commit)."
  exit 0
fi

git add -A
if [ "$SIGN" = true ]; then
  git commit -S -m "$MESSAGE"
else
  git commit -m "$MESSAGE"
fi

trap - EXIT
rm -f "$TMP_PATCH"
echo "agent-runner: committed."
exit 0
