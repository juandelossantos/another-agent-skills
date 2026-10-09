#!/usr/bin/env node
/*
 * generate-skills.mjs — build the skills reference dataset.
 *
 * Single source of truth: `../skills/<name>/SKILL.md` (frontmatter + the
 * "When to Use" / "When NOT to Use" sections) plus the ES translation map in
 * `src/data/skills.es.json`. Nothing is hand-copied from the skills.
 *
 * Run:  node scripts/generate-skills.mjs   (wired to `npm run skills`)
 * Writes: src/data/skills.json             (deterministic, no timestamp)
 *
 * Dependency-free: a tiny parser handles the YAML subset the SKILL.md files
 * use (scalars, quoted strings, one nested `metadata` map, and the `>` folded
 * scalar in customize-opencode). Missing sections fall back gracefully.
 */
import { readdirSync, readFileSync, writeFileSync, existsSync, statSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join, dirname, resolve } from 'node:path';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, '../..');
const SKILLS_DIR = join(REPO_ROOT, 'skills');
const DATA_DIR = resolve(HERE, '../src/data');
const OUT_FILE = join(DATA_DIR, 'skills.json');
const ES_FILE = join(DATA_DIR, 'skills.es.json');
const GITHUB_BLOB = 'https://github.com/juandelossantos/another-agent-skills/blob/main';

/*
 * Category layer, from AGENTS-EXTENDED.md Rule 1 (plus `self-improvement`,
 * which that table omits). A skill missing from the map falls back to its
 * `tier` and is reported, so drift is visible instead of silent.
 */
const CATEGORIES = [
  { id: 'foundation', en: 'Foundation', es: 'Fundamentos', enDesc: 'Universal engineering philosophy, context setup and user preferences.', esDesc: 'Filosofía de ingeniería universal, configuración de contexto y preferencias del usuario.' },
  { id: 'ideation', en: 'Ideation', es: 'Ideación', enDesc: 'Refine raw ideas and extract requirements before committing to a plan.', esDesc: 'Refina ideas sin pulir y extrae requisitos antes de comprometerte con un plan.' },
  { id: 'process', en: 'Process', es: 'Proceso', enDesc: 'Specs, architecture, planning and the incremental build loop.', esDesc: 'Especificaciones, arquitectura, planificación y el ciclo de construcción incremental.' },
  { id: 'frontend', en: 'Frontend', es: 'Frontend', enDesc: 'Web, PWA, mobile, desktop and the shared UI component layer.', esDesc: 'Web, PWA, móvil, escritorio y la capa compartida de componentes de UI.' },
  { id: 'backend', en: 'Backend', es: 'Backend', enDesc: 'APIs, data, auth and command-line interfaces.', esDesc: 'APIs, datos, autenticación e interfaces de línea de comandos.' },
  { id: 'testing', en: 'Testing', es: 'Pruebas', enDesc: 'Tests first, browser verification and systematic debugging.', esDesc: 'Pruebas primero, verificación en navegador y depuración sistemática.' },
  { id: 'quality', en: 'Quality', es: 'Calidad', enDesc: 'Audits, review, security, performance and observability.', esDesc: 'Auditorías, revisión, seguridad, rendimiento y observabilidad.' },
  { id: 'design-review', en: 'Design review', es: 'Revisión de diseño', enDesc: 'Heuristic review, the audit to fix chain, and delight.', esDesc: 'Revisión heurística, la cadena de auditoría a corrección y el deleite.' },
  { id: 'design-skins', en: 'Design skins', es: 'Pieles de diseño', enDesc: 'Visual directions and output-enforcement skills.', esDesc: 'Direcciones visuales y skills de aplicación del formato de salida.' },
  { id: 'git', en: 'Git', es: 'Git', enDesc: 'Repository setup, branching and day-to-day version control.', esDesc: 'Configuración del repositorio, ramas y control de versiones diario.' },
  { id: 'devops', en: 'DevOps', es: 'DevOps', enDesc: 'CI/CD, deployment and production launch.', esDesc: 'CI/CD, despliegue y lanzamiento a producción.' },
  { id: 'metrics', en: 'Metrics', es: 'Métricas', enDesc: 'Background quality logging across projects.', esDesc: 'Registro de métricas de calidad en segundo plano entre proyectos.' },
  { id: 'meta', en: 'Meta', es: 'Meta', enDesc: 'Skills that work on the framework and its host agent.', esDesc: 'Skills que trabajan sobre el framework y su agente anfitrión.' },
];

