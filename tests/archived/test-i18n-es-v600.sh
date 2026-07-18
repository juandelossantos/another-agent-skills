#!/usr/bin/env bash
# Test: i18n/es.json + docs/i18n/es.json have v6.0.0 content

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "15 puertas\|15 gates\|v6.0.0\|6.0.0\|Gate 0" "$ROOT/i18n/es.json" && pass "i18n/es.json: updated" || fail "i18n/es.json not updated"
grep -q "v6.0.0\|6.0.0" "$ROOT/docs/i18n/es.json" && pass "docs/i18n/es.json: v6.0.0" || fail "docs/i18n/es.json missing v6.0.0"
