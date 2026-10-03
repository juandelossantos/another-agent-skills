#!/usr/bin/env bash
# test-deploy-web-workflow.sh — asserts .github/workflows/deploy-web.yml builds
# the Astro project in web/ and deploys it to GitHub Pages on every push to
# main, with least privilege, and that a post-deploy job VERIFIES the live site
# actually serves (fails the run otherwise).
#
# Boundary: the core CI (.github/workflows/gates.yml) must NOT build web/. The
# Astro build is a separate workflow — asserted at the bottom.
#
# Spec: PLAN.md — Phase 10 closure (T2) / Phase 11 P11.5.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$REPO_ROOT/.github/workflows/deploy-web.yml"
GATES="$REPO_ROOT/.github/workflows/gates.yml"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

echo ""
echo "deploy-web.yml — GitHub Pages deploy for the Astro web/"
echo "───────────────────────────────────────────────────────"

# ─── Existence + valid YAML ───
assert "workflow exists" "[ -f '$FILE' ]"
assert "parses as YAML (Ruby Psych)" "ruby -ryaml -e 'YAML.load_file(ARGV[0])' '$FILE' >/dev/null 2>&1"

# ─── Triggers ───
assert "triggers on push to main" "grep -qE '^  push:' '$FILE' && grep -qE 'branches: \[main\]' '$FILE'"
assert "supports manual workflow_dispatch" "grep -qE '^  workflow_dispatch:' '$FILE'"

# ─── Least-privilege permissions ───
assert "requests contents: read" "grep -qE '^  contents: read' '$FILE'"
assert "requests pages: write" "grep -qE '^  pages: write' '$FILE'"
assert "requests id-token: write (OIDC for Pages deploy)" "grep -qE '^  id-token: write' '$FILE'"
assert "does NOT request contents: write" "! grep -qE 'contents: write' '$FILE'"
assert "does NOT request any other write scope" "! grep -qE '^  (actions|checks|deployments|issues|packages|pull-requests|security-events|statuses): write' '$FILE'"

# ─── Concurrency: one Pages deploy at a time, never cancel a production deploy ───
assert "concurrency group is 'pages'" "grep -qE 'group: \"pages\"' '$FILE'"
assert "does not cancel an in-progress deploy" "grep -qE 'cancel-in-progress: false' '$FILE'"

# ─── Jobs ───
assert "has a build job" "grep -qE '^  build:' '$FILE'"
assert "has a deploy job" "grep -qE '^  deploy:' '$FILE'"
assert "has a post-deploy verify job" "grep -qE '^  verify:' '$FILE'"

# ─── build job: checkout → setup-node → npm ci → build → configure-pages → upload ───
assert "checks out the repository" "grep -q 'actions/checkout@' '$FILE'"
assert "uses actions/setup-node" "grep -q 'actions/setup-node@' '$FILE'"
assert "Node 24" "grep -qE \"node-version: *'?24'?\" '$FILE'"
assert "caches npm" "grep -qE 'cache: npm' '$FILE'"
assert "cache key is web/package-lock.json" "grep -qE 'cache-dependency-path: web/package-lock.json' '$FILE'"
assert "installs with npm ci" "grep -qE '(^|[[:space:]])npm ci([[:space:]]|$)' '$FILE'"
assert "runs the web build" "grep -qE 'npm run build' '$FILE'"
assert "commands run in web/" "grep -qE 'working-directory: web' '$FILE'"
assert "uses actions/configure-pages" "grep -q 'actions/configure-pages@' '$FILE'"
assert "configure-pages has enablement: true" "grep -qE 'enablement: true' '$FILE'"
assert "uses actions/upload-pages-artifact" "grep -q 'actions/upload-pages-artifact@' '$FILE'"
assert "uploads web/dist" "grep -qE 'path: web/dist' '$FILE'"

# ─── deploy job: needs build, github-pages environment, deploy-pages@v4 ───
assert "deploy needs build" "grep -qE '^    needs: build' '$FILE'"
assert "deploy targets the github-pages environment" "grep -qE 'name: github-pages' '$FILE'"
assert "environment url comes from the deployment output" "grep -qF 'url: ${{ steps.deployment.outputs.page_url }}' '$FILE'"
assert "deploy step id is 'deployment'" "grep -qE '^        id: deployment' '$FILE'"
assert "uses actions/deploy-pages@v4" "grep -q 'actions/deploy-pages@v4' '$FILE'"
assert "deploy job exposes page_url as a job output" "grep -qF 'page_url: ${{ steps.deployment.outputs.page_url }}' '$FILE'"

# ─── verify job: post-deploy live check, resilient but fails loudly ───
assert "verify needs deploy" "grep -qE '^    needs: deploy' '$FILE'"
assert "verify reads the deployed page_url" "grep -qF 'needs.deploy.outputs.page_url' '$FILE'"
assert "verify uses curl" "grep -qE 'curl ' '$FILE'"
assert "verifies the EN landing" "grep -qE 'BASE_URL' '$FILE'"
assert "verifies the ES landing (/es/)" "grep -qF 'es/' '$FILE'"
assert "verifies the docs (/docs/)" "grep -qF 'docs/' '$FILE'"
assert "verifies a tutorial" "grep -qF 'first-gated-commit/' '$FILE'"
assert "verifies sitemap-index.xml" "grep -qF 'sitemap-index.xml' '$FILE'"
assert "retries with backoff" "grep -qE 'MAX_ATTEMPTS|sleep ' '$FILE'"
assert "fails loudly with ::error::" "grep -qF '::error::' '$FILE'"
assert "exits non-zero when a URL never serves" "grep -qE 'exit 1' '$FILE'"

# ─── Read-only: the deploy workflow must never mutate the repo ───
assert "no mutating git commands" "! grep -qE 'git (push|commit|tag)' '$FILE'"

# ─── Comments explain the one-time Pages source switch + legacy replacement ───
assert "documents the Pages source requirement" "grep -qiE 'Settings .* Pages|Pages .* Source' '$FILE'"
assert "documents the GitHub Actions source" "grep -qi 'GitHub Actions' '$FILE'"
assert "notes the legacy root site is replaced" "grep -qiE 'legacy|replaces the' '$FILE'"

# ─── Boundary: the core gates workflow must NOT build web/ ───
assert "core gates.yml does not build web/" "! grep -q 'npm run build' '$GATES' && ! grep -qE 'web/' '$GATES'"
assert "core gates.yml does not run deploy-pages" "! grep -q 'deploy-pages' '$GATES'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0
