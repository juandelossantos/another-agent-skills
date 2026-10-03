/*
 * Deterministic Open Graph / social card generator.
 *
 * Renders an on-brand, editorial-premium 1200x630 card (warm background, the
 * Newsreader serif thesis, the burnt-orange accent, the product name) with
 * headless Chromium and screenshots it to `public/og.png`.
 *
 * Deterministic: no randomness, no network, fonts embedded as data URIs, and
 * animations disabled. Regenerate with `npm run og`.
 *
 * The self-hosted latin subsets are the same files `src/styles/fonts.css`
 * serves, so the card matches the site's typography.
 */
import { chromium } from '@playwright/test';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const WIDTH = 1200;
const HEIGHT = 630;

const fontFile = (name) => new URL(`../src/styles/fonts/${name}`, import.meta.url);
const OUT = fileURLToPath(new URL('../public/og.png', import.meta.url));

async function dataUri(name) {
  const buf = await readFile(fontFile(name));
  return `data:font/woff2;base64,${buf.toString('base64')}`;
}

const [serif, mono] = await Promise.all([dataUri('f24c321523.woff2'), dataUri('0a7197f9e2.woff2')]);

const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<style>
  @font-face { font-family: 'Newsreader'; font-style: normal; font-weight: 800; src: url(${serif}) format('woff2'); }
  @font-face { font-family: 'JetBrains Mono'; font-style: normal; font-weight: 500; src: url(${mono}) format('woff2'); }

  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: ${WIDTH}px; height: ${HEIGHT}px; }
  body {
    background: #1a1a18;
    color: #e8e6e3;
    font-family: 'Newsreader', Georgia, serif;
    -webkit-font-smoothing: antialiased;
  }
  .card {
    width: 100%; height: 100%;
    padding: 64px 72px;
    display: flex; flex-direction: column; justify-content: space-between;
    border-left: 10px solid #e8703a;
  }
  .top { display: flex; align-items: baseline; justify-content: space-between; }
  .brand {
    font-family: 'JetBrains Mono', monospace;
    font-weight: 500;
    font-size: 22px;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    color: #e8703a;
  }
  .meta {
    font-family: 'JetBrains Mono', monospace;
    font-size: 18px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: #8f8c86;
  }
  h1 {
    font-weight: 800;
    font-size: 78px;
    line-height: 1.02;
    letter-spacing: -0.015em;
    max-width: 20ch;
  }
  h1 .accent { color: #e8703a; }
  .rule { width: 132px; height: 4px; background: #e8703a; margin: 28px 0 24px; }
  .bottom { display: flex; align-items: flex-end; justify-content: space-between; gap: 32px; }
  .facts {
    font-family: 'JetBrains Mono', monospace;
    font-size: 20px;
    line-height: 1.5;
    color: #a8a5a0;
    max-width: 62ch;
  }
  .url {
    font-family: 'JetBrains Mono', monospace;
    font-size: 19px;
    color: #e8703a;
    white-space: nowrap;
  }
</style>
</head>
<body>
  <div class="card">
    <div class="top">
      <span class="brand">/// Another Agent Skills</span>
      <span class="meta">Open source · MIT</span>
    </div>

    <div>
      <h1>Most skill libraries sell capability. <span class="accent">We sell discipline you can verify.</span></h1>
    </div>

    <div>
      <div class="rule"></div>
      <div class="bottom">
        <p class="facts">57 skills · L1/L2/L3 mechanical enforcement · 15 agents</p>
        <span class="url">another-agent-skills</span>
      </div>
    </div>
  </div>
</body>
</html>`;

const browser = await chromium.launch();
const context = await browser.newContext({
  viewport: { width: WIDTH, height: HEIGHT },
  deviceScaleFactor: 1,
  reducedMotion: 'reduce',
});
const page = await context.newPage();
await page.setContent(html, { waitUntil: 'load' });
await page.evaluate(() => document.fonts.ready);
await page.screenshot({ path: OUT, type: 'png' });
await browser.close();

const bytes = (await readFile(OUT)).length;
console.log(`og.png written: ${OUT} (${WIDTH}x${HEIGHT}, ${bytes} bytes)`);
