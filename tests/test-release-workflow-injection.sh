#!/usr/bin/env bash
# test-release-workflow-injection.sh — release.yml (Phase 9/P9.1) must not
# interpolate untrusted GitHub contexts directly into `run:` shell scripts.
#
# `TAG="${{ github.event.inputs.tag }}"` is expanded by the runner BEFORE bash
# parses it, so a value like `"; rm -rf / #` executes. The tag (workflow_dispatch
# input or a ref name) must arrive via `env:` and be referenced as `$TAG`.
# Homebrew was dropped (not planned), so release.yml must carry no Homebrew
# surface at all.
#
# Static analysis + Ruby YAML parse — no network, no CI.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WF="$REPO_ROOT/.github/workflows/release.yml"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=$((fail + 1)); fi; }

echo ""
echo "release.yml — script injection + secret scoping"
echo "───────────────────────────────────────────────"

[ -f "$WF" ]; check $? "release.yml exists"

# ── YAML is valid ────────────────────────────────────────────────────────────
ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$WF" >/dev/null 2>&1; check $? "release.yml parses as YAML"

# ── No ${{ }} interpolation inside any run: block ────────────────────────────
ruby -ryaml -e '
  doc = YAML.load_file(ARGV[0])
  steps = doc.dig("jobs", "release", "steps") || []
  bad = steps.select { |s| s["run"].is_a?(String) && s["run"].include?("${{") }
  exit(bad.empty? ? 0 : 1)
' "$WF" 2>/dev/null; check $? "no \${{ }} interpolation inside any run: block"

# ── The untrusted tag is not interpolated at all (belt + braces) ─────────────
! grep -qE 'TAG="\$\{\{ *github\.(event\.inputs\.tag|ref_name)' "$WF"; check $? "tag is not interpolated into a shell assignment"

# ── The tag arrives via env and is referenced as $TAG ────────────────────────
grep -qE 'INPUT_TAG: \$\{\{ github\.event\.inputs\.tag \}\}' "$WF"; check $? "workflow_dispatch tag passed via env"
grep -qE 'REF_NAME: \$\{\{ github\.ref_name \}\}' "$WF"; check $? "ref_name passed via env"

# ── No Homebrew surface remains (dropped — not planned) ──────────────────────
! grep -qi 'HOMEBREW_TAP' "$WF"; check $? "release.yml has no HOMEBREW_TAP secret"
! grep -qi 'Homebrew' "$WF"; check $? "release.yml has no Homebrew step"

echo ""
[ "$fail" -gt 0 ] && { echo "  $fail failed"; exit 1; }
echo "  all checks passed"
exit 0
