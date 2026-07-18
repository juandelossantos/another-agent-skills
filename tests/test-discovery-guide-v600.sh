#!/usr/bin/env bash
# Test: DISCOVERY-GUIDE.md renamed from Visual Frontend Mastery

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

head -1 "$ROOT/skills/engineering-fundamentals/guides/DISCOVERY-GUIDE.md" | grep -q "Design Discovery Guide" && pass "DISCOVERY-GUIDE.md: title updated" || fail "DISCOVERY-GUIDE.md title wrong"
