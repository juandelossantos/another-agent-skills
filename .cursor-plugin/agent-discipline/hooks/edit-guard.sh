#!/usr/bin/env bash
# edit-guard.sh — Claude Code hook: Structural integrity gate
# Calls the shared scripts/edit-guard.sh implementation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

exec bash "$REPO_ROOT/scripts/edit-guard.sh" "$@"
