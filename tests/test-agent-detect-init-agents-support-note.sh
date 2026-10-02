#!/usr/bin/env bash
# test-agent-detect-support-note.sh — agent_support_note() flags versions the
# installer cannot support (OpenCode v1 < 1.18.29 → no dual-contract server()).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/scripts/agent-detect.sh"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }
note() { bash -c 'source "$1"; agent_support_note "$2" "$3"' _ "$SRC" "$1" "$2"; }

[ -n "$(note opencode 1.18.20)" ]; check $? "flags opencode 1.18.20 (< 1.18.29)"
[ -n "$(note opencode 1.0.0)" ];   check $? "flags opencode 1.0.0"
[ -z "$(note opencode 1.18.29)" ]; check $? "accepts opencode 1.18.29"
[ -z "$(note opencode 2.0.21)" ];  check $? "accepts opencode 2.0.21"
[ -z "$(note opencode '')" ];      check $? "empty version → no note"
[ -z "$(note claude 2.1.282)" ];   check $? "claude → no note"

exit "$fail"
