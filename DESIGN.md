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

- **Sans display**: Geist (self-hosted woff2) — clean, modern, developer-friendly
- **Mono**: JetBrains Mono — for code blocks, install commands
- **Fallback**: `system-ui, -apple-system, sans-serif`

### Type Scale

| Token | Size | Weight | Line-Height | Usage |
|---|---|---|---|---|
| display | clamp(2.5rem, 5vw, 4rem) | 800 | 1.05 | Hero H1 |
| heading-1 | clamp(1.75rem, 3vw, 2.25rem) | 700 | 1.15 | Section titles |
| heading-2 | 1.125rem | 600 | 1.3 | Card titles, step headers |
| body | 1rem | 400 | 1.6 | Description text |
| body-small | 0.875rem | 400 | 1.5 | Secondary text |
| caption | 0.75rem | 600 | 1 | Labels, badges, stats |
| code | 0.8125rem | — | 1.5 | Install blocks, inline code |

## Color Palette

### Dark Theme

| Token | Value | Usage |
|---|---|---|
| --bg | #0A0A0B | Page background |
| --bg-secondary | #141416 | Card, section backgrounds |
| --bg-tertiary | #1C1C1F | Toggle group, input bg |
| --text | #F5F5F4 | Primary body text |
| --text-secondary | #A1A1AA | Secondary, descriptions |
| --text-muted | #71717A | Labels, captions |
| --accent | #3B82F6 | Interactive elements (sparingly) |
| --accent-hover | #60A5FA | Button hover state |
| --accent-subtle | rgba(59, 130, 246, 0.1) | Badge backgrounds |
| --border | #27272A | Dividers, card borders |
| --success | #22C55E | Copied state |
| --pipeline-bg | #0F0F11 | Pipeline section background |

### Light Theme

| Token | Value | Usage |
|---|---|---|
| --bg | #FAFAF8 | Page background (warm bone) |
| --bg-secondary | #F0EFED | Card backgrounds |
| --bg-tertiary | #E8E7E4 | Toggle group |
| --text | #1C1917 | Primary body |
| --text-secondary | #6B6B76 | Secondary |
| --text-muted | #A1A1AA | Labels |
| --accent | #2563EB | Interactive |
| --accent-hover | #1D4ED8 | Hover |
| --accent-subtle | rgba(37, 99, 235, 0.08) | Badge |
| --border | #E3E2E0 | Dividers |
| --success | #16A34A | Copied |
| --pipeline-bg | #F5F4F2 | Pipeline bg |

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
- ❌ Em-dashes (—) in copy
- ❌ "Scroll to explore" indicators
- ❌ Version footers ("v1.2.0", "Build 0042")
- ❌ Fake terminal/product UI made of divs
- ❌ Pills/tags floating over images
- ❌ Gradient text on headings
- ❌ `border-radius: 999px` on containers or cards

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
