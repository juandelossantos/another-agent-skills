#!/usr/bin/env bash
# Test: docs/enforcement.html has correct gate counts and versions

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "15 checks\|15 gates\|15 pre-commit" "$ROOT/docs/enforcement.html" && pass "enforcement.html: 15 checks" || fail "enforcement.html missing 15 checks"
grep -q "Commit-Msg Gate (v6)" "$ROOT/docs/enforcement.html" && pass "enforcement.html: commit-msg v6" || fail "enforcement.html missing v6 ref"
