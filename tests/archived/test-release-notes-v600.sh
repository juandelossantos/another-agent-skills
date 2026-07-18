#!/usr/bin/env bash
# Test: RELEASE-NOTES.md has v6.0.0 section

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "6.0.0" "$ROOT/RELEASE-NOTES.md" && pass "RELEASE-NOTES has v6.0.0" || fail "RELEASE-NOTES missing v6.0.0"
grep -q "Phase 6" "$ROOT/RELEASE-NOTES.md" && pass "RELEASE-NOTES mentions Phase 6" || fail "RELEASE-NOTES missing Phase 6"
grep -q "Design Skill Integrity" "$ROOT/RELEASE-NOTES.md" && pass "RELEASE-NOTES has Phase 6 title" || fail "RELEASE-NOTES missing Phase 6 title"
