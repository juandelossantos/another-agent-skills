# Anti-Slop Core — Universal AI Tell Catalogue

**Shared by all platform skills.** Platform-specific ANTI-SLOP-GUIDE.md adds banned layouts, platform-specific fonts, and UI patterns.

---

## 1. Universal Visual Tells

### Banned As Default

- Neon / outer glows
- Pure `#000000` black
- Oversaturated accents
- Excessive gradient text for headers
- Custom mouse cursors (a11y-hostile, perf-hostile)
- Div-based fake screenshots
- Glassmorphism on everything (use intentionally, with solid fallback)
- Pure `#ffffff` white backgrounds

### Banned Layout Signatures

- Three equal feature cards as default grid
- Centered hero + H1 + dark mesh background
- Edge-to-edge sticky navbars glued to the top
- Step / number labels on non-sequential sections (`"01"`, `"02"`)
- Middle-dot `·` overuse as visual separators
- `<br>`-broken headlines (artificial breaks)
- Vertical rotated text on section edges
- Crosshair grid lines overlay on backgrounds
- Fake version footers (`© 2026 — v2.4.1`)
- Scroll cues (`scroll down`, `↓`, animated arrows)

### Card & Container Tells

- Cards when elevation isn't needed (use `border-t`, `divide-y`, or whitespace instead)
- `border-b` on every single row in a list
- Mixed corner radii without documented rules
- Pure-black drop shadows on light backgrounds
- Bento grids with empty cells
- All white-on-white bento with only typography inside

---

## 2. Universal Typography Tells

- Em-dash `—` in visible text (single most-violated AI tell)
- Mixed-family emphasis (random serif word in sans headline)
- Oversized H1s that scream (control hierarchy with weight + color, not raw scale)

### Eyebrow Restraint

An "eyebrow" is the small label above a section heading. Hard rule: **max 1 per 3 sections.**

---

## 3. Content Density Rules

### Landing Page Content Shape

Per section: headline (≤ 8 words) + sub-paragraph (≤ 25 words) + one visual OR one CTA.

### Hero Discipline

- Fits initial viewport — headline ≤ 2 lines, subtext ≤ 20 words, CTAs visible without scroll
- Max 4 text elements: eyebrow + headline + subtext + CTAs
- **Banned inside hero:** trust strips, avatar rows, feature bullets, pricing teasers

### Long List Alternatives

No `<ul>` with 20 bullets. Reach for:
- 2-column split with grouped items
- Card grid with image + label per item
- Tabs / accordion if categorisable
- Horizontal scroll-snap pills
- Carousel for breadth-heavy lists
- Marquee for items that don't need individual attention

### Spec Sheet Ban

Product spec with `border-b` on every row is an AI default. Alternatives:
- 2-col card grid with spec + "why it matters"
- Scroll-snap horizontal pills
- Grouped chunks with cluster headings
- Featured-vs-rest (3-4 hero specs, rest under "View full specs")

---

## 4. Copy Self-Audit Protocol

Before declaring done, re-read every visible string:

### Flag These

- Grammatically broken text
- Unclear referents ("we plan to stay that way" without prior context)
- AI-hallucinated copy (forced metaphors, "elegant nothing" phrases)
- Fake-craftsman labels ("hand-stitched digital experience")
- Fake-precise numbers (`92%`, `4.1×`, `5.8 mm`) without real data

### Copy Register

One copy register per page. Do not mix technical mono, editorial prose, and marketing punch unless brand voice demands it.

### CTA Labels

- No wrapped buttons at desktop (if label wraps, shorten or widen)
- No duplicate intent: "Get in touch" + "Contact us" + "Let's talk" = same intent → pick ONE label per page

---

## 5. UI State Tells

LLMs default to "static successful state only." Always implement:

- **Loading:** Skeletal loaders matching layout shape. No generic circular spinners.
- **Empty states:** Beautiful, with guidance on how to populate.
- **Error states:** Clear, inline (forms) or contextual (toasts for transient only).
- **Tactile feedback:** `active:scale-[0.98]` or equivalent on interactive elements.
- **Button contrast:** WCAG AA minimum (4.5:1 body, 3:1 large text).

### Page Theme Lock

One page = one theme. Sections do not invert:
- Dark page = ALL sections dark
- Light page = ALL sections light
- Exception: deliberate color block transition, **once per page**

---

## 6. Emoji Policy

Discouraged by default in code, markup, and visible text. Replace symbols with icon-library glyphs.

Override: allow only when the user explicitly asks for playful / chat-style / social-native vibe.
