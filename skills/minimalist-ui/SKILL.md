---
name: minimalist-ui
description: "Design editorial product UI inspired by Notion and Linear: warm monochrome palette, typographic contrast, flat bento grids, muted pastel accents. Do NOT use for industrial or brutalist UIs."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-shadcn
  style: minimal-editorial
---

# Minimalist UI

Clean editorial-style interfaces with high-contrast warm monochrome palette, bespoke typographic hierarchy, and ultra-flat component architecture.

## When to Use

Product UIs, documentation sites, SaaS dashboards, editorial layouts. Not for playful consumer brands or experimental agency sites.

## Banned Elements

- Inter, Roboto, Open Sans as typefaces
- Lucide, Feather, Heroicons — use Phosphor (Bold) or Radix Icons
- Tailwind `shadow-md`, `shadow-lg`, `shadow-xl`
- Primary colored backgrounds for large sections
- Gradients, neon, 3D glassmorphism
- `rounded-full` for containers, cards, or primary buttons
- Emojis in code, markup, or text
- Generic placeholder names ("John Doe", "Acme Corp")
- AI copywriting clichés ("Elevate", "Seamless", "Unleash")

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Minimalist UI source code | HTML/CSS/TSX (Tailwind CSS v4 `@theme` tokens) | Component source files | Responsive all breakpoints (mobile ≤768px), WCAG AA contrast (4.5:1 text, 3:1 large text), token-compliant warm monochrome palette, transform/opacity motion only |

## Typography

- **Sans:** SF Pro Display, Geist, Switzer
- **Serif (editorial only):** Lyon Text, Newsreader, Playfair Display — for hero headings and quotes
- **Mono (metadata):** Geist Mono, SF Mono, JetBrains Mono
- Text colors: off-black `#111111` for body, muted `#787774` for secondary
- Line-height: 1.6 for body, 1.1 for headings

## Color Palette

- Background: `#FFFFFF` or warm bone `#F7F6F3`
- Card surface: `#FFFFFF` or `#F9F9F8`
- Borders: `#EAEAEA` or `rgba(0,0,0,0.06)` — every card, divider, and border uses this
- Accents (muted pastels only):
  - Red: bg `#FDEBEC` / text `#9F2F2D`
  - Blue: bg `#E1F3FE` / text `#1F6C9F`
  - Green: bg `#EDF3EC` / text `#346538`
  - Yellow: bg `#FBF3DB` / text `#956400`

## Components

- Bento grids: asymmetric CSS Grid, `border: 1px solid #EAEAEA`, border-radius max `12px`, internal padding `24-40px`
- Buttons: solid `#111111` bg, white text, border-radius `4-6px`, no shadow, hover: `#333333`, active: `scale(0.98)`
- Tags: pill-shaped, `text-xs uppercase tracking-wide`, pastel background
- FAQ: no container boxes, `border-bottom` only
- Keystrokes: `<kbd>` with `border: 1px solid #EAEAEA`, mono font

## Motion

- Scroll entry: gentle fade-up (`translateY(12px)` + `opacity: 0` over 600ms, `cubic-bezier(0.16, 1, 0.3, 1)`)
- Hover: ultra-subtle shadow shift (`0 2px 8px rgba(0,0,0,0.04)`)
- Staggered reveals with `animation-delay: calc(var(--index) * 80ms)`
- Single slow-moving radial gradient blob (opacity 0.02-0.04) behind hero, fixed position
- Animate only `transform` and `opacity`
