# Frontend Web — Design Guide

**Web-specific design reference.** See `engineering-fundamentals/guides/DESIGN-CORE.md` for the universal Three Dials System, Brief Inference, color principles, and dark mode protocol.

This document adds web-specific font selection, token application, banned lists, and platform-specific implementation.

---

## 1. Vibe → Dial Inference

After the Design Read (Phase 0b), infer dial values from the brief's signals:

| Signal / Vibe | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| Minimalist / clean / calm / Linear-style | 5-6 | 3-4 | 2-3 |
| Premium consumer / Apple-y / luxury | 7-8 | 5-7 | 3-4 |
| Playful / Dribbble / Awwwards / agency | 9-10 | 8-10 | 3-4 |
| Landing / portfolio / marketing (default) | 7-9 | 6-8 | 3-5 |
| Trust-first / public-sector / a11y-critical | 3-4 | 2-3 | 4-5 |
| Redesign — preserve | match existing | +1 | match |
| Redesign — overhaul | +2 | +2 | match |

### Default Presets

| Use case | VAR | MOT | DEN |
|---|---|---|---|
| SaaS landing (mainstream) | 7 | 5 | 4 |
| Agency / creative landing | 9 | 8 | 3 |
| Premium consumer landing | 7 | 5 | 3 |
| Designer portfolio | 8 | 7 | 3 |
| Developer portfolio | 6 | 4 | 4 |
| Editorial / Blog | 6 | 3 | 3 |
| Public-sector service | 3 | 2 | 5 |

---

## 2. Dial Technical Reference

### DESIGN_VARIANCE (1-10)
- **1-3 (Predictable):** Symmetrical 12-col grid, equal paddings, centered alignment.
- **4-7 (Offset):** `margin-top: -2rem` overlaps, varied aspect ratios, left-aligned headers.
- **8-10 (Asymmetric):** Masonry, fractional CSS Grid (`2fr 1fr 1fr`), massive empty zones (`padding-left: 20vw`).

### MOTION_INTENSITY (1-10)
- **1-3 (Static):** CSS `:hover` and `:active` only. `prefers-reduced-motion` is default.
- **4-7 (Fluid CSS):** `cubic-bezier(0.16, 1, 0.3, 1)` transitions, `animation-delay` cascades, Framer Motion `whileInView`.
- **8-10 (Advanced):** Scroll-triggered reveals, parallax, GSAP ScrollTrigger (pinned sections only). NEVER `window.addEventListener('scroll')`.

### VISUAL_DENSITY (1-10)
- **1-3 (Art Gallery):** `py-32` to `py-48` section gaps, huge whitespace.
- **4-7 (Daily App):** `py-16` to `py-24` standard spacing.
- **8-10 (Cockpit):** Tight paddings, no card boxes, `1px` line separators, `font-mono` for numbers.

### Mobile Collapse Rule
For VARIANCE > 4: asymmetric layouts above `md:` MUST collapse to single-column on viewports < 768px (`w-full`, `px-4`, `py-8`, no overlapping, no masonry).

---

## 3. Typography

### Font Selection

| Role | Preferred | Banned as default |
|---|---|---|
| Sans display | Geist, Outfit, Cabinet Grotesk, Satoshi | Inter, Roboto, Arial, Space Grotesk |
| Serif (rare) | PP Editorial New, GT Sectra, Reckless Neue, Tiempos Headline | Fraunces, Instrument Serif |
| Monospace | JetBrains Mono, Geist Mono, IBM Plex Mono | — |

### Pairings
- Geist + Geist Mono
- Satoshi + JetBrains Mono
- Cabinet Grotesk + Inter Tight
- GT America + IBM Plex Mono

### Serif Discipline
Serif is **very discouraged as default**. Only acceptable when:
1. The brand brief literally names a serif font, OR
2. The aesthetic is genuinely editorial / luxury / publication / heritage

For everything else, default sans-serif display. Do not inject a random serif word into a sans headline for emphasis — use italic/bold of the same font.

### Italic Descender Clearance
When italic is used in display type and the word contains `y`, `g`, `j`, `p`, `q`: use `leading-[1.1]` minimum and add `pb-1` on the wrapping element.

### Font Loading
Always use `next/font/google` with CSS variables (`--font-display`, `--font-body`). Never `<link>` Google Fonts in production.

### Scale Defaults
- Display / Headlines: `text-4xl md:text-6xl tracking-tighter leading-none`
- Body: `text-base leading-relaxed max-w-[65ch]`
- Mono metadata: `text-sm` or `text-xs`

---

## 4. Color

### The Lila Rule
**No AI-purple/blue glow as default.** No automatic purple button glows, no random neon gradients. Use neutral bases (Zinc, Slate, Stone) with high-contrast singular accents (Emerald, Electric Blue, Deep Rose, Burnt Orange).

Override: if the brand explicitly asks for purple, embrace it — but with a consistent palette and restrained gradients.

### Premium-Consumer Palette Ban
The AI-default beige+brass+espresso family is **banned as the default reach** for premium-consumer briefs. Banned hex families:

- Backgrounds: `#f5f1ea`, `#f7f5f1`, `#fbf8f1`, `#efeae0`, `#ece6db`, `#e8dfcb`
- Accents: `#b08947`, `#b6553a`, `#9a2436`, `#9c6e2a`, `#bc7c3a`, `#7d5621`
- Text: `#1a1714`, `#1a1814`, `#1b1814`

**Default alternatives (rotate, do not reuse consecutively):**
- Cold Luxury: silver-grey + chrome + smoke
- Forest: deep green + bone + amber
- Black and Tan: true off-black + warm tan
- Cobalt + Cream: saturated blue against single neutral
- Terracotta + Slate: warm rust + cool grey
- Olive + Brick + Paper: muted olive + brick-red accent
- Pure monochrome + single saturated pop

### Color Rules
- Max 1 accent color, saturation < 80%
- Once chosen, lock it for the whole page. No warm-grey site + blue CTA
- No pure `#000000` black or pure `#ffffff` white — use off-black/off-white
- All colors as CSS custom properties from DESIGN.md, never Tailwind generics

---

## 5. Dark Mode Protocol

- Design for both modes from the start. Never ship light-only or dark-only.
- Use Tailwind `dark:` variant or CSS variables. Pick one per project.
- Maintain visual hierarchy and WCAG AA contrast in both modes.
- Respect `prefers-color-scheme`. Add manual toggle if brand identity demands it.
- Test in both modes before shipping.

### Token Strategy
- Tailwind projects: every color utility paired with `dark:` variant
- shadcn/Radix projects: CSS variables in `:root` and `.dark` / `[data-theme="dark"]`
- No pure `#000000` or `#ffffff` in either mode
