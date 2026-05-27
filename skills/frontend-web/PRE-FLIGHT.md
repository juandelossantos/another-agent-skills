# Frontend Web — Pre-Flight Check

**MANDATORY GATE.** Run every box before declaring done. If ANY box is unchecked, output is not finished.

Run `engineering-fundamentals/guides/PRE-FLIGHT-CORE.md` first for universal checks. This document adds web-specific layout, hero, component, and build checks.

---

## Design Intent

- [ ] Brief inference (Phase 0b) was executed before any code
- [ ] One-line "Design Read" was declared
- [ ] Three dials (VARIANCE / MOTION / DENSITY) were set based on the Design Read
- [ ] Design System Map (Phase 3b) was consulted and a system was chosen (or deliberately skipped)
- [ ] Redesign mode detected: greenfield, preserve, or overhaul

---

## Typography

- [ ] No Inter as display font (unless public-sector / a11y-first brief)
- [ ] No Fraunces or Instrument Serif
- [ ] Serif usage is justified (brief names a serif, or genuine editorial/luxury)
- [ ] Zero em-dashes in visible text (grep for `—`)
- [ ] Italic descender clearance checked for display type (look for `y`, `g`, `j`, `p`, `q`)
- [ ] Font pairings are documented and applied consistently
- [ ] Fonts loaded via `next/font` or self-hosted (`font-display: swap`), never `<link>`
- [ ] If serif used, it's different from previous project's serif

---

## Color

- [ ] No AI-purple/blue glow default (THE LILA RULE)
- [ ] Premium-consumer palette is not beige+brass+espresso (check hex families)
- [ ] Different premium-consumer palette from previous project, if applicable
- [ ] Max 1 accent color, saturation < 80%
- [ ] Color consistency lock: one accent for the whole page
- [ ] No warm-grey + cool-grey mixing in the same project
- [ ] No pure `#000000` or `#ffffff`
- [ ] All colors from DESIGN.md tokens, no Tailwind generics

---

## Hero

- [ ] Fits in initial viewport without scroll
- [ ] Headline ≤ 2 lines at desktop
- [ ] Subtext ≤ 20 words AND ≤ 4 lines
- [ ] CTAs visible without scroll
- [ ] Top padding ≤ `pt-24` at desktop
- [ ] Max 4 text elements (eyebrow + headline + subtext + CTAs)
- [ ] No trust strip, taglines below CTAs, avatar rows, feature bullets inside hero
- [ ] Hero has a real visual asset (not just text + gradient)
- [ ] Font scale is reasonable (`text-4xl`-`text-6xl`, not `text-8xl` for long headlines)

---

## Layout

- [ ] Eyebrow count ≤ ceil(sectionCount / 3)
- [ ] Split-header pattern ("big headline left + small text right") is not used by default
- [ ] Zigzag (text+image split) appears ≤ 2 consecutive sections
- [ ] Section-layout families: ≥ 4 different families for 8 sections
- [ ] Bento cell count = exact content count (no empty cells)
- [ ] Bento background diversity: at least 2-3 cells have visual variation (images, gradients, patterns)
- [ ] Mobile collapse defined per section (tested at < 768px)
- [ ] No `h-screen` — all full-height sections use `min-h-[100dvh]`
- [ ] CSS Grid used over flexbox percentage math (`calc(33%-1rem)`)
- [ ] Navigation renders on one line at desktop
- [ ] Navigation height ≤ 80px at desktop (default 64-72px)
- [ ] Shape consistency lock: one corner-radius scale for the page

---

## Components

- [ ] Button contrast: WCAG AA minimum (4.5:1 body, 3:1 large text)
- [ ] CTA wrap check: all button labels fit on one line at desktop
- [ ] No duplicate CTA intent: same intent = same label across the page
- [ ] Logo wall = logos only. No industry labels below logos
- [ ] Form inputs: label above, helper text optional, error text below
- [ ] No placeholder-as-label
- [ ] Form contrast: inputs, placeholders, focus rings, errors all WCAG AA
- [ ] Interactive states provided: loading (skeleton), empty, error
- [ ] Tactile feedback on `:active` (`scale-[0.98]` or equivalent)

---

## Content

- [ ] Copy self-audit: every visible string re-read
- [ ] No grammatically broken text, unclear referents, or hallucinated copy
- [ ] One copy register per page (no mixing technical + editorial + marketing unless brand demands it)
- [ ] Fake-precise numbers flagged (invented `92%`, `4.1×`, `5.8 mm`)
- [ ] Quotes ≤ 3 lines, with proper attribution
- [ ] No AI copy clichés ("Elevate", "Seamless", "Unleash", "Next-Gen")
- [ ] No placeholder names ("John Doe", "Acme Corp") without context

---

## Motion

- [ ] Every animation is motivated (articulate the reason in one sentence)
- [ ] Motion claimed (dial value) = motion shown in the output
- [ ] Marquee appears ≤ 1 time per page
- [ ] No `window.addEventListener('scroll')` — use Motion `useScroll()`, GSAP ScrollTrigger, or CSS scroll-driven
- [ ] No custom scroll progress calculations in React state
- [ ] No `requestAnimationFrame` loops touching React state
- [ ] Only `transform` and `opacity` animated (never `top`, `left`, `width`, `height`)
- [ ] `prefers-reduced-motion` honored (static fallback for all animations)
- [ ] GSAP skeletons (StickyStack, HorizontalPan) use correct `start: "top top"` and `pin: true` if used
- [ ] Spring physics (`type: "spring"`, custom cubic-bezier) — no `linear` or `ease-in-out` default

---

## AI Tells (Visual)

- [ ] No neon / outer glows
- [ ] No pure `#000000` or pure `#ffffff`
- [ ] No div-based fake screenshots
- [ ] No "Version" labels or version footers
- [ ] No section-number eyebrows on non-sequential content
- [ ] No middle-dot overuse as separators
- [ ] No `<br>`-broken headlines
- [ ] No vertical rotated text on section edges
- [ ] No crosshair grid lines overlay
- [ ] No scroll cues ("scroll down", arrow indicators)
- [ ] No pills overlaid on images
- [ ] No photo-credit captions as decorative elements
- [ ] No decorative status dots
- [ ] No locale/weather strips
- [ ] No custom mouse cursors
- [ ] No fake "scoring" or progress bars

---

## Technical

- [ ] Dark mode tokens implemented (both `prefers-color-scheme` and/or manual toggle)
- [ ] Page theme lock: ONE theme per page (no random section inversions)
- [ ] Mobile tested at 375px viewport
- [ ] All `useEffect` have cleanup functions where needed
- [ ] Icons from allowed libraries (Phosphor, Radix, Tabler, Hugeicons) — one family per project
- [ ] One design system used (not mixed)
- [ ] Dependencies verified in `package.json` before importing
- [ ] Core Web Vitals: LCP < 2.5s, INP < 200ms, CLS < 0.1
- [ ] Lighthouse run before declaring done
