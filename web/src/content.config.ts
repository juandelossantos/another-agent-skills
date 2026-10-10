/*
 * Content collections for the docs site.
 *
 * The `docs` collection holds one Markdown file per page per locale. A page is
 * bilingual when both `<slug>.en.md` and `<slug>.es.md` exist with the same
 * `order` and `section`. The slug is derived from the entry id (the filename
 * without the locale suffix), so frontmatter never duplicates the route.
 *
 * Adding a page: create `src/content/docs/<slug>.en.md` and `<slug>.es.md`
 * with the frontmatter below. See web/README.md ("Docs structure").
 */
import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const docs = defineCollection({
  loader: glob({
    base: './src/content/docs',
    pattern: '**/*.md',
    // Keep the locale suffix in the id (`overview.en`), so the two locales are
    // distinct collection entries. `docSlug()` strips it to get the route slug.
    generateId: ({ entry }) => entry.replace(/\.md$/, ''),
  }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    lang: z.enum(['en', 'es']),
    order: z.number().int().nonnegative(),
    section: z.enum(['start', 'tutorials', 'concepts', 'reference', 'help']),
    /** One-line, citable summary shown as the page TL;DR (AEO). */
    tldr: z.string().optional(),
  }),
});

/*
 * Blog collection.
 *
 * One Markdown file per post per locale (`<slug>.en.md` / `<slug>.es.md`), the
 * same bilingual convention as the docs. The `title`/`subtitle`/`author` live in
 * frontmatter, so the author is data (ready for guest posts), never hardcoded in
 * the layout. The route slug is the filename without the locale suffix.
 *
 * `image` is a filename inside `src/assets/blog/`; `src/blog/nav.ts` resolves it
 * to `ImageMetadata` for the optimized `<Image>` hero.
 */
const blog = defineCollection({
  loader: glob({
    base: './src/content/blog',
    pattern: '**/*.md',
    generateId: ({ entry }) => entry.replace(/\.md$/, ''),
  }),
  schema: z.object({
    title: z.string(),
    subtitle: z.string().optional(),
    description: z.string(),
    lang: z.enum(['en', 'es']),
    date: z.coerce.date(),
    updated: z.coerce.date().optional(),
    author: z.object({
      name: z.string(),
      handle: z.string().optional(),
      url: z.string().optional(),
      role: z.string().optional(),
    }),
    /** Filename inside `src/assets/blog/` (resolved to ImageMetadata). */
    image: z.string(),
    imageAlt: z.string(),
    tags: z.array(z.string()).default([]),
    /** One-line, citable summary (AEO). */
    tldr: z.string().optional(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { docs, blog };
