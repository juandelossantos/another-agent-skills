# Frontend Web — Design Guide

**Web-specific design reference.** See `engineering-fundamentals/guides/DESIGN-CORE.md` for the universal Three Dials System, Brief Inference, color principles, and dark mode protocol.

This document adds web-specific font selection, token application, banned lists, and platform-specific implementation.

---

## 1. Dial Technical Reference

→ See `engineering-fundamentals/guides/DESIGN-CORE.md` for the canonical Vibe→Dial Inference, Use Case dial presets, and Mobile Collapse Rule.

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

## 2. Typography

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

## 3. Color & Dark Mode

→ See `engineering-fundamentals/guides/DESIGN-CORE.md` for universal color principles (Lila Rule, Premium Palette Ban, color rules) and dark mode protocol.

**Web-specific token application:**

Colors and dark mode tokens MUST use CSS custom properties:

```
:root {
  --color-bg: #f4f4f0;
  --color-fg: #1a1814;
  --color-accent: #2563eb;
}

.dark {
  --color-bg: #1a1814;
  --color-fg: #f4f4f0;
}
```

- **Tailwind projects:** every color utility paired with `dark:`. Use `@theme` in CSS, never `tailwind.config.ts`.
- **shadcn/Radix projects:** CSS variables in `:root` and `.dark`. Use `hsl()` for compatibility.
- **No pure `#000000` or `#ffffff`** — use off-black/off-white from DESIGN.md tokens.
- **All colors from DESIGN.md tokens** — never Tailwind generic colors, never hardcoded hex.
