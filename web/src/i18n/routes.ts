import { DEFAULT_LOCALE, type Locale } from './index';

/**
 * Astro's BASE_URL may or may not include a trailing slash depending on the
 * configured `base`; normalize it so path joins are always correct.
 */
const RAW_BASE = import.meta.env.BASE_URL;
export const BASE = RAW_BASE.endsWith('/') ? RAW_BASE : `${RAW_BASE}/`;

/**
 * Build a site path for a locale. EN (the default) is unprefixed; ES lives
 * under `/es/`. The returned path already includes the configured `base`.
 *
 *   localePath('en')          -> '/another-agent-skills/'
 *   localePath('es')          -> '/another-agent-skills/es/'
 *   localePath('es', 'docs')  -> '/another-agent-skills/es/docs'
 */
export function localePath(locale: Locale, path = ''): string {
  const clean = path.replace(/^\/+/, '');
  return locale === DEFAULT_LOCALE ? `${BASE}${clean}` : `${BASE}${locale}/${clean}`;
}

/** The other locale (the landing is a two-locale pair). */
export function alternateLocale(locale: Locale): Locale {
  return locale === 'en' ? 'es' : 'en';
}
