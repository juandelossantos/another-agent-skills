/*
 * Zero-dependency static server for the Playwright smoke.
 *
 * Astro 7's `astro preview` runs as a background daemon (it returns
 * immediately), which Playwright's `webServer` cannot manage. This serves the
 * built `dist/` under the configured base path instead, so the smoke test
 * exercises exactly what GitHub Pages will serve.
 *
 * Usage: node tests/static-server.mjs   (PORT env optional, default 4321)
 */
import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const DIST = fileURLToPath(new URL('../dist/', import.meta.url));
const BASE = '/another-agent-skills';
const PORT = Number(process.env.PORT || 4321);

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.xml': 'application/xml; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
};

const server = createServer(async (req, res) => {
  try {
    let pathname = decodeURIComponent(new URL(req.url ?? '/', 'http://localhost').pathname);
    if (!pathname.startsWith(BASE)) {
      res.writeHead(404, { 'content-type': 'text/plain' });
      res.end('not found');
      return;
    }
    pathname = pathname.slice(BASE.length);
    if (pathname === '' || pathname.endsWith('/')) pathname += 'index.html';

    const filePath = normalize(join(DIST, pathname));
    if (!filePath.startsWith(DIST)) {
      res.writeHead(403, { 'content-type': 'text/plain' });
      res.end('forbidden');
      return;
    }

    const data = await readFile(filePath);
    res.writeHead(200, { 'content-type': MIME[extname(filePath)] ?? 'application/octet-stream' });
    res.end(data);
  } catch {
    res.writeHead(404, { 'content-type': 'text/plain' });
    res.end('not found');
  }
});

server.listen(PORT, () => {
  console.log(`static server: http://localhost:${PORT}${BASE}/`);
});
