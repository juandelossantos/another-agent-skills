// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Boundary rule: this build lives ONLY in web/. The repo core (skills/, hooks/,
// install.sh, scripts/, bin/aas) stays build-free and the core CI (`gates`)
// never runs this. See web/README.md and PLAN.md (Phase 10/11).
export default defineConfig({
  // GitHub Pages project page: https://juandelossantos.github.io/another-agent-skills/
  site: 'https://juandelossantos.github.io',
  base: '/another-agent-skills',

  // Fully static output — no adapter, no server runtime.
  output: 'static',

  // Docs are plain Markdown. Disable Shiki so fenced code inherits the site's
  // light/dark tokens instead of baking a fixed syntax theme into the HTML.
  markdown: {
    syntaxHighlight: false,
  },

  // EN is the default locale and lives at the root; ES is prefixed with /es/.
  i18n: {
    locales: ['en', 'es'],
    defaultLocale: 'en',
    routing: {
      prefixDefaultLocale: false,
    },
  },

  integrations: [
    sitemap({
      // Emits xhtml:link alternates (hreflang) for the EN/ES pair.
      i18n: {
        defaultLocale: 'en',
        locales: {
          en: 'en-US',
          es: 'es-ES',
        },
      },
    }),
  ],
});
