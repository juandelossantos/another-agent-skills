#!/usr/bin/env bash
# Test: index.html + docs/index.html have correct v6.0.0 refs

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

# i18n has 15 gates (source of truth for index.html rendering)
grep -q "15 gates\|15 puertas" "$ROOT/i18n/en.json" && pass "i18n/en.json: 15 gates" || fail "i18n/en.json missing 15 gates"
grep -q "Gate 0" "$ROOT/i18n/en.json" && pass "i18n/en.json: Gate 0" || fail "i18n/en.json missing Gate 0"

# Docs index.html (version table)
grep -q "v6.0.0" "$ROOT/docs/index.html" && pass "docs/index.html: v6.0.0" || fail "docs/index.html missing v6.0.0"
