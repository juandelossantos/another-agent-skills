import type { Dictionary, Locale } from './i18n';
import { localePath, BASE } from './i18n/routes';
import { SITE, VERSION } from './config';
import { absoluteUrl } from './site';

/**
 * A schema.org JSON-LD graph for the landing: Organization, WebSite,
 * SoftwareApplication, FAQPage (AEO), HowTo (install) and BreadcrumbList.
 * Localized per locale.
 */
export function buildJsonLd(locale: Locale, dict: Dictionary): Record<string, unknown> {
  const canonical = absoluteUrl(localePath(locale));
  const orgId = `${canonical}#organization`;
  const websiteId = `${canonical}#website`;
  const inLanguage = locale === 'es' ? 'es' : 'en';

  const faqs = [
    [dict.faq.q1, dict.faq.a1],
    [dict.faq.q2, dict.faq.a2],
    [dict.faq.q3, dict.faq.a3],
    [dict.faq.q4, dict.faq.a4],
    [dict.faq.q5, dict.faq.a5],
    [dict.faq.q6, dict.faq.a6],
    [dict.faq.q7, dict.faq.a7],
  ].map(([name, text]) => ({
    '@type': 'Question',
    name,
    acceptedAnswer: { '@type': 'Answer', text },
  }));

  const howToSteps = [
    [dict.howTo.step1Name, dict.howTo.step1Text],
    [dict.howTo.step2Name, dict.howTo.step2Text],
    [dict.howTo.step3Name, dict.howTo.step3Text],
  ].map(([name, text], i) => ({
    '@type': 'HowToStep',
    position: i + 1,
    name,
    text,
  }));

  const docsSearchUrl = absoluteUrl(localePath(locale, 'docs/'));
  const logoUrl = absoluteUrl(`${BASE}favicon.svg`);

  return {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'Organization',
        '@id': orgId,
        name: 'Another Agent Skills',
        url: canonical,
        logo: logoUrl,
        sameAs: [SITE.github],
        description: dict.meta.description,
      },
      {
        '@type': 'WebSite',
        '@id': websiteId,
        url: canonical,
        name: 'Another Agent Skills',
        inLanguage,
        publisher: { '@id': orgId },
        // The docs overlay reads `?q=` on load, so this search action resolves.
        potentialAction: {
          '@type': 'SearchAction',
          target: {
            '@type': 'EntryPoint',
            urlTemplate: `${docsSearchUrl}?q={search_term_string}`,
          },
          'query-input': 'required name=search_term_string',
        },
      },
      {
        '@type': 'SoftwareApplication',
        name: 'Another Agent Skills',
        applicationCategory: 'DeveloperApplication',
        operatingSystem: 'macOS, Linux, Windows (Git Bash)',
        softwareVersion: VERSION,
        license: 'https://opensource.org/licenses/MIT',
        offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
        url: canonical,
        sameAs: [SITE.github],
        inLanguage,
        description: dict.meta.description,
      },
      {
        '@type': 'FAQPage',
        mainEntity: faqs,
      },
      {
        '@type': 'HowTo',
        name: dict.howTo.name,
        inLanguage,
        step: howToSteps,
      },
      {
        '@type': 'BreadcrumbList',
        itemListElement: [
          { '@type': 'ListItem', position: 1, name: 'Home', item: canonical },
        ],
      },
    ],
  };
}
