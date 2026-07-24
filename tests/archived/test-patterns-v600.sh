#!/usr/bin/env bash
# Test: PATTERNS.md updated design gate and commit manifest patterns

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "no override" "$ROOT/PATTERNS.md" && pass "PATTERNS.md: no override" || fail "PATTERNS.md missing no override"
grep -q "17-section" "$ROOT/PATTERNS.md" && pass "PATTERNS.md: 17-section schema" || fail "PATTERNS.md missing 17-section"
