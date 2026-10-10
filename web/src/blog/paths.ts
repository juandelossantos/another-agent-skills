/*
 * Blog route helpers. All paths already include the configured `base`.
 *
 * The index lives at `/blog/` (EN) or `/es/blog/` (ES); a post lives at
 * `/blog/<slug>/` (EN) or `/es/blog/<slug>/` (ES).
 */
import { localePath } from '../i18n/routes';
import type { Locale } from '../i18n';

/** `/another-agent-skills/blog/` (EN) or `/another-agent-skills/es/blog/` (ES). */
export function blogHome(locale: Locale): string {
  return localePath(locale, 'blog/');
}

/** The canonical path for a post slug in a locale. */
export function blogHref(locale: Locale, slug: string): string {
  return localePath(locale, `blog/${slug}/`);
}

/** The RSS feed for a locale (`/blog/rss.xml` or `/es/blog/rss.xml`). */
export function blogRss(locale: Locale): string {
  return localePath(locale, 'blog/rss.xml');
}
