/*
 * Skills dataset access — the single source shared by the docs sidebar group
 * and the build-generated search index.
 *
 * Data comes from `src/data/skills.json`, generated from the skills' own
 * `SKILL.md` by `scripts/generate-skills.mjs`. Never hand-edit the dataset:
 * edit the skills and re-run `npm run skills`.
 *
 * Everything here is build-time (imported by `.astro` components and the
 * `search.json` endpoints); nothing ships to the client.
 */
import dataset from '../data/skills.json';
import type { Locale } from '../i18n';

export interface SkillTranslation {
  what: string;
  triggers: string[];
  whenToUse: string[];
  whenNotToUse: string[];
  fallback: boolean;
}

export interface Skill {
  name: string;
  title: string;
  category: string;
  tier: string;
  audience: string;
  what: string;
  triggers: string[];
  whenToUse: string[];
  whenNotToUse: string[];
  guides: string[];
  guideCount: number;
  docsUrl: string;
  es: SkillTranslation;
}

export interface SkillCategory {
  id: string;
  en: string;
  es: string;
  enDesc: string;
  esDesc: string;
}

export interface SkillsDataset {
  generatedFrom: string;
  skillCount: number;
  guideCount: number;
  categories: SkillCategory[];
  skills: Skill[];
}

export const SKILLS = dataset as unknown as SkillsDataset;

/** `#skill-<name>` — the anchor rendered by `SkillsCatalog`. */
export function skillAnchor(name: string): string {
  return `#skill-${name}`;
}

/** Localized category label (falls back to EN if an id is unknown). */
export function categoryLabel(category: SkillCategory, locale: Locale): string {
  return locale === 'es' ? category.es : category.en;
}

/** The locale's copy for one skill (ES always present; EN is the canonical). */
export function localizeSkill(skill: Skill, locale: Locale): SkillTranslation {
  if (locale === 'es') return skill.es;
  return {
    what: skill.what,
    triggers: skill.triggers,
    whenToUse: skill.whenToUse,
    whenNotToUse: skill.whenNotToUse,
    fallback: false,
  };
}

export interface SidebarSkill {
  name: string;
  title: string;
  anchor: string;
}

export interface SidebarSkillGroup {
  id: string;
  label: string;
  skills: SidebarSkill[];
}

/**
 * Localized `category -> skills` tree for the sidebar. Every skill appears
 * exactly once; empty categories are dropped.
 */
export function skillsSidebar(locale: Locale): SidebarSkillGroup[] {
  return SKILLS.categories
    .map((category) => ({
      id: category.id,
      label: categoryLabel(category, locale),
      skills: SKILLS.skills
        .filter((skill) => skill.category === category.id)
        .map((skill) => ({
          name: skill.name,
          title: skill.title,
          anchor: skillAnchor(skill.name),
        })),
    }))
    .filter((group) => group.skills.length > 0);
}

export interface SkillSearchItem {
  title: string;
  section: string;
  snippet: string;
  url: string;
}

/**
 * One search entry per skill, anchored on the skills page. `skillsHref` is the
 * already base- and locale-prefixed skills page URL (see `docsHref`).
 */
export function skillSearchItems(locale: Locale, skillsHref: string): SkillSearchItem[] {
  const labels = new Map(SKILLS.categories.map((category) => [category.id, categoryLabel(category, locale)]));
  return SKILLS.skills.map((skill) => ({
    title: skill.name,
    section: labels.get(skill.category) ?? skill.category,
    snippet: localizeSkill(skill, locale).what,
    url: `${skillsHref}${skillAnchor(skill.name)}`,
  }));
}

/**
 * The citable skills stat line, derived from the generated dataset so the guide
 * count can never drift from `skills.json` (the single source of truth). Never
 * hand-type the counts in the dictionaries.
 */
export function skillsStats(locale: Locale): string {
  const { skillCount, guideCount } = SKILLS;
  if (locale === 'es') {
    return `${skillCount} skills · ${guideCount} guías · 6 componentes del harness · un eval para cada una`;
  }
  return `${skillCount} skills · ${guideCount} guides · 6 harness components · an eval for each`;
}
