# Frontend Web — Anti-Slop Guide

Catalogue of AI tells, content density rules, and copy self-audit protocol. Referenced from `frontend-web/SKILL.md` Phase 5.

---

## 1. Visual & CSS Tells

### Banned As Default
- Neon / outer glows
- Pure `#000000` black
- Oversaturated accents
- Excessive gradient text for headers
- Custom mouse cursors (outdated, a11y-hostile, perf-hostile)
- Div-based fake screenshots (product previews built with `<div>` rectangles)
- Glassmorphism on everything (use intentionally, with solid fallback)
- `h-screen` for hero sections — always `min-h-[100dvh]`

### Banned AI Layout Signatures
- Three equal feature cards as default grid
- Centered hero + H1 + dark mesh background
- "Used by" / "Trusted by" logo wall inside the hero (belongs in a dedicated section below)
- Edge-to-edge sticky navbars glued to the top (prefer floating / island nav)
- Step / number labels on sections that don't form a sequence (no `"01"`, `"02"` eyebrow markers on non-sequential content)
- Middle-dot `·` overuse as visual separators between nav items or inline text
- `<br>`-broken headlines (artificial line breaks that don't match the content's natural reading)
- Vertical rotated text on section edges (aesthetic-only, reduces readability)
- Crosshair grid lines overlay on backgrounds
- Fake version footers (e.g., `© 2026 — v2.4.1` when no versioning exists)
- Scroll cues (`scroll down`, `↓`, animated arrows telling users to scroll)

### Card & Container Tells
- Cards when elevation isn't needed (group with `border-t`, `divide-y`, or whitespace instead)
- `border-b` on every single row in a list or table
- Mixed corner radii without documented rules
- Pure-black drop shadows on light backgrounds (tint shadow to background hue)
- Bento grids with empty cells (cell count = content count)
- All white-on-white bento with only typography inside

---

## 2. Typography Tells

### Hard Bans
- Inter as default display font (acceptable only for public-sector / a11y-first)
- Fraunces and Instrument Serif as serif defaults
- Em-dash `—` in visible text (single most-violated AI tell)
- Mixed-family emphasis (random serif word in sans headline for "visual interest")
- Oversized H1s that scream (control hierarchy with weight + color, not raw scale)

### Eyebrow Restraint
An "eyebrow" is the small uppercase label above a section headline (`text-[11px] uppercase tracking-[0.18em]`). Every AI site puts one above EVERY heading.

**Hard rule:** Max 1 eyebrow per 3 sections. Hero counts as 1. If section A has one, the next 2 cannot.

**What to do instead of an eyebrow:** Drop it entirely. The headline alone is enough.

---

## 3. Content Density Rules

### Landing Page Content Shape
Per section: headline (≤ 8 words) + sub-paragraph (≤ 25 words) + one visual OR one CTA.

### Hero Discipline
- Fits in initial viewport (headline ≤ 2 lines, subtext ≤ 20 words, CTAs visible without scroll)
- Max 4 text elements: eyebrow OR brand strip (pick 0 or 1) + headline + subtext + CTAs (1 primary + max 1 secondary)
- **Banned inside hero:** taglines below CTAs, trust strips, avatar rows, feature bullets, pricing teasers
- Top padding max `pt-24` at desktop
- Font scale: `text-4xl md:text-5xl lg:text-6xl` for most heroes; `text-6xl md:text-7xl` only for 3-5 word headlines

### Long List Alternatives
No `<ul>` with 20 bullets. Reach for:
- 2-column split with grouped items
- Card grid with image + label per item
- Tabs / accordion if categorisable
- Horizontal scroll-snap pills
- Carousel for breadth-heavy lists
- Marquee for items that don't need individual attention

### Spec Sheet Ban
A product spec table with `border-b` on every row is the AI default for cookware / hardware / apparel. Banned. Alternatives:
- 2-col card grid with spec name + value + "why it matters"
- Scroll-snap horizontal pills
- Grouped chunks (3 logical clusters with cluster headings)
- Featured-vs-rest (3-4 hero specs visualised, rest under "View full specs")

### Quote Rules
- Max 3 lines of quote body
- Attribution: name + role + (optionally) company
- Use typographic quotes (" ") or none. Not straight ASCII (")
- No em-dashes inside quote text

---

## 4. Copy Self-Audit Protocol

Before declaring done, re-read every visible string:

### Flag These
- Grammatically broken text
- Unclear referents ("we plan to stay that way" without prior context)
- AI-hallucinated copy (forced metaphors, "elegant nothing" phrases)
- LLM-trying-to-sound-thoughtful (passive-aggressive humility, fake-craftsman labels)
- Fake-precise numbers (`92%`, `4.1×`, `5.8 mm`) without real data

### Copy Register
One copy register per page. Don't mix technical mono, editorial prose, and marketing punch unless the brand voice demands it.

### CTA Labels
- No wrapped CTAs at desktop (if label wraps, shorten or widen the button)
- No duplicate intent: "Get in touch" + "Contact us" + "Let's talk" = same intent → pick ONE label for the whole page

---

## 5. Image & Asset Tells

- Div-based fake screenshots are **banned**
- Plain text wordmarks as logos for made-up brands: generate an SVG monogram instead
- Logo wall = logos only. No industry labels below logos (no "Vercel" + "hosting")
- Hand-rolled decorative SVGs: strongly discouraged as default
- Text-only hero with gradient blob: that's a placeholder, not a hero

### Image Priority
1. Image-gen tool (if available) — generate section-specific assets
2. Real web images (`picsum.photos/seed/{descriptive-seed}/{w}/{h}`)
3. Placeholder slots with `<!-- TODO -->` — tell the user what's needed

---

## 6. UI State Tells

LLMs default to "static successful state only." Always implement:

- **Loading:** Skeletal loaders matching layout shape. No generic circular spinners.
- **Empty states:** Beautiful, with guidance on how to populate.
- **Error states:** Clear, inline (forms) or contextual (toasts for transient only).
- **Tactile feedback:** `active:scale-[0.98]` or `active:-translate-y-[1px]` on interactive elements.
- **Button contrast check:** WCAG AA minimum (4.5:1 body, 3:1 large text). No white button + white text.

---

## 7. Page Theme Lock

One page = one theme. Sections do not invert:
- Dark page = ALL sections dark
- Light page = ALL sections light
- Exception: "Color Block Story" with a deliberate transition, **once per page**

---

## 8. Emoji Policy

Discouraged by default in code, markup, and visible text. Replace symbols with icon-library glyphs (Phosphor, Radix, Tabler).

Override: allow only when the user explicitly asks for playful / chat-style / social-native vibe.
