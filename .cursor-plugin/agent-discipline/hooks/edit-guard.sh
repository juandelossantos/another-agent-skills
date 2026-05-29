#!/usr/bin/env bash
# edit-guard.sh — Cursor hook: Structural integrity gate
# Calls the shared scripts/edit-guard.sh implementation

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

exec bash "${REPO_ROOT}/scripts/edit-guard.sh" "$@"
