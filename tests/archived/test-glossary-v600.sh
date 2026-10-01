#!/usr/bin/env bash
# Test: GLOSSARY.md removed OVERRIDE_APPROVED entry

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

grep -q "^### OVERRIDE_APPROVED" "$ROOT/GLOSSARY.md" && fail "GLOSSARY.md has OVERRIDE_APPROVED entry" || pass "GLOSSARY.md: OVERRIDE_APPROVED entry removed"
grep -q "current v6" "$ROOT/GLOSSARY.md" && pass "GLOSSARY.md: v6 ref" || fail "GLOSSARY.md missing v6 ref"
