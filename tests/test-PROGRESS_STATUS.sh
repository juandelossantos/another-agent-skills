#!/usr/bin/env bash
# test-progress-status-v610.sh — PROGRESS_STATUS.md header reflects v6.1.0.
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$REPO_ROOT/PROGRESS_STATUS.md"
fail=0
grep -q "Current version:\*\* 6.1.0" "$DOC" && echo "  ✓ current version 6.1.0" || { echo "  ✗ version not updated"; fail=1; }
grep -q "Phase 7 complete" "$DOC" && echo "  ✓ Phase 7 status" || { echo "  ✗ status not updated"; fail=1; }
exit "$fail"
