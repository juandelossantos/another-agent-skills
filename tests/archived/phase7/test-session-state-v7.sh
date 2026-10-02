#!/usr/bin/env bash
# test-session-state-v7.sh — development/SESSION_STATE.md carries the current handoff.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$REPO_ROOT/development/SESSION_STATE.md"

fail=0
grep -q "Phase 7: OpenCode v1/v2 Plugin Compatibility" "$DOC" && echo "  ✓ Phase 7 handoff header" || { echo "  ✗ missing Phase 7 header"; fail=1; }
grep -q "P7.4" "$DOC" && echo "  ✓ next step P7.4 recorded" || { echo "  ✗ missing P7.4"; fail=1; }
grep -q "fix/opencode-v2-plugin-compat" "$DOC" && echo "  ✓ branch recorded" || { echo "  ✗ missing branch"; fail=1; }

exit "$fail"