const CATEGORY_OF = {
  'engineering-fundamentals': 'foundation',
  'context-engineering': 'foundation',
  'user-onboarding': 'foundation',
  'idea-refine': 'ideation',
  'interview-me': 'ideation',
  'spec-driven-development': 'process',
  'architecture-analysis': 'process',
  'planning-and-task-breakdown': 'process',
  'incremental-implementation': 'process',
  'source-driven-development': 'process',
  'doubt-driven-development': 'process',
  'multi-agent-orchestration': 'process',
  'deprecation-and-migration': 'process',
  'frontend-web': 'frontend',
  'frontend-pwa': 'frontend',
  'frontend-mobile': 'frontend',
  'frontend-desktop': 'frontend',
  'frontend-ui-engineering': 'frontend',
  'backend-api-mastery': 'backend',
  'api-and-interface-design': 'backend',
  'cli-tools': 'backend',
  'test-driven-development': 'testing',
  'browser-testing-with-devtools': 'testing',
  'debugging-and-error-recovery': 'testing',
  'debugging-three-strikes': 'testing',
  'project-health-check': 'quality',
  'code-review-and-quality': 'quality',
  'dev-environment-audit': 'quality',
  'security-and-hardening': 'quality',
  'performance-optimization': 'quality',
  'code-simplification': 'quality',
  'observability-and-instrumentation': 'quality',
  'documentation-and-adrs': 'quality',
  'critique-skill': 'design-review',
  'audit-skill': 'design-review',
  'clarify-skill': 'design-review',
  'hard-skill': 'design-review',
  'polish-skill': 'design-review',
  'typeset-skill': 'design-review',
  'adapt-skill': 'design-review',
  'optimize-skill': 'design-review',
  'delight-skill': 'design-review',
  'industrial-brutalist-ui': 'design-skins',
  'minimalist-ui': 'design-skins',
  'soft-premium-ui': 'design-skins',
  'output-skill': 'design-skins',
  'redesign-skill': 'design-skins',
  'git-init-and-versioning': 'git',
  'git-workflow-and-versioning': 'git',
  'gate': 'devops',
  'ci-cd-and-automation': 'devops',
  'shipping-and-launch': 'devops',
  'fullstack-shipping': 'devops',
  'project-metrics': 'metrics',
  'skill-creator': 'meta',
  'skill-improver': 'meta',
  'customize-opencode': 'meta',
  'self-improvement': 'meta',
};

const CATEGORY_ORDER = CATEGORIES.map((c) => c.id);

/* ------------------------------------------------------------------ *
 * Tiny YAML frontmatter parser (the SKILL.md subset only)
 * ------------------------------------------------------------------ */

function unquote(value) {
  const v = value.trim();
  if (v.length >= 2 && ((v[0] === '"' && v.at(-1) === '"') || (v[0] === "'" && v.at(-1) === "'"))) {
    return v.slice(1, -1);
  }
  return v;
}

