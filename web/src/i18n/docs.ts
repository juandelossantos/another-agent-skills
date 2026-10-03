/*
 * Docs-shell UI strings (EN canonical, ES typed as `typeof docsEn`).
 * Content lives in `src/content/docs/*.md`; this dictionary is only the chrome:
 * sidebar labels, search, TOC, pager and accessible names.
 *
 * Neutral Spanish only (no voseo) — asserted by web/tests/build.test.mjs.
 */
import type { Locale } from './index';

export const docsEn = {
  nav: {
    label: 'Documentation',
    docs: 'Docs',
    home: 'Another Agent Skills home',
    skip: 'Skip to content',
  },
  sections: {
    start: 'Get started',
    concepts: 'Concepts',
    reference: 'Reference',
    help: 'Help',
  },
  search: {
    placeholder: 'Search docs',
    label: 'Search documentation',
    resultsLabel: 'Documentation results',
    hints: '↑↓ navigate · Enter open · Esc close',
    results: 'results',
    result: 'result',
    noResults: 'No results for',
    loading: 'Loading results',
  },
  toc: { title: 'On this page' },
  pager: { prev: 'Previous', next: 'Next', label: 'Pagination' },
  edit: 'Edit this page',
  versionLabel: 'current docs',
  github: 'GitHub',
  theme: { dark: 'Dark', light: 'Light' },
  a11y: {
    menu: 'Open documentation navigation',
    menuClose: 'Close documentation navigation',
    theme: 'Toggle color theme',
    langToEs: 'Switch to Spanish',
    langToEn: 'Switch to English',
    copy: 'Copy code',
    copied: 'Copied',
    breadcrumb: 'Breadcrumb',
    docsNav: 'Docs',
    sidebar: 'Documentation navigation',
  },
  index: {
    title: 'Documentation',
    browse: 'Browse the docs',
  },
} as const;

export type DocsDictionary = typeof docsEn;

export const docsEs: DocsDictionary = {
  nav: {
    label: 'Documentación',
    docs: 'Documentación',
    home: 'Inicio de Another Agent Skills',
    skip: 'Saltar al contenido',
  },
  sections: {
    start: 'Empezar',
    concepts: 'Conceptos',
    reference: 'Referencia',
    help: 'Ayuda',
  },
  search: {
    placeholder: 'Buscar en la documentación',
    label: 'Buscar en la documentación',
    resultsLabel: 'Resultados de documentación',
    hints: '↑↓ navegar · Enter abrir · Esc cerrar',
    results: 'resultados',
    result: 'resultado',
    noResults: 'Sin resultados para',
    loading: 'Cargando resultados',
  },
  toc: { title: 'En esta página' },
  pager: { prev: 'Anterior', next: 'Siguiente', label: 'Paginación' },
  edit: 'Editar esta página',
  versionLabel: 'docs actuales',
  github: 'GitHub',
  theme: { dark: 'Oscuro', light: 'Claro' },
  a11y: {
    menu: 'Abrir la navegación de documentación',
    menuClose: 'Cerrar la navegación de documentación',
    theme: 'Cambiar tema de color',
    langToEs: 'Cambiar a español',
    langToEn: 'Cambiar a inglés',
    copy: 'Copiar código',
    copied: 'Copiado',
    breadcrumb: 'Migas de pan',
    docsNav: 'Documentación',
    sidebar: 'Navegación de documentación',
  },
  index: {
    title: 'Documentación',
    browse: 'Explorar la documentación',
  },
};

const DICTS: Record<Locale, DocsDictionary> = { en: docsEn, es: docsEs };

export function getDocsDictionary(locale: Locale): DocsDictionary {
  return DICTS[locale] ?? docsEn;
}
