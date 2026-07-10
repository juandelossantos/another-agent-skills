---
name: soft-premium-ui
description: Design polished, calm, premium UIs with soft contrast, generous whitespace, premium fonts, and spring motion. Do NOT use for industrial or brutalist aesthetics.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-shadcn
  style: premium-agency
---

# Soft Premium UI

## When to Use

Use when: user chooses premium agency / luxury / calm design direction.

Engineer $150k+ agency-level digital experiences. Haptic depth, cinematic spatial rhythm, obsessive micro-interactions.

## Banned Elements

- Fonts: Inter, Roboto, Arial, Open Sans, Helvetica (use Geist, Clash Display, PP Editorial New, Plus Jakarta Sans)
- Icons: Lucide, FontAwesome, Material (use Phosphor Light or Remix Line)
- Generic `1px solid` gray borders, harsh `shadow-md`
- Edge-to-edge sticky navbars, symmetrical 3-column Bootstrap grids
- `linear` or `ease-in-out` transitions

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Premium-styled visual layer | HTML/CSS — design tokens + motion definitions | Source files | Responsive ≤768px, WCAG AA focus + contrast, `prefers-reduced-motion`, spring-physics motion curve, backdrop-blur on fixed/sticky only, Double-Bezel card architecture, ≥44px touch targets, lazy-loaded below-fold media |

## Creative Variance Engine

Pick **one vibe** + **one layout** per project. Do not reuse the same combo on consecutive projects.

### Vibe Archetypes
1. **Ethereal Glass (SaaS/AI/Tech):** Deepest OLED black (`#050505`), radial mesh gradients, `backdrop-blur-2xl`, white/10 hairlines
2. **Editorial Luxury (Lifestyle/Agency):** Warm creams (`#FDFBF7`), muted sage, deep espresso, variable serif, CSS film-grain overlay
3. **Soft Structuralism (Consumer/Health/Portfolio):** Silver-grey or white, massive Grotesk typography, ultra-diffused ambient shadows

### Layout Archetypes
1. **Asymmetrical Bento:** Masonry CSS Grid with varying card sizes. Mobile: single-column stack.
2. **Z-Axis Cascade:** Elements slightly overlapping, subtle rotation (`-2deg` to `3deg`). Mobile: remove rotations and overlaps.
3. **Editorial Split:** Massive type left half, interactive scrollable content right half. Mobile: vertical stack.

## Double-Bezel (Doppelrand) Architecture

Every premium card uses **nested enclosures**:

- **Outer shell:** Subtle background (`bg-black/5`), hairline border (`ring-1 ring-black/5`), padding `p-1.5`, large radius (`rounded-[2rem]`)
- **Inner core:** Own background, inner highlight (`shadow-[inset_0_1px_1px_rgba(255,255,255,0.15)]`), smaller radius (`rounded-[calc(2rem-0.375rem)]`)

## Motion

- **Fluid Island Nav:** Floating glass pill (`mt-6 mx-auto w-max rounded-full`), hamburger morphs to X, staggered mask reveal on menu open
- **Magnetic buttons:** `active:scale-[0.98]`, nested icon translates diagonally on hover
- **Scroll interpolation:** `translate-y-16 blur-md opacity-0` resolving over 800ms+
- All motion: `cubic-bezier(0.32, 0.72, 0, 1)` — never `ease-in-out`
- Animate only `transform` and `opacity`

## Pre-Output Checklist

- [ ] No banned fonts, icons, borders, shadows, layouts, or motion
- [ ] Vibe and layout archetypes selected and applied
- [ ] All major cards use Double-Bezel nested architecture
- [ ] Section padding ≥ `py-24`
- [ ] All transitions use custom cubic-bezier
- [ ] Scroll entry animations present on all major blocks
- [ ] Mobile collapse below 768px
- [ ] `backdrop-blur` only on fixed/sticky elements
