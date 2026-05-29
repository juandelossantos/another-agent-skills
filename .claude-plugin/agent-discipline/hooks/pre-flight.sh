#!/usr/bin/env bash
# pre-flight.sh — Claude Code hook: Git state check before risky commands
# Calls the shared scripts/pre-flight.sh implementation

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

exec bash "${REPO_ROOT}/scripts/pre-flight.sh" "$@"
