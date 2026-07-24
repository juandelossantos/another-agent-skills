#!/usr/bin/env bash
# Test: PROGRESS_STATUS.md reflects Phase 7

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "Phase 7" "$ROOT/PROGRESS_STATUS.md" && pass "PROGRESS_STATUS: Phase 7" || fail "PROGRESS_STATUS missing Phase 7"