function parseFrontmatter(raw) {
  const lines = raw.split(/\r?\n/);
  if (lines[0]?.trim() !== '---') return {};
  const end = lines.findIndex((line, i) => i > 0 && line.trim() === '---');
  if (end === -1) return {};

  const data = {};
  let currentKey = null;
  let blockMode = null;
  let blockLines = [];

  const flushBlock = () => {
    if (currentKey && blockMode) {
      const text =
        blockMode === '>'
          ? blockLines.join(' ').replace(/\s+/g, ' ').trim()
          : blockLines.join('\n').trim();
      data[currentKey] = text;
    }
    blockMode = null;
    blockLines = [];
  };

  for (const line of lines.slice(1, end)) {
    if (blockMode) {
      if (/^\s+\S/.test(line)) {
        blockLines.push(line.trim());
        continue;
      }
      flushBlock();
    }
    if (!line.trim() || line.trim().startsWith('#')) continue;

    const match = line.match(/^(\s*)([\w.-]+):\s*(.*)$/);
    if (!match) continue;
    const [, indent, key, rawValue] = match;

    if (indent.length === 0) {
      if (rawValue === '>' || rawValue === '|') {
        currentKey = key;
        blockMode = rawValue;
        blockLines = [];
        continue;
      }
      currentKey = key;
      data[key] = unquote(rawValue);
    } else if (currentKey) {
      if (typeof data[currentKey] !== 'object' || data[currentKey] === null) data[currentKey] = {};
      data[currentKey][key] = unquote(rawValue);
    }
  }
  flushBlock();
  return data;
}

/** Split the frontmatter from the Markdown body. */
function splitDoc(raw) {
  const lines = raw.split(/\r?\n/);
  if (lines[0]?.trim() !== '---') return { frontmatter: {}, body: raw };
  const end = lines.findIndex((line, i) => i > 0 && line.trim() === '---');
  if (end === -1) return { frontmatter: {}, body: raw };
  return {
    frontmatter: parseFrontmatter(raw),
    body: lines.slice(end + 1).join('\n'),
  };
}

/* ------------------------------------------------------------------ *
 * Section + description extraction
 * ------------------------------------------------------------------ */

function cleanInline(text) {
  return text
    .replace(/\*\*/g, '')
    .replace(/`([^`]*)`/g, '$1')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Bullets or paragraph prose from the first matching `## <name>` section. */
