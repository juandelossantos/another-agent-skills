# Critique — AI Slop Anti-Patterns

## Detection Catalog

25 concrete anti-patterns. When 3+ are present, the interface reads as AI-generated.

### Typography

| # | Anti-pattern | Detection | Fix |
|---|---|---|---|
| 1 | **Inter/Roboto as display** | Body font used for headlines. No distinctive display type. | Swap to Geist, Satoshi, Cabinet Grotesk. See frontend-web DESIGN-GUIDE. |
| 2 | **Fraunces/Instrument Serif as default serif** | The AI-default serif pairings. | Use PP Editorial New, GT Sectra, Reckless Neue, or Tiempos Headline. |
| 3 | **14px body text** | Body copy below 16px on desktop. | Bump to 16px minimum. Adjust leading to 1.5-1.6. |
| 4 | **No type scale** | Random font-size values without a coherent scale. | Build modular scale (1.25 or 1.333 ratio). Fix to rem units. |
| 5 | **Widows and orphans** | Single word on last line of paragraph or heading. | Add `text-wrap: balance` or `padding-right` to container. |

### Color

| # | Anti-pattern | Detection | Fix |
|---|---|---|---|
| 6 | **AI purple/blue glow** | Purple gradients behind hero, neon purple buttons, blue glow on CTAs. | Use neutral base (Zinc, Slate, Stone) + single saturated accent. See DESIGN-CORE.md Lila Rule. |
| 7 | **Beige+brass+espresso palette** | The AI-default premium palette. Hex: `#f5f1ea`, `#b08947`, etc. | Rotate to Cold Luxury, Forest, Cobalt+Cream, or Terracotta+Slate. See DESIGN-CORE.md. |
| 8 | **Gradient text** | Text with `background-clip: text` gradient as primary style. | Use solid color text with gradient only for decorative display (1 element max). |
| 9 | **Unbalanced saturation** | One element at 90%+ saturation while everything else is muted. | Cap accent saturation at 80%. Desaturate or rebalance. |
| 10 | **Pure #000000 / #ffffff** | True black or white used as text or background. | Replace with off-black/off-white from DESIGN.md tokens. |

### Layout

| # | Anti-pattern | Detection | Fix |
|---|---|---|---|
| 11 | **Three equal feature cards** | Row of 3 identically sized cards with icon, title, description. | Vary sizes. Use 2+1 layout, stacked, or staggered cards. |
| 12 | **Centered hero + dark mesh** | Full-viewport hero with radial gradient, centered headline, single CTA. | Offset headline. Add asymmetry. Vary hero section per page. |
| 13 | **Zigzag pattern >2** | More than 2 consecutive text+image alternating rows. | Cap at 2. Use gallery, full-width, or offset layouts. |
| 14 | **Nested cards** | Cards inside cards inside cards. | Flatten to one level of card depth. |
| 15 | **Side-tab borders** | Left border or tab decoration on sidebar navigation items. | Use background color, not left border, for active state. |

### Content

| # | Anti-pattern | Detection | Fix |
|---|---|---|---|
| 16 | **"Unlock your potential" copy** | Generic motivational SaaS copy. | Write specific, user-centered copy. See `clarify` skill. |
| 17 | **Every section has eyebrow** | Small uppercase label above every section heading. | Remove eyebrows. Use headings directly. Max 1-2 eyebrows per page. |
| 18 | **Stacked avatar circles** | Row of overlapping circular avatars with "+N more". | Use text list, single avatar, or non-overlapping grid. |
| 19 | **Tooltip restates label** | Tooltip that says "Click to submit" on a "Submit" button. | Remove tooltip or add genuinely new information. |
| 20 | **"Lorem ipsum" or placeholder text** | Filler text in shipped interfaces. | Replace with real copy or remove the element. |

### Interaction

| # | Anti-pattern | Detection | Fix |
|---|---|---|---|
| 21 | **Hover-only interactions** | Actions only available on hover. Invisible on touch devices. | Move to always-visible. Use `@media (hover: hover)` for conditional. |
| 22 | **No focus indicators** | Custom interactive elements without visible focus ring. | Add `:focus-visible` styles with 2px offset ring. |
| 23 | **No loading states** | Content appears instantly or not at all. No skeleton/placeholder. | Add skeleton for async content, spinner for actions >1s. |
| 24 | **No empty states** | "No items" shows blank page or error. | Design each empty state with illustration, explanation, and next action. |
| 25 | **Missing error states** | API failure shows nothing or generic error. | Design error state: what happened, whose fault, next step. |

## Verdict Rules

| Anti-patterns found | Verdict |
|---|---|
| 0-2 | PASS — Looks intentional |
| 3-5 | BORDERLINE — Review flagged items |
| 6+ | FAIL — Needs significant rework |

**Always list which anti-patterns were found.** Never just a PASS/FAIL without evidence.
