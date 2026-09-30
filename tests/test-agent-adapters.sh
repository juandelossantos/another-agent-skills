#!/usr/bin/env bash
# test-agent-adapters.sh — docs/AGENT-ADAPTERS.md reflects the current design:
# philosophy A, the dual contract, the relocated source, and the per-agent matrix.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$REPO_ROOT/docs/AGENT-ADAPTERS.md"

fail=0
grep -q "plugins/agent-discipline" "$DOC" && echo "  ✓ relocated source path" || { echo "  ✗ missing relocated source path"; fail=1; }
grep -qi "philosophy A" "$DOC" && echo "  ✓ philosophy A documented" || { echo "  ✗ missing philosophy A"; fail=1; }
grep -q "Duplicate plugin ID" "$DOC" && echo "  ✓ explains the duplicate-id constraint" || { echo "  ✗ missing duplicate-id note"; fail=1; }
grep -qi "dual-contract" "$DOC" && echo "  ✓ dual contract documented" || { echo "  ✗ missing dual contract"; fail=1; }
grep -q "~/.claude/skills" "$DOC" && echo "  ✓ per-agent matrix present" || { echo "  ✗ missing per-agent matrix"; fail=1; }

exit "$fail"
