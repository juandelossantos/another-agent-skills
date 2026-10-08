/*
 * External links used across the landing. Kept in one place so they are easy to
 * audit and update. The docs site is part of this Astro build, so the "Docs"
 * links resolve to `/docs/` (EN) and `/es/docs/` (ES) through `docsHome()` in
 * `src/docs/paths.ts` — not to the repository folder.
 */
const GITHUB = 'https://github.com/juandelossantos/another-agent-skills';

export const SITE = {
  github: GITHUB,
  agents: `${GITHUB}/blob/main/docs/AGENT-ADAPTERS.md`,
  evidence: `${GITHUB}/blob/main/docs/REMOTE-ENFORCEMENT-EVIDENCE.md`,
  skills: `${GITHUB}/blob/main/docs/skills.html`,
  license: `${GITHUB}/blob/main/LICENSE`,
} as const;

/** The current product version shown in the footer (not a build id). */
export const VERSION = 'v6.3.1';
