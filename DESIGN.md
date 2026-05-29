# Design: Another Agent Skills Landing Page

## Brief

Product showcase landing page for an open-source agent skills framework. Target: senior developers using AI coding agents who want production-grade outputs. Tone: confident, mechanical, premium — no hype, no slop.

## Three Dials

| Dial | Value | Why |
|---|---|---|
| Variance | Low | Single page, coherent visual system |
| Motion | Subtle | Scroll-triggered reveals, pipeline sequence animation |
| Density | Medium | Balance of whitespace and code/content density |

## Typography

- **Display / Headlines**: Newsreader (serif) — editorial weight, magazine feel
- **Body / UI**: System UI (`system-ui, -apple-system, sans-serif`) — zero external load, clean
- **Mono**: JetBrains Mono — for code blocks, install commands, labels
- **Variable font**: Newsreader has `opsz` axis — `opsz 72` for display, `opsz 6` for body

### Type Scale

| Token | Size | Weight | Line-Height | Usage |
|---|---|---|---|---|
| display | clamp(3rem, 8vw, 5.5rem) | 800 | 0.92 | Hero H1 |
| heading-xl | 2.5rem | 700 | 1.05 | Section titles |
| heading-lg | 1.75rem | 600 | 1.15 | Card titles |
| body | 1rem | 400 | 1.7 | Description text |
| body-small | 0.875rem | 400 | 1.6 | Secondary text |
| caption | 0.75rem | 600 | 1.4 | Labels, badges, stats (minimum) |
| code | 0.8125rem | — | 1.5 | Install blocks, code |

## Color Palette

### Dark Theme

| Token | Value | Usage | Contrast |
|---|---|---|---|
| --bg | #1A1A18 | Page background (warm dark gray) | — |
| --bg-card | #222220 | Card, section backgrounds | — |
| --bg-code | #1E1E1C | Code block backgrounds | — |
| --text | #E8E6E3 | Primary body text | 13.99:1 AAA |
| --text-secondary | #A09E9A | Secondary, descriptions | 6.52:1 AA |
| --text-muted | #7A7772 | Labels, captions | 3.91:1 AA-lg |
| --accent | #DC5C20 | Interactive elements (burnt orange) | 4.64:1 AA |
| --accent-dim | rgba(220, 92, 32, 0.12) | Subtle accent backgrounds | — |
| --border | #2C2A28 | Dividers, card borders | decorative |
| --border-light | #3A3835 | Lighter borders | decorative |
| --green | #3CCE1E | Terminal success, copied state | 8.33:1 AAA |

### Light Theme

| Token | Value | Usage | Contrast |
|---|---|---|---|
| --bg | #F2F0ED | Page background (warm light gray) | — |
| --bg-card | #F8F7F5 | Card backgrounds (warm near-white) | — |
| --bg-code | #EEEDEA | Code block backgrounds | — |
| --text | #2A2826 | Primary body text | 12.91:1 AAA |
| --text-secondary | #545250 | Secondary, descriptions | 6.84:1 AA |
| --text-muted | #6F6C68 | Labels, captions | 4.59:1 AA |
| --accent | #B8450E | Interactive elements (burnt orange) | 4.74:1 AA |
| --accent-dim | rgba(184, 69, 14, 0.1) | Subtle accent backgrounds | — |
| --border | #D8D6D2 | Dividers, card borders | decorative |
| --border-light | #C8C6C2 | Lighter borders | decorative |
| --green | #167A32 | Terminal success, copied state | 4.78:1 AA |

## Pipeline Stage Colors

Each of the 9 stages gets a distinct, muted color. No purple.

| Stage | Color | Usage |
|---|---|---|
| Critique | #DC2626 (red) | Evaluation, review |
| Audit | #D97706 (amber) | Technical scan |
| Clarify | #059669 (emerald) | UX copy |
| Harden | #2563EB (blue) | ARIA, states, i18n |
| Polish | #7C3AED (violet) | Spacing, tokens |
| Typeset | #9333EA (purple) | Typography |
| Adapt | #DB2777 (pink) | Responsive |
| Optimize | #0D9488 (teal) | Performance |
| Delight | #E11D48 (rose) | Micro-interactions |

## Anti-Pattern Bans (enforced)

- ❌ Purple gradients or mesh gradients anywhere
- ❌ "From AI Slop", "Elevate", "Seamless", "Unleash", "Supercharge"
- ❌ Three or more equal-sized cards in a row
- ❌ Em-dashes (—) in copy (use spaced en-dash instead)
- ❌ "Scroll to explore" indicators
- ❌ Version footers ("v1.2.0", "Build 0042")
- ❌ Fake terminal/product UI made of divs (terminal is acceptable as design accent, not as functional mockup)
- ❌ Pills/tags floating over images
- ❌ Gradient text on headings
- ❌ `border-radius: 999px` on containers or cards
- ❌ Inter, Geist, or any generic sans-serif for headings (reserved for body/system only)

## Component Specs

### Pipeline Visual
- Horizontal scrollable on mobile, full-width on desktop
- Each stage: colored circle (40px) + label below
- Connecting dots/lines between stages
- Animate in sequence on scroll (80ms stagger)
- On hover: scale circle 1.12x + subtle glow matching stage color

### Skills Grid
- Asymmetric — not all equal size
- Featured skills get more visual weight (larger or highlighted)
- Cards: border, 8px radius, no shadow, hover lifts 2px
- Icons: minimal letter icons in pastel bg, not generic SVG icons

### Install Block
- Inline code with copy button
- Monospace font
- No fake terminal chrome

### FAQ
- Clean `border-bottom` dividers (no card containers)
- Accordion with smooth max-height transition
- Arrow rotates on open

### Buttons
- Primary: solid dark bg, white text, 6px radius, no shadow
- Secondary: border only, transparent bg
- Hover: darker bg on primary, border color shift on secondary
- Active: scale(0.98)

## Layout Structure

```
Header (fixed, 56px)
  Logo | Nav: Pipeline Skills Quick Start FAQ | [GitHub]

Hero (centered, large padding)
  Tag badge | H1 | Subtitle | Pipeline visual | Install block | CTA buttons | Stats row

Pipeline Section (full-width bg)
  Each stage with description

Skills Section (asymmetric grid)
  Featured card + regular cards mixed

Quick Start (numbered steps, left-aligned)

Why Different (positioning vs alternatives)

FAQ (border-bottom accordion)

Footer (border-top, simple links)
```

## Motion

- Scroll reveals: `opacity 0 → 1` + `translateY(20px) → 0`, 600ms, `cubic-bezier(0.16, 1, 0.3, 1)`
- Pipeline nodes: stagger 80ms per node
- FAQ accordion: max-height transition 300ms
- Copy button: flash green 200ms, revert after 2s
- `prefers-reduced-motion`: disable all transitions, keep nodes visible

## Design Files

- This file: `DESIGN.md` (design contract)
- Implementation: `index.html`
- i18n: `i18n/en.json`, `i18n/es.json`
- Styles: `css/style.css` + `css/pipeline.css`
- Scripts: `js/main.js`, `js/animations.js`
