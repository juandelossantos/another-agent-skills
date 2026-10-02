#!/usr/bin/env bash
# test-release-notes-v620.sh — RELEASE-NOTES.md has the v6.2.0 (Phase 7) section.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$REPO_ROOT/RELEASE-NOTES.md"

fail=0
grep -q "## 6.2.0" "$DOC" && echo "  ✓ v6.2.0 section" || { echo "  ✗ missing v6.2.0"; fail=1; }
grep -q "Dual-contract plugin" "$DOC" && echo "  ✓ dual-contract note" || { echo "  ✗ missing dual-contract"; fail=1; }
grep -q "Philosophy A" "$DOC" && echo "  ✓ philosophy A note" || { echo "  ✗ missing philosophy A"; fail=1; }
grep -q "Multi-agent detection" "$DOC" && echo "  ✓ multi-agent note" || { echo "  ✗ missing multi-agent"; fail=1; }

exit "$fail"
