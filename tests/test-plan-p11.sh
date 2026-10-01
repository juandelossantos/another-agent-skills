#!/usr/bin/env bash
# test-plan-p11.sh — PLAN.md records Phase 11 (Astro + Starlight docs site).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "## Phase 11: Docs site — Astro + Starlight" "$PLAN" && echo "  ✓ Phase 11 heading" || { echo "  ✗ missing Phase 11"; fail=1; }
grep -q "sin build" "$PLAN" && echo "  ✓ build boundary documented" || { echo "  ✗ missing build boundary"; fail=1; }
grep -q "P11.4" "$PLAN" && echo "  ✓ i18n routing task present" || { echo "  ✗ missing i18n routing task"; fail=1; }

exit "$fail"
