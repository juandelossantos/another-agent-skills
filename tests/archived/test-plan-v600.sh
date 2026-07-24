#!/usr/bin/env bash
# Test: PLAN.md has Phase 6 completion and v6.0.0 release plan

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "Phase 6.*Design Skill Integrity" "$ROOT/PLAN.md" && pass "PLAN.md: Phase 6 title" || fail "PLAN.md missing Phase 6"
grep -q "6.0.0" "$ROOT/PLAN.md" && pass "PLAN.md: v6.0.0" || fail "PLAN.md missing v6.0.0"
