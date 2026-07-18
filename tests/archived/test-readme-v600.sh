#!/usr/bin/env bash
# Test: README.md contains correct v6.0.0 references

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "v6.0.0" "$ROOT/README.md" && pass "README references v6.0.0" || fail "README missing v6.0.0 ref"
grep -q "15 gates" "$ROOT/README.md" && pass "README mentions 15 gates" || fail "README missing 15 gates"
grep -q "Phase 6" "$ROOT/README.md" && pass "README mentions Phase 6" || fail "README missing Phase 6"
