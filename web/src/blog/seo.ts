/*
 * SEO/AEO helpers for the blog.
 *
 * The index gets a `Blog` node plus a Home > Blog breadcrumb. Each post gets a
 * `BlogPosting` (with the author as a Person, so attribution is machine-readable)
 * plus a Home > Blog > Post breadcrumb. Both are localized.
 */
import type { Locale } from '../i18n';
import { absoluteUrl } from '../site';

const WEBSITE = absoluteUrl('/');

export interface BlogIndexSeoInput {
  locale: Locale;
  title: string;
  description: string;
  homeUrl: string;
  blogUrl: string;
}

export function buildBlogIndexJsonLd(input: BlogIndexSeoInput): Record<string, unknown>[] {
  const inLanguage = input.locale === 'es' ? 'es' : 'en';
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'Blog',
      name: input.title,
      description: input.description,
      url: input.blogUrl,
      inLanguage,
      isPartOf: { '@type': 'WebSite', name: 'Another Agent Skills', url: WEBSITE },
      publisher: { '@type': 'Organization', name: 'Another Agent Skills', url: WEBSITE },
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: input.homeUrl },
        { '@type': 'ListItem', position: 2, name: input.title, item: input.blogUrl },
      ],
    },
  ];
}

export interface BlogPostSeoInput {
  locale: Locale;
  headline: string;
  description: string;
  /** ISO 8601. */
  datePublished: string;
  /** ISO 8601. */
  dateModified: string;
  authorName: string;
  authorUrl?: string;
  imageUrl: string;
  homeUrl: string;
  blogUrl: string;
  blogName: string;
  pageUrl: string;
  /** Optional richer metadata (AEO). */
  wordCount?: number;
  readingMinutes?: number;
  keywords?: string[];
  articleSection?: string;
}

export function buildBlogPostJsonLd(input: BlogPostSeoInput): Record<string, unknown>[] {
  const inLanguage = input.locale === 'es' ? 'es' : 'en';
  const author: Record<string, unknown> = { '@type': 'Person', name: input.authorName };
  if (input.authorUrl) author.url = input.authorUrl;

  return [
    {
      '@context': 'https://schema.org',
      '@type': 'BlogPosting',
      headline: input.headline,
      description: input.description,
      datePublished: input.datePublished,
      dateModified: input.dateModified,
      inLanguage,
      url: input.pageUrl,
      image: input.imageUrl,
      author,
      isPartOf: { '@type': 'Blog', name: input.blogName, url: input.blogUrl },
      publisher: { '@type': 'Organization', name: 'Another Agent Skills', url: WEBSITE },
      mainEntityOfPage: input.pageUrl,
      ...(input.wordCount ? { wordCount: input.wordCount } : {}),
      ...(input.readingMinutes ? { timeRequired: `PT${input.readingMinutes}M` } : {}),
      ...(input.keywords?.length ? { keywords: input.keywords } : {}),
      ...(input.articleSection ? { articleSection: input.articleSection } : {}),
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: input.homeUrl },
        { '@type': 'ListItem', position: 2, name: input.blogName, item: input.blogUrl },
        { '@type': 'ListItem', position: 3, name: input.headline, item: input.pageUrl },
      ],
    },
  ];
}
