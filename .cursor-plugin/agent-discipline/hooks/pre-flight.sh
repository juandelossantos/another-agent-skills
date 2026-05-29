#!/usr/bin/env bash
# pre-flight.sh — Claude Code hook: Git state check before risky commands
# Calls the shared scripts/pre-flight.sh implementation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

exec bash "$REPO_ROOT/scripts/pre-flight.sh" "$@"
