#!/usr/bin/env bash
# Test: HEALTH-CHECK.md reflects Phase 7 start

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "Phase 7" "$ROOT/HEALTH-CHECK.md" && pass "HEALTH-CHECK: Phase 7" || fail "HEALTH-CHECK missing Phase 7"
