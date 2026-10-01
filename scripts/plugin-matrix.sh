#!/usr/bin/env bash
# plugin-matrix.sh — opt-in compatibility matrix for the agent-discipline plugin.
#
# Default: report the system OpenCode + plugin state (no network).
# --with-v1: also install opencode-ai@<V1_VERSION> (v1 latest) into a temp prefix
#            and report its version (network).
#
# Honest limit: a full v1 runtime session needs model credentials, so this checks
# version + load, not a model turn. v1 enforcement is covered by the contract
# test that drives plugin.server().
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
V1_VERSION="${V1_VERSION:-1.18.34}"

echo "=== agent-discipline plugin compatibility matrix ==="

echo "--- system (v2) ---"
if command -v opencode >/dev/null 2>&1; then
  echo "opencode: $(opencode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  ( cd "$REPO_ROOT" && bash scripts/init-agents.sh --check-env 2>/dev/null | grep -E '^(agents|agent:|agent-discipline|opencode)' )
else
  echo "opencode: not found"
fi

if [ "${1:-}" = "--with-v1" ]; then
  echo "--- v1 (opencode-ai@${V1_VERSION}, isolated prefix) ---"
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found — cannot install v1"
    exit 1
  fi
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  if npm install --silent --prefix "$TMP" "opencode-ai@${V1_VERSION}" >/dev/null 2>&1; then
    BIN="$TMP/node_modules/.bin/opencode"
    if [ -x "$BIN" ]; then
      echo "v1 opencode: $("$BIN" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    else
      echo "v1 package installed but no opencode binary found (npm packaging differs)"
    fi
  else
    echo "could not install opencode-ai@${V1_VERSION}"
    exit 1
  fi
else
  echo "(pass --with-v1 to also install OpenCode v1 in an isolated prefix)"
fi
