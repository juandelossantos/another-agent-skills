#!/usr/bin/env bash
# test-release-workflow-injection.sh — release.yml (Phase 9/P9.1) must not
# interpolate untrusted GitHub contexts directly into `run:` shell scripts.
#
# `TAG="${{ github.event.inputs.tag }}"` is expanded by the runner BEFORE bash
# parses it, so a value like `"; rm -rf / #` executes. The tag (workflow_dispatch
# input or a ref name) must arrive via `env:` and be referenced as `$TAG`.
# Likewise the optional Homebrew token must be scoped to the steps that need it,
# not exposed to every step in the job.
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

# ── Homebrew token is NOT job-level (least privilege) ────────────────────────
ruby -ryaml -e '
  doc = YAML.load_file(ARGV[0])
  job_env = doc.dig("jobs", "release", "env") || {}
  exit(job_env.key?("HOMEBREW_TAP_TOKEN") ? 1 : 0)
' "$WF" 2>/dev/null; check $? "HOMEBREW_TAP_TOKEN is not exposed at job level"

# ── Token is scoped to the Homebrew step (and a presence-detection step) ─────
ruby -ryaml -e '
  doc = YAML.load_file(ARGV[0])
  steps = doc.dig("jobs", "release", "steps") || []
  with = steps.select { |s| (s["env"] || {}).key?("HOMEBREW_TAP_TOKEN") }
  exit(with.length >= 1 && with.length < steps.length ? 0 : 1)
' "$WF" 2>/dev/null; check $? "HOMEBREW_TAP_TOKEN is scoped to specific step(s)"

# ── The Homebrew step is still gated on token presence ───────────────────────
grep -qE "if:.*steps\.tap\.outputs\.enabled == 'true'" "$WF"; check $? "Homebrew step gated on the detected token"

echo ""
[ "$fail" -gt 0 ] && { echo "  $fail failed"; exit 1; }
echo "  all checks passed"
exit 0
