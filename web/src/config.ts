/*
 * External links used across the landing. Kept in one place so they are easy to
 * audit and update. The docs site arrives in a later step (Phase 11); until then
 * the "Docs" links point at the repository, which is honest and never broken.
 */
const GITHUB = 'https://github.com/juandelossantos/another-agent-skills';

export const SITE = {
  github: GITHUB,
  docs: `${GITHUB}/tree/main/docs`,
  agents: `${GITHUB}/blob/main/docs/AGENT-ADAPTERS.md`,
  evidence: `${GITHUB}/blob/main/docs/REMOTE-ENFORCEMENT-EVIDENCE.md`,
  skills: `${GITHUB}/blob/main/docs/skills.html`,
  license: `${GITHUB}/blob/main/LICENSE`,
} as const;

/** The current product version shown in the footer (not a build id). */
export const VERSION = 'v6.2.0';
