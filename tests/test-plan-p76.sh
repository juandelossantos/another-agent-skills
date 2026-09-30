#!/usr/bin/env bash
# test-plan-p76.sh — PLAN.md records P7.6 (per-agent skills install) and B2
# (framework self-hosting hook integrity).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN="$REPO_ROOT/PLAN.md"

fail=0
grep -q "P7.6" "$PLAN" && echo "  ✓ PLAN.md references P7.6" || { echo "  ✗ PLAN.md missing P7.6"; fail=1; }
grep -q "agent_skills_dir\|agent→skills" "$PLAN" && echo "  ✓ PLAN.md documents the skills-path mapping" || { echo "  ✗ PLAN.md missing skills-path mapping"; fail=1; }
grep -q "B2" "$PLAN" && echo "  ✓ PLAN.md references B2" || { echo "  ✗ PLAN.md missing B2"; fail=1; }

exit "$fail"
