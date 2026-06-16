# Design Core — Universal Design Direction

**Shared by all platform skills.** Platform-specific DESIGN-GUIDE.md adds banned lists, font stacks, build commands, and animation libraries.

Each platform skill references this guide. Do not duplicate this content.

---

## 1. Brief Inference (Phase 0b)

**Read 6 signals before any code:**

1. **Page kind** — landing, SaaS, portfolio, e-commerce, dashboard, documentation
2. **Vibe words** — calm, energetic, technical, warm, cold, experimental, premium, playful
3. **Reference URLs** — any existing sites or apps the user likes
4. **Audience** — consumers, developers, executives, patients, general public
5. **Existing brand assets** — logo, colors, fonts, or "start from scratch"
6. **Quiet constraints** — a11y-first, regulated industry, trust-first, performance-critical

**Output one-line Design Read:**
> `"Reading this as: <page kind> for <audience>, <vibe>, leaning toward <system>."`

**Anti-Default Discipline:** Do not default to AI-purple gradients, centered hero over dark mesh, three equal feature cards, or generic fonts.

---

## 2. Design Principles

### 2a. Ground in the Subject

Before any visual decision, name three things explicitly:

1. **Subject** — What is this page about? Be concrete: "a task manager for remote construction teams," not "a productivity app."
2. **Audience** — Who reads this? "Site supervisors juggling 3 devices," not "users."
3. **Single job** — What must this page accomplish? "Prove this tool saves 2 hrs/day," not "look professional."

The subject's own world — its materials, instruments, artifacts, vernacular — is where distinctive design choices come from. A construction tool should reference site plans and safety vest orange, not startup-purple. Build with the brief's real content throughout.

### 2b. Hero Is a Thesis

The hero section is a thesis statement, not a template slot. Open with the single most characteristic thing about the subject, in whatever form suits it best:

- A headline that names the job to be done
- An interactive demo of the core mechanic
- A data point that reframes the problem
- A photograph of the subject in its actual environment

Be deliberate: a big number with a smaller label, supporting stats, and a gradient accent is the template answer. Use it only if that is genuinely the best way to open this specific subject. The template hero (headline + subtext + CTA + mockup) is a fallback, never a default.

### 2c. Typography Carries Personality

Typography is the most visible carrier of a design's point of view. Choose deliberately:

| Role | Goal | Anti-pattern |
|---|---|---|
| **Display face** | Characterful, used with restraint (headings only, max 2-3 sizes) | Default system font or AI-favorite (Inter, Space Grotesk, Geist) |
| **Body face** | Complementary, readable at text sizes, distinct from display | Same family as display (default pair) |
| **Utility face** | Data, captions, code (if needed) | Ignoring this role entirely |

- Pair display and body deliberately. Satoshi + JetBrains Mono is a choice. Inter + Inter is not.
- Set a clear type scale with intentional weights, widths, and spacing. The type treatment itself should be memorable.
- Banned as display defaults: Inter, Roboto, Arial, Space Grotesk, Fraunces, Instrument Serif.

### 2d. Structure Is Information

Structural devices — numbering, eyebrows, dividers, labels — must encode something true about the content, not decorate it.

- Numbered items (01, 02, 03) are appropriate only when the content is a real sequence: a process with ordered steps, a timeline, a narrative where position carries meaning.
- If items could be reordered without loss, numbering is decoration. Use unlabeled sections or a grid instead.
- Dividers should separate distinct concepts. If everything has a divider, nothing is separated.
- Labels should name what something is, not where it appears. "Pricing" not "Section 3."

---

## 3. Three Dials System

Replace 8 fixed aesthetic directions with **3 parametric dials** set after Design Read:

### DESIGN_VARIANCE (1-10)

| Range | Character | Pattern |
|---|---|---|
| **1-3 (Predictable)** | Symmetrical grids, equal spacing, centered | Safe, trustworthy, utilitarian |
| **4-7 (Offset)** | Asymmetric but balanced, varied ratios | Typical landing, product, portfolio |
| **8-10 (Asymmetric)** | Masonry, fractional grids, massive empty zones | Creative agency, experimental |

### MOTION_INTENSITY (1-10)

