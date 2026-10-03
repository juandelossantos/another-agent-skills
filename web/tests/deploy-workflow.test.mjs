/*
 * Deploy-workflow assertions — run with `node --test tests/deploy-workflow.test.mjs`.
 *
 * The Astro site in web/ is published by .github/workflows/deploy-web.yml (a
 * workflow SEPARATE from the core CI). These checks pin the wiring the web
 * project depends on: it builds web/, uploads web/dist, deploys to the
 * github-pages environment with the official Pages actions, and verifies the
 * live site afterwards. They are static (they read the workflow file), so they
 * run without a build.
 *
 * Spec: PLAN.md — Phase 10 closure (T2) / Phase 11 P11.5.
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const WORKFLOW = fileURLToPath(
  new URL('../../.github/workflows/deploy-web.yml', import.meta.url),
);

test('deploy-web.yml exists', () => {
  assert.ok(existsSync(WORKFLOW), 'missing .github/workflows/deploy-web.yml');
});

const yml = existsSync(WORKFLOW) ? readFileSync(WORKFLOW, 'utf8') : '';

test('triggers on push to main and manual dispatch', () => {
  assert.match(yml, /^on:/m);
  assert.match(yml, /^\s*push:/m);
  assert.match(yml, /branches:\s*\[main\]/);
  assert.match(yml, /^\s*workflow_dispatch:/m);
});

test('requests least-privilege permissions for a Pages deploy', () => {
  assert.match(yml, /^\s*contents:\s*read$/m);
  assert.match(yml, /^\s*pages:\s*write$/m);
  assert.match(yml, /^\s*id-token:\s*write$/m);
  assert.doesNotMatch(yml, /^\s*contents:\s*write$/m);
});

test('serializes deploys on the pages concurrency group without cancelling', () => {
  assert.match(yml, /group:\s*"pages"/);
  assert.match(yml, /cancel-in-progress:\s*false/);
});

test('builds web/ and uploads web/dist with the official actions', () => {
  assert.match(yml, /^\s*build:/m);
  assert.match(yml, /actions\/setup-node@/);
  assert.match(yml, /node-version:\s*'?24'?/);
  assert.match(yml, /cache-dependency-path:\s*web\/package-lock\.json/);
  assert.match(yml, /npm ci/);
  assert.match(yml, /npm run build/);
  assert.match(yml, /working-directory:\s*web/);
  assert.match(yml, /actions\/configure-pages@/);
  assert.match(yml, /enablement:\s*true/);
  assert.match(yml, /actions\/upload-pages-artifact@/);
  assert.match(yml, /path:\s*web\/dist/);
});

test('deploys to the github-pages environment with deploy-pages@v4', () => {
  assert.match(yml, /^\s*deploy:/m);
  assert.match(yml, /^\s*needs:\s*build$/m);
  assert.match(yml, /name:\s*github-pages/);
  assert.match(yml, /url:\s*\$\{\{\s*steps\.deployment\.outputs\.page_url\s*\}\}/);
  assert.match(yml, /actions\/deploy-pages@v4/);
  assert.match(yml, /^\s*id:\s*deployment$/m);
  assert.match(yml, /page_url:\s*\$\{\{\s*steps\.deployment\.outputs\.page_url\s*\}\}/);
});

test('post-deploy verification curls the live site and fails loudly', () => {
  assert.match(yml, /^\s*verify:/m);
  assert.match(yml, /^\s*needs:\s*deploy$/m);
  assert.match(yml, /needs\.deploy\.outputs\.page_url/);
  assert.match(yml, /curl /);
  assert.match(yml, /es\//);
  assert.match(yml, /docs\//);
  assert.match(yml, /first-gated-commit\//);
  assert.match(yml, /sitemap-index\.xml/);
  assert.match(yml, /MAX_ATTEMPTS/);
  assert.match(yml, /::error::/);
  assert.match(yml, /exit 1/);
});

test('never mutates the repository', () => {
  assert.doesNotMatch(yml, /git (push|commit|tag)/);
});

test('documents the one-time Pages source switch and the legacy replacement', () => {
  assert.match(yml, /Settings .* Pages/);
  assert.match(yml, /GitHub Actions/);
  assert.match(yml, /legacy/i);
});
