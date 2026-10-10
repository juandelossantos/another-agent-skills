/*
 * Single source of truth for the site origin.
 *
 * `astro.config.mjs` sets `site`; Astro exposes it as `import.meta.env.SITE`,
 * normalized with a trailing slash. Normalize it once here so every SEO / OG /
 * RSS helper builds absolute URLs from the same place instead of hardcoding the
 * origin per file.
 */
export const SITE_ORIGIN = (
  import.meta.env.SITE ?? 'https://juandelossantos.github.io'
).replace(/\/+$/, '');

/** Absolute URL for a site path (e.g. `/another-agent-skills/blog/`). */
export function absoluteUrl(path: string): string {
  return new URL(path, `${SITE_ORIGIN}/`).href;
}
