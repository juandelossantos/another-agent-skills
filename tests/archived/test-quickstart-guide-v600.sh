#!/usr/bin/env bash
# Test: docs/quickstart-guide.html has updated gate counts

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "15 gates\|all 15\|Gate 15" "$ROOT/docs/quickstart-guide.html" && pass "quickstart: gate count updated" || fail "quickstart missing 15 gate ref"
