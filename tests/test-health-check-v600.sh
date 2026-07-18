#!/usr/bin/env bash
# Test: HEALTH-CHECK.md shows HEALTHY status

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "HEALTHY" "$ROOT/HEALTH-CHECK.md" && pass "HEALTH-CHECK.md: HEALTHY" || fail "HEALTH-CHECK.md not HEALTHY"
grep -q "Phase 6" "$ROOT/HEALTH-CHECK.md" && pass "HEALTH-CHECK.md: Phase 6" || fail "HEALTH-CHECK.md missing Phase 6"
