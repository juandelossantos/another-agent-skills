#!/usr/bin/env bash
# Test: i18n/en.json + docs/i18n/en.json have v6.0.0 content

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "15 gates" "$ROOT/i18n/en.json" && pass "i18n/en.json: 15 gates" || fail "i18n/en.json missing 15 gates"
grep -q "v6.0.0\|6.0.0" "$ROOT/docs/i18n/en.json" && pass "docs/i18n/en.json: v6.0.0" || fail "docs/i18n/en.json missing v6.0.0"
