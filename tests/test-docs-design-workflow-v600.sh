#!/usr/bin/env bash
# Test: docs/DESIGN-WORKFLOW.md updated (no "futuro" for now-implemented skills)

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "v6.0.0\|Phase 6\|implementado\|current\|✅" "$ROOT/docs/DESIGN-WORKFLOW.md" && pass "DESIGN-WORKFLOW.md updated" || fail "DESIGN-WORKFLOW.md not updated"
