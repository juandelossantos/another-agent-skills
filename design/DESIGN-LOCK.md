# DESIGN-LOCK.md

> Approved: 2026-05-28
> Locked by: user + agent consensus after 3 design preview iterations
> Design files: `design/approved/v3-refined.html`, `design/approved/v3-dark.png`, `design/approved/v3-light.png`

---

## Direction

| Attribute | Value |
|---|---|
| Aesthetic ID | `editorial-hacker` |
| Mood | Confident, mechanical, editorial, warm dark — not cold or sterile |
| Primary reference | open-design.ai (editorial layout, generous whitespace, magazine structure) |
| Secondary reference | industrial-brutalist (terminal accents, monospace labels, hazard red-orange) |

## Final Palette — Dark Theme

| Token | Value | Usage | Contrast |
|---|---|---|---|
| `--bg` | `#1A1A18` | Page background | — |
| `--bg-card` | `#222220` | Card, section backgrounds | — |
| `--bg-code` | `#1E1E1C` | Code block backgrounds | — |
| `--text` | `#E8E6E3` | Primary body text | 13.99:1 AAA |
| `--text-secondary` | `#A09E9A` | Secondary descriptions | 6.52:1 AA |
| `--text-muted` | `#7A7772` | Labels, captions | 3.91:1 AA-lg |
| `--accent` | `#DC5C20` | Interactive elements (burnt orange) | 4.64:1 AA |
| `--accent-dim` | `rgba(220, 92, 32, 0.12)` | Subtle accent backgrounds | — |
| `--border` | `#2C2A28` | Dividers, card borders | decorative |
| `--border-light` | `#3A3835` | Lighter borders | decorative |
| `--green` | `#3CCE1E` | Terminal success, copied state | 8.33:1 AAA |

## Final Palette — Light Theme

| Token | Value | Usage | Contrast |
|---|---|---|---|
| `--bg` | `#F2F0ED` | Page background (warm light gray) | — |
| `--bg-card` | `#F8F7F5` | Card backgrounds (warm near-white) | — |
| `--bg-code` | `#EEEDEA` | Code block backgrounds | — |
| `--text` | `#2A2826` | Primary body text | 12.91:1 AAA |
| `--text-secondary` | `#545250` | Secondary descriptions | 6.84:1 AA |
| `--text-muted` | `#6F6C68` | Labels, captions | 4.59:1 AA |
| `--accent` | `#B8450E` | Interactive elements (burnt orange) | 4.74:1 AA |
| `--accent-dim` | `rgba(184, 69, 14, 0.1)` | Subtle accent backgrounds | — |
| `--border` | `#D8D6D2` | Dividers, card borders | decorative |
| `--border-light` | `#C8C6C2` | Lighter borders | decorative |
| `--green` | `#167A32` | Terminal success, copied state | 4.78:1 AA |

## Final Typography

| Role | Font | Fallback | Usage |
|---|---|---|---|
| Display / Headlines | Newsreader (serif) | Georgia, Times New Roman, serif | H1, H2, section titles, pipeline letters |
| Body / UI | System UI | -apple-system, system-ui, sans-serif | Body text, navigation, buttons |
| Code / Labels | JetBrains Mono | SF Mono, monospace | Install commands, inline code, labels |

### Type Scale

| Token | Size | Weight | Line-Height | Usage |
|---|---|---|---|---|
| `display` | `clamp(3rem, 8vw, 5.5rem)` | 800 | 0.92 | Hero H1 |
| `heading-xl` | `2.5rem` | 700 | 1.05 | Section titles |
| `heading-lg` | `1.75rem` | 600 | 1.15 | Card titles |
| `body` | `1rem` | 400 | 1.7 | Description text |
| `body-small` | `0.875rem` | 400 | 1.6 | Secondary text |
| `caption` | `0.75rem` | 600 | 1.4 | Labels, badges, stats (minimum) |
| `code` | `0.8125rem` | — | 1.5 | Install blocks, code |

### Variable Font Settings

Newsreader is a variable font with `opsz` (optical size) axis 6–72:
- Display/headings: `font-variation-settings: 'opsz' 72`
- Body text (if using serif): `font-variation-settings: 'opsz' 6`

## Key Decisions

1. **Serif + Sans + Mono pairing** — Newsreader for editorial weight, System UI for fast body text, JetBrains Mono for code. No external font for body (zero load).
2. **Burnt orange accent** (`#DC5C20` dark / `#B8450E` light) — Replaces red hazard. Warmer, more mechanical, less "alarm".
3. **Warm dark bg** (`#1A1A18`) — Not pure black. Reduces eye strain vs `#000000` or `#0A0A0A`.
4. **Warm light bg** (`#F2F0ED`) — Not pure white. Cards are `#F8F7F5` (warm near-white). No pure blacks or whites in either theme.
5. **Minimum font size: 12px (0.75rem)** — No text below this. All labels, captions, and metadata meet this floor.
6. **Spacing system: 8px base unit** — All margins/paddings in multiples of 8 (8, 16, 24, 32, 48, 64).
7. **Borders are 1px, no border-radius** — Consistent with industrial-brutalist aesthetic.
8. **i18n: JS runtime swap via JSON** — No separate HTML per language. Spanish must account for ~25% text expansion.
9. **Pipeline visual: Editorial letters + arrows** — Not 9 equal circles. Serif letters with color-coded stages.
10. **No images** — Entirely CSS/HTML. No icon library. Minimal letter-in-pastel-bg for skill icons.

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

## Blocking Conditions for BUILD

These 4 issues MUST be resolved in implementation before the page is considered complete:

1. **`prefers-color-scheme` detection** — Inline `<script>` in `<head>` sets the correct `data-theme` before first paint to prevent FOUC.
2. **`::selection` styles** — Match accent color, not default blue.
3. **`:focus-visible` styles** — Outline ring using accent color for keyboard navigation.
4. **`font-variation-settings: 'opsz'`** — Explicit `opsz` 72 for display, 6 for body on Newsreader.

## Approved Artifacts

- `design/approved/v3-refined.html` — Final design preview with all approved tokens
- `design/approved/v3-dark.png` — Dark theme screenshot
- `design/approved/v3-light.png` — Light theme screenshot

## References

- open-design.ai — Editorial layout, magazine structure
- industrial-brutalist-ui skill — Terminal accents, monospace framing
- minimalist-ui skill — Warm palette foundations
