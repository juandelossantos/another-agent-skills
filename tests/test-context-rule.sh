#!/usr/bin/env bash
# test-context-rule.sh — rules/common/context.md points at the relocated plugin source.
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$REPO_ROOT/rules/common/context.md"
fail=0
grep -q "plugins/agent-discipline/" "$DOC" && echo "  ✓ relocated source path" || { echo "  ✗ missing relocated path"; fail=1; }
if grep -q "(\.opencode/plugins/agent-discipline/)" "$DOC"; then echo "  ✗ stale old-path reference"; fail=1; else echo "  ✓ no stale old-path reference"; fi
exit "$fail"
