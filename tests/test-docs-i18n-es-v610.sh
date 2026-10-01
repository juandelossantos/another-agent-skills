#!/usr/bin/env bash
# test-docs-i18n-es-v610.sh — docs/i18n/es.json references v6.1.0.
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
F="$REPO_ROOT/docs/i18n/es.json"
fail=0
jq -e . "$F" >/dev/null 2>&1 && echo "  ✓ valid JSON" || { echo "  ✗ invalid JSON"; fail=1; }
grep -q "Novedades en v6.1.0" "$F" && echo "  ✓ whatsNew = v6.1.0" || { echo "  ✗ whatsNew not updated"; fail=1; }
exit "$fail"
