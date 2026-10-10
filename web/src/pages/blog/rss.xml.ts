import type { APIRoute } from 'astro';
import { getPosts, postSlug } from '../../blog/nav';
import { blogHref, blogHome, blogRss } from '../../blog/paths';
import { getBlogDictionary } from '../../i18n/blog';
import { absoluteUrl } from '../../site';

const abs = absoluteUrl;

function escapeXml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

/** Build-generated RSS 2.0 feed for the EN writing. */
export const GET: APIRoute = async () => {
  const locale = 'en' as const;
  const blog = getBlogDictionary(locale);
  const posts = await getPosts(locale);
  const home = abs(blogHome(locale));

  const items = posts
    .map((entry) => {
      const url = abs(blogHref(locale, postSlug(entry)));
      return [
        '    <item>',
        `      <title>${escapeXml(entry.data.title)}</title>`,
        `      <link>${url}</link>`,
        `      <guid isPermaLink="true">${url}</guid>`,
        `      <description>${escapeXml(entry.data.description)}</description>`,
        `      <pubDate>${entry.data.date.toUTCString()}</pubDate>`,
        '    </item>',
      ].join('\n');
    })
    .join('\n');

  const xml = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">',
    '  <channel>',
    `    <title>Another Agent Skills — ${escapeXml(blog.index.title)}</title>`,
    `    <link>${home}</link>`,
    `    <description>${escapeXml(blog.index.lede)}</description>`,
    `    <language>${locale}</language>`,
    `    <atom:link href="${abs(blogRss(locale))}" rel="self" type="application/rss+xml"/>`,
    items,
    '  </channel>',
    '</rss>',
    '',
  ].join('\n');

  return new Response(xml, {
    headers: { 'content-type': 'application/xml; charset=utf-8' },
  });
};
