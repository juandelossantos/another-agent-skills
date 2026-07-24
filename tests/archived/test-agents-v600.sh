#!/usr/bin/env bash
# Test: AGENTS.md references commit-msg v6 with no override

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "commit-msg hook v6" "$ROOT/AGENTS.md" && pass "AGENTS.md: v6 ref" || fail "AGENTS.md missing v6"
grep -q "no override" "$ROOT/AGENTS.md" && pass "AGENTS.md: no override" || fail "AGENTS.md missing no override"
