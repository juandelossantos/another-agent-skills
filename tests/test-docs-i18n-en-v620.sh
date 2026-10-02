#!/usr/bin/env bash
# test-docs-i18n-en-v620.sh — docs/i18n/en.json references v6.2.0.
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
F="$REPO_ROOT/docs/i18n/en.json"
fail=0
jq -e . "$F" >/dev/null 2>&1 && echo "  ✓ valid JSON" || { echo "  ✗ invalid JSON"; fail=1; }
grep -q "What's New in v6.2.0" "$F" && echo "  ✓ whatsNew = v6.2.0" || { echo "  ✗ whatsNew not updated"; fail=1; }
exit "$fail"