| Range | Character | Pattern |
|---|---|---|
| **1-3 (Static)** | CSS hover/active only | Public-sector, a11y-first, editorial |
| **4-7 (Fluid)** | Entrance reveals, cascade delays, spring physics | Standard landing, product |
| **8-10 (Cinematic)** | Scroll-triggered reveals, parallax, pinned sections | Agency, storytelling, premium |

### VISUAL_DENSITY (1-10)

| Range | Character | Pattern |
|---|---|---|
| **1-3 (Airy)** | Large section gaps, huge whitespace | Portfolio, premium, editorial |
| **4-7 (Standard)** | Normal spacing, comfortable reading | Product, landing, SaaS |
| **8-10 (Dense)** | Tight padding, data-rich, mono numbers | Dashboard, cockpit, terminal |

### Use Case → Dial Presets

| Use case | VAR | MOT | DEN |
|---|---|---|---|
| SaaS landing (mainstream) | 7 | 5 | 4 |
| Agency portfolio | 8 | 7 | 3 |
| Premium consumer | 7 | 5 | 3 |
| Editorial / Blog | 6 | 3 | 3 |
| Public-sector service | 3 | 2 | 5 |
| Developer portfolio | 6 | 4 | 4 |
| Designer portfolio | 8 | 7 | 3 |
| Dashboard / Admin | 4 | 2 | 7 |

### Vibe → Dial Inference

| Signal / Vibe | VAR | MOT | DEN |
|---|---|---|---|
| Minimal / calm / Linear-style | 5-6 | 3-4 | 2-3 |
| Premium consumer / Apple-y | 7-8 | 5-7 | 3-4 |
| Playful / agency / Dribbble | 9-10 | 8-10 | 3-4 |
| Landing / portfolio / marketing (default) | 7-9 | 6-8 | 3-5 |
| Trust-first / public-sector | 3-4 | 2-3 | 4-5 |
| Redesign — preserve brand | match | +1 | match |
| Redesign — overhaul | +2 | +2 | match |

### Mobile Collapse Rule

For VARIANCE > 4: asymmetric layouts collapse to single-column on viewports < 768px. No overlapping, no masonry on mobile.

---

## 3. Universal Color Principles

### The Lila Rule

**No AI-purple/blue glow as default.** No automatic purple button glows, no random neon gradients. Use neutral bases (Zinc, Slate, Stone) with high-contrast singular accents.

Override: if brand explicitly asks for purple, embrace it with a consistent palette.

### Premium-Consumer Palette Ban

AI-default beige+brass+espresso hex families are **banned as the default reach**:

**Banned backgrounds:** `#f5f1ea`, `#f7f5f1`, `#fbf8f1`, `#efeae0`, `#ece6db`, `#e8dfcb`
**Banned accents:** `#b08947`, `#b6553a`, `#9a2436`, `#9c6e2a`, `#bc7c3a`, `#7d5621`
**Banned text:** `#1a1714`, `#1a1814`, `#1b1814`

**Default alternatives (rotate, do not reuse consecutively):**
- Cold Luxury: silver-grey + chrome + smoke
- Forest: deep green + bone + amber
- Black and Tan: true off-black + warm tan
- Cobalt + Cream: saturated blue against single neutral
- Terracotta + Slate: warm rust + cool grey
- Olive + Brick + Paper: muted olive + brick-red
- Pure monochrome + single saturated pop

### Color Rules
- Max 1 accent color, saturation < 80%
- Lock accent for whole page — no warm-grey site + blue CTA
- No pure `#000000` or pure `#ffffff` — use off-black/off-white
- All colors from DESIGN.md tokens, never hardcoded generics

---

## 4. Dark Mode Protocol

- Design for both modes from the start. Never ship light-only or dark-only.
- Use CSS variables or the platform's theme mechanism. Pick one per project.
- Maintain visual hierarchy and WCAG AA contrast in both modes.
- Respect `prefers-color-scheme` (or platform equivalent). Add manual toggle if brand demands it.
- Test in both modes before shipping.
- No pure `#000000` or `#ffffff` in either mode.

---

## 5. Platform Extension

Each platform skill MUST:
1. Reference DESIGN-CORE.md in Phase 3 (or equivalent)
2. Add platform-specific DESIGN-GUIDE.md with banned font lists, font loading, and stack-specific tokens
3. Add platform-specific ANIMATION-GUIDE.md
4. Keep the Three Dials System consistent — only extend, never override
