import { en, type Dictionary } from './en';
import { es } from './es';

export type Locale = 'en' | 'es';

export const LOCALES: Locale[] = ['en', 'es'];
export const DEFAULT_LOCALE: Locale = 'en';

const DICTS: Record<Locale, Dictionary> = { en, es };

/** The dictionary for a locale. Falls back to EN for an unknown locale. */
export function getDictionary(locale: Locale): Dictionary {
  return DICTS[locale] ?? en;
}

export function isLocale(value: string): value is Locale {
  return (LOCALES as string[]).includes(value);
}

/** The `lang`/`hreflang` attribute value for a locale. */
export const HTML_LANG: Record<Locale, string> = { en: 'en', es: 'es' };

export { en, es };
export type { Dictionary };
