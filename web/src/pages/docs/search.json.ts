import type { APIRoute } from 'astro';
import { getDocs, docSlug } from '../../docs/nav';
import { docsHref } from '../../docs/paths';
import { docsEn } from '../../i18n/docs';

/** Build-generated client-side search index for the EN docs. */
export const GET: APIRoute = async () => {
  const docs = await getDocs('en');
  const items = docs.map((entry) => ({
    title: entry.data.title,
    section: docsEn.sections[entry.data.section],
    snippet: entry.data.tldr ?? entry.data.description,
    url: docsHref('en', docSlug(entry)),
  }));
  return new Response(JSON.stringify(items), {
    headers: { 'content-type': 'application/json; charset=utf-8' },
  });
};
