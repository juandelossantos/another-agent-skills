/*
 * Docs route helpers. All paths already include the configured `base`.
 *
 * `overview` is the docs home (`/docs/`); every other slug lives at
 * `/docs/<slug>/` (EN) or `/es/docs/<slug>/` (ES).
 */
import { localePath } from '../i18n/routes';
import type { Locale } from '../i18n';

export const OVERVIEW_SLUG = 'overview';

/** `/another-agent-skills/docs/` (EN) or `/another-agent-skills/es/docs/` (ES). */
export function docsHome(locale: Locale): string {
  return localePath(locale, 'docs/');
}

/** The canonical path for a docs slug in a locale. */
export function docsHref(locale: Locale, slug: string): string {
  return slug === OVERVIEW_SLUG ? docsHome(locale) : localePath(locale, `docs/${slug}/`);
}

/** The build-generated client-side search index for a locale. */
export function docsSearchIndex(locale: Locale): string {
  return localePath(locale, 'docs/search.json');
}
