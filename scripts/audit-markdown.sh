#!/usr/bin/env bash
# audit-markdown.sh — thin wrapper over universal-audit.sh (P1.3)
#
# Preserves the name + exit-code semantics every consumer depends on
# (self-improvement skill, HEALTH-CHECK, pre-commit Test chain). All logic
# now lives in universal-audit.sh (config-driven, subshell-bug-free, real JSON).
#
# Usage unchanged:  bash scripts/audit-markdown.sh [--json]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG="$REPO_ROOT/.audit-config.json"

if [ ! -f "$CONFIG" ]; then
  echo "audit-markdown.sh: .audit-config.json not found at $CONFIG" >&2
  echo "  Run: bash scripts/universal-audit.sh --init" >&2
  exit 2
fi

exec bash "$SCRIPT_DIR/universal-audit.sh" --config "$CONFIG" "$@"
