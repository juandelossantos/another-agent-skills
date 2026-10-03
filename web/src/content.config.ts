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

export const collections = { docs };
