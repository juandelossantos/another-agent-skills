/*
 * Docs collection queries and navigation helpers.
 *
 * The sidebar is built from the collection itself: pages are grouped by their
 * `section` frontmatter and ordered by `order`. Adding a page to the collection
 * is enough for it to appear in the sidebar and the prev/next pager.
 */
import { getCollection, render, type CollectionEntry } from 'astro:content';
import type { Locale } from '../i18n';

export type DocEntry = CollectionEntry<'docs'>;

export const SECTION_IDS = ['start', 'concepts', 'reference', 'help'] as const;
export type SectionId = (typeof SECTION_IDS)[number];

/** `overview.en` -> `overview`; the route slug is locale-independent. */
export function docSlug(entry: DocEntry): string {
  return entry.id.replace(/\.(en|es)$/, '');
}

/** All docs for a locale, ordered by `order` then slug. */
export async function getDocs(locale: Locale): Promise<DocEntry[]> {
  const docs = await getCollection('docs', (entry) => entry.data.lang === locale);
  return docs.sort(
    (a, b) => a.data.order - b.data.order || docSlug(a).localeCompare(docSlug(b)),
  );
}

export interface DocGroup {
  id: SectionId;
  docs: DocEntry[];
}

/** Non-empty groups, in the fixed section order. */
export function groupBySection(docs: DocEntry[]): DocGroup[] {
  return SECTION_IDS.map((id) => ({
    id,
    docs: docs.filter((entry) => entry.data.section === id),
  })).filter((group) => group.docs.length > 0);
}

export interface LoadedDoc {
  entry: DocEntry;
  Content: Awaited<ReturnType<typeof render>>['Content'];
  headings: Awaited<ReturnType<typeof render>>['headings'];
  docs: DocEntry[];
  groups: DocGroup[];
  prev: DocEntry | null;
  next: DocEntry | null;
}

/** Resolve a page, its rendered body, the sidebar tree and the pager. */
export async function loadDoc(locale: Locale, slug: string): Promise<LoadedDoc> {
  const docs = await getDocs(locale);
  const index = docs.findIndex((entry) => docSlug(entry) === slug);
  if (index === -1) {
    throw new Error(`docs: no "${slug}" page for locale "${locale}"`);
  }
  const entry = docs[index];
  const { Content, headings } = await render(entry);
  return {
    entry,
    Content,
    headings,
    docs,
    groups: groupBySection(docs),
    prev: index > 0 ? docs[index - 1] : null,
    next: index < docs.length - 1 ? docs[index + 1] : null,
  };
}
