#!/usr/bin/env bash
# Test: Memory.md references current hook version

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "v6 now" "$ROOT/skills/engineering-fundamentals/guides/Memory.md" && pass "Memory.md: v6 ref" || fail "Memory.md missing v6 ref"
