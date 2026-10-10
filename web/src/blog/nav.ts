/*
 * Blog collection queries and helpers.
 *
 * Posts are ordered newest-first. The hero image named in a post's frontmatter
 * is resolved against `src/assets/blog/` at build time, so `<Image>` can emit an
 * optimized, responsive asset. Nothing here ships to the client.
 */
import { getCollection, render, type CollectionEntry } from 'astro:content';
import type { ImageMetadata } from 'astro';
import type { Locale } from '../i18n';

export type PostEntry = CollectionEntry<'blog'>;

/** `the-human-in-command.en` -> `the-human-in-command` (locale-independent). */
export function postSlug(entry: PostEntry): string {
  return entry.id.replace(/\.(en|es)$/, '');
}

/** Published posts for a locale, newest first. */
export async function getPosts(locale: Locale): Promise<PostEntry[]> {
  const posts = await getCollection(
    'blog',
    (entry) => entry.data.lang === locale && !entry.data.draft,
  );
  return posts.sort(
    (a, b) =>
      b.data.date.getTime() - a.data.date.getTime() || postSlug(a).localeCompare(postSlug(b)),
  );
}

/** Every hero image in `src/assets/blog/`, keyed by its site-root path. */
const HEROES = import.meta.glob<{ default: ImageMetadata }>(
  '/src/assets/blog/*.{png,jpg,jpeg,webp,avif}',
  { eager: true },
);

/** Resolve a post's `image` frontmatter to an importable asset. */
export function heroImage(entry: PostEntry): ImageMetadata {
  const key = `/src/assets/blog/${entry.data.image}`;
  const mod = HEROES[key];
  if (!mod) {
    throw new Error(
      `blog: hero image "${entry.data.image}" not found in src/assets/blog/ (post "${entry.id}")`,
    );
  }
  return mod.default;
}

/** A rough reading time (words / 200), never below one minute. */
export function readingMinutes(entry: PostEntry): number {
  const words = entry.body?.trim().split(/\s+/).length ?? 0;
  return Math.max(1, Math.round(words / 200));
}

/** A stable, timezone-safe date label for the post meta line. */
export function formatDate(date: Date, locale: Locale): string {
  return new Intl.DateTimeFormat(locale === 'es' ? 'es-ES' : 'en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    timeZone: 'UTC',
  }).format(date);
}

export interface LoadedPost {
  entry: PostEntry;
  Content: Awaited<ReturnType<typeof render>>['Content'];
  headings: Awaited<ReturnType<typeof render>>['headings'];
  prev: PostEntry | null;
  next: PostEntry | null;
}

/** Resolve a post, its rendered body, and the newer/older neighbours. */
export async function loadPost(locale: Locale, slug: string): Promise<LoadedPost> {
  const posts = await getPosts(locale);
  const index = posts.findIndex((entry) => postSlug(entry) === slug);
  if (index === -1) {
    throw new Error(`blog: no "${slug}" post for locale "${locale}"`);
  }
  const entry = posts[index];
  const { Content, headings } = await render(entry);
  return {
    entry,
    Content,
    headings,
    prev: index > 0 ? posts[index - 1] : null,
    next: index < posts.length - 1 ? posts[index + 1] : null,
  };
}
