#!/usr/bin/env bash
# Test: docs/design-review.html references design gates

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "design.*gate\|DESIGN.md\|design-gate\|Phase 6" "$ROOT/docs/design-review.html" && pass "design-review.html: Phase 6 ref" || fail "design-review.html missing Phase 6"
