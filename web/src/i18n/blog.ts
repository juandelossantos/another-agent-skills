/*
 * Blog chrome (EN canonical, ES typed as `typeof blogEn`, so a missing or extra
 * key fails the type check: locale parity is enforced at build).
 *
 * Post content lives in `src/content/blog/*.md`; this dictionary is only the
 * shell: the index, the article header, the share options and the navigation
 * aids. The author itself is frontmatter data, never a hardcoded string here.
 *
 * Neutral Spanish only (no voseo) — asserted by web/tests/build.test.mjs.
 */
import type { Locale } from './index';

export const blogEn = {
  index: {
    eyebrow: '/// writing',
    title: 'Writing',
    lede: 'Essays on AI agents, judgment, and the discipline that keeps a human in charge.',
    featured: 'Featured',
    latest: 'Latest',
    read: 'Read',
    minRead: 'min read',
    empty: 'No posts yet.',
    subscribe: 'Subscribe via RSS',
  },
  post: {
    back: 'All writing',
    minRead: 'min read',
    tags: 'Tags',
    toc: 'On this article',
    summary: 'Summary',
    share: 'Share',
    shareX: 'X',
    shareLinkedIn: 'LinkedIn',
    shareHN: 'Hacker News',
    shareEmail: 'Email',
    copyLink: 'Copy link',
    copied: 'Copied',
  },
};

export type BlogDictionary = typeof blogEn;

export const blogEs: BlogDictionary = {
  index: {
    eyebrow: '/// artículos',
    title: 'Artículos',
    lede: 'Ensayos sobre agentes de IA, criterio y la disciplina que mantiene al humano al mando.',
    featured: 'Destacado',
    latest: 'Recientes',
    read: 'Leer',
    minRead: 'min de lectura',
    empty: 'Todavía no hay artículos.',
    subscribe: 'Suscríbete por RSS',
  },
  post: {
    back: 'Todos los artículos',
    minRead: 'min de lectura',
    tags: 'Etiquetas',
    toc: 'En este artículo',
    summary: 'Resumen',
    share: 'Compartir',
    shareX: 'X',
    shareLinkedIn: 'LinkedIn',
    shareHN: 'Hacker News',
    shareEmail: 'Correo',
    copyLink: 'Copiar enlace',
    copied: 'Copiado',
  },
};

const DICTS: Record<Locale, BlogDictionary> = { en: blogEn, es: blogEs };

export function getBlogDictionary(locale: Locale): BlogDictionary {
  return DICTS[locale] ?? blogEn;
}
