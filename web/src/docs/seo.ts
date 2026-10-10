/*
 * SEO/AEO helpers for the docs site.
 *
 * Every docs page gets a BreadcrumbList (Docs > Section > Page) so search and
 * answer engines can place it in the tree, plus a TechArticle carrying the
 * citable TL;DR/description and the locale.
 */
import type { Locale } from '../i18n';
import { absoluteUrl } from '../site';

export interface DocsSeoInput {
  locale: Locale;
  title: string;
  description: string;
  sectionLabel: string;
  homeUrl: string;
  sectionUrl: string;
  pageUrl: string;
}

export function buildDocsJsonLd(input: DocsSeoInput): Record<string, unknown>[] {
  const inLanguage = input.locale === 'es' ? 'es' : 'en';
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Docs', item: input.homeUrl },
        { '@type': 'ListItem', position: 2, name: input.sectionLabel, item: input.sectionUrl },
        { '@type': 'ListItem', position: 3, name: input.title, item: input.pageUrl },
      ],
    },
    {
      '@context': 'https://schema.org',
      '@type': 'TechArticle',
      headline: input.title,
      description: input.description,
      inLanguage,
      url: input.pageUrl,
      isPartOf: {
        '@type': 'WebSite',
        name: 'Another Agent Skills',
        url: absoluteUrl('/'),
      },
      about: 'AI coding agent skills and mechanical enforcement',
    },
  ];
}
