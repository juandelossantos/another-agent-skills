#!/usr/bin/env bash
# Test: PLAN.md has Phase 7 plan and is the single source of truth

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "Phase 7" "$ROOT/PLAN.md" && pass "PLAN.md: Phase 7" || fail "PLAN.md missing Phase 7"
grep -q "v7.0.0" "$ROOT/PLAN.md" && pass "PLAN.md: v7.0.0" || fail "PLAN.md missing v7.0.0"
grep -q "7.10" "$ROOT/PLAN.md" && pass "PLAN.md: 10 tasks" || fail "PLAN.md missing 10 tasks"
grep -q "Cross-Platform Harness Parity" "$ROOT/PLAN.md" && pass "PLAN.md: Phase 7 title" || fail "PLAN.md missing Phase 7 title"