function extractSection(body, names) {
  const lines = body.split(/\r?\n/);
  const startRe = new RegExp(`^##\\s+(?:${names.join('|')})\\s*$`, 'i');
  const start = lines.findIndex((line) => startRe.test(line));
  if (start === -1) return [];

  const out = [];
  let paragraph = [];
  const flushParagraph = () => {
    if (paragraph.length) {
      const item = cleanInline(paragraph.join(' '));
      if (item && !NOISE.test(item)) out.push(item);
    }
    paragraph = [];
  };

  // Structural labels used inside some sections (not activation content).
  const NOISE = /^(?:MANDATORY|Invoke|Apply|Runs automatically|Triggered automatically|Skip)\b[^.]*:$|^AUTO-DETECTED\b/i;

  for (let i = start + 1; i < lines.length; i += 1) {
    const line = lines[i];
    if (/^##\s+/.test(line)) break;
    const bullet = line.match(/^\s*(?:[-*]|\d+\.)\s+(.+)$/);
    if (bullet) {
      flushParagraph();
      const item = cleanInline(bullet[1]);
      if (item && !NOISE.test(item)) out.push(item);
      continue;
    }
    if (!line.trim()) {
      flushParagraph();
      continue;
    }
    // Skip code fences, tables, blockquotes, thematic breaks and headings;
    // keep prose paragraphs.
    if (/^\s*(?:```|\||>|#{1,6}\s|-{3,}|\*{3,}|_{3,})/.test(line)) {
      flushParagraph();
      continue;
    }
    paragraph.push(line.trim());
  }
  flushParagraph();
  return out;
}

/*
 * The description packs the "what", an activation hint and the anti-trigger
 * into one line. Split it on the first marker sentence so the catalog can show
 * a clean one-liner, the triggers and the "do not use" note.
 */
const USE_MARKERS = [
  'Triggers on:',
  'Triggers:',
  'Use ONLY when',
  'Use when',
  'Use for',
  'Use with',
  'Use before',
  'Use after',
  'Use across',
  'Do NOT use',
  'Never invoke',
];
const MARKER_RE = new RegExp(`(?:^|\\.\\s)(${USE_MARKERS.map(escapeRe).join('|')})`);

function escapeRe(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function splitDescription(description) {
  const desc = cleanInline(description ?? '');
  const marker = desc.match(MARKER_RE);
  const what = (marker ? desc.slice(0, marker.index + 1) : desc).trim();
  return { desc, what };
}

function splitList(text) {
  return text
    .split(',')
    .map((part) => cleanInline(part).replace(/^(?:and|or)\s+/i, '').replace(/\.$/, ''))
    .filter(Boolean);
}

/** Explicit `Triggers:`/`Triggers on:` list, or the "Use when/for..." clause. */
function extractTriggers(desc) {
  const explicit = desc.match(/(?:^|\.\s)(?:Triggers on:|Triggers:)\s*([^.]*)/);
  if (explicit) {
    const triggers = splitList(explicit[1]);
    if (triggers.length) return triggers;
  }
  const clause = desc.match(
    /(?:^|\.\s)(?:Use ONLY when|Use when|Use for|Use with|Use before|Use after|Use across)\s+([^.]*)/,
  );
  if (clause) {
    const triggers = splitList(clause[1]);
    if (triggers.length) return triggers;
  }
  return [];
}

/** The `Do NOT use for ...` tail of the description, as a fallback. */
function extractDoNotUse(desc) {
  const match = desc.match(/(?:^|\.\s)(?:Do NOT use(?: for)?|Never invoke(?: directly)?)\s*:?\s*([^.]*)/);
  return match ? cleanInline(match[1]).replace(/\.$/, '') : '';
}

function titleFrom(name, heading) {
  if (heading) return heading;
  return name
    .split('-')
    .map((word) => (word ? word[0].toUpperCase() + word.slice(1) : word))
    .join(' ');
}

/** Turn a prose activation line into a short trigger phrase. */
function toTrigger(text) {
  const t = cleanInline(text)
    .replace(/^(?:Use ONLY when|Use when|Use for|Use with|Use before|Use after|Use across)\s*:?\s*/i, '')
    .replace(/^(?:MANDATORY|Invoke|Apply)\s+(?:when|for)\s*:?\s*/i, '')
    .trim();
  const firstSentence = t.split(/\.\s/)[0].replace(/\.$/, '').trim();
  return firstSentence || t;
}

function listGuides(skillDir) {
  const guidesDir = join(skillDir, 'guides');
  if (!existsSync(guidesDir) || !statSync(guidesDir).isDirectory()) return [];
  return readdirSync(guidesDir)
    .filter((file) => file.endsWith('.md'))
    .map((file) => file.replace(/\.md$/, ''))
    .sort((a, b) => a.localeCompare(b));
}

/* ------------------------------------------------------------------ *
 * Build
 * ------------------------------------------------------------------ */

function readSkill(name) {
  const skillDir = join(SKILLS_DIR, name);
  const raw = readFileSync(join(skillDir, 'SKILL.md'), 'utf8');
  const { frontmatter: fm, body } = splitDoc(raw);
  const heading = (body.match(/^#\s+(.+)$/m) ?? [])[1];
  const meta = typeof fm.metadata === 'object' && fm.metadata !== null ? fm.metadata : {};
  const { desc, what } = splitDescription(fm.description);

  const whenToUse = extractSection(body, ['When to Use', 'When to Activate']);
  const whenNotToUse = extractSection(body, ['When NOT to Use', 'When Not to Use']);

  const triggers = extractTriggers(desc);
  if (triggers.length === 0 && whenToUse.length > 0) triggers.push(toTrigger(whenToUse[0]));
  if (triggers.length === 0 && what) triggers.push(toTrigger(what));

  const notUse = whenNotToUse.length
    ? whenNotToUse
    : extractDoNotUse(desc)
      ? [extractDoNotUse(desc)]
      : [];

  const guides = listGuides(skillDir);
  const category = CATEGORY_OF[name];
  const tier = fm.tier ?? 'draft';

  return {
    name,
    title: titleFrom(name, heading),
    category: category ?? tier,
    tier,
    audience: meta.audience ?? 'all-engineers',
    workflow: meta.workflow ?? null,
    foundation: meta.foundation ?? null,
    compatibility: fm.compatibility ?? null,
    what: what || desc,
    triggers: triggers.length ? triggers : [what || desc],
    whenToUse: whenToUse.length ? whenToUse : [what || desc],
    whenNotToUse: notUse,
    guides,
    guideCount: guides.length,
    docsUrl: `${GITHUB_BLOB}/skills/${name}/SKILL.md`,
    categoryMapped: Boolean(category),
  };
}

function main() {
  const names = readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && existsSync(join(SKILLS_DIR, entry.name, 'SKILL.md')))
    .map((entry) => entry.name)
    .sort();

  const esMap = existsSync(ES_FILE) ? JSON.parse(readFileSync(ES_FILE, 'utf8')) : {};

  const warnings = [];
  const skills = names.map((name) => {
    const entry = readSkill(name);
    if (!entry.categoryMapped) {
      warnings.push(`no category for "${name}" — falling back to tier "${entry.tier}"`);
    }

    const es = esMap[name];
    const missing = [];
    if (!es || typeof es.what !== 'string' || !es.what.trim()) missing.push('what');
    if (!Array.isArray(es?.triggers) || es.triggers.length === 0) missing.push('triggers');
    if (!Array.isArray(es?.whenToUse) || es.whenToUse.length === 0) missing.push('whenToUse');
    if (!Array.isArray(es?.whenNotToUse)) missing.push('whenNotToUse');

    const fallback = missing.length > 0;
    if (fallback) warnings.push(`missing ES translation for "${name}": ${missing.join(', ')}`);

    const { categoryMapped, ...rest } = entry;
    return {
      ...rest,
      es: fallback
        ? {
            what: entry.what,
            triggers: entry.triggers,
            whenToUse: entry.whenToUse,
            whenNotToUse: entry.whenNotToUse,
            fallback: true,
          }
        : {
            what: es.what,
            triggers: es.triggers,
            whenToUse: es.whenToUse,
            whenNotToUse: es.whenNotToUse,
            fallback: false,
          },
    };
  });

  // Deterministic: category order, then name.
  skills.sort((a, b) => {
    const byCat = CATEGORY_ORDER.indexOf(a.category) - CATEGORY_ORDER.indexOf(b.category);
    return byCat !== 0 ? byCat : a.name.localeCompare(b.name);
  });

  const guideTotal = skills.reduce((sum, skill) => sum + skill.guideCount, 0);
  const dataset = {
    generatedFrom: 'skills/*/SKILL.md',
    skillCount: skills.length,
    guideCount: guideTotal,
    categories: CATEGORIES.map(({ id, en, es, enDesc, esDesc }) => ({
      id,
      en,
      es,
      enDesc,
      esDesc,
    })),
    skills,
  };

  mkdirSync(DATA_DIR, { recursive: true });
  writeFileSync(OUT_FILE, `${JSON.stringify(dataset, null, 2)}\n`, 'utf8');

  const missing = warnings.filter((w) => w.startsWith('missing ES'));
  console.log(
    `generate-skills: ${skills.length} skills, ${guideTotal} guides, ${CATEGORIES.length} categories → src/data/skills.json`,
  );
  if (missing.length) {
    console.warn(`generate-skills: ${missing.length} skill(s) missing ES translation (fell back to EN):`);
    for (const warning of missing) console.warn(`  - ${warning}`);
  }
  for (const warning of warnings.filter((w) => !w.startsWith('missing ES'))) {
    console.warn(`generate-skills: ${warning}`);
  }
  if (missing.length) {
    // Non-zero exit so CI surfaces the gap instead of shipping English on ES.
    process.exitCode = 1;
  }
}

main();
