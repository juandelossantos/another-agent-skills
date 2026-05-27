# Pre-Flight Core — Universal Pre-Output Checks

**MANDATORY GATE.** Run every box. If ANY box is unchecked, output is not finished.

Platform-specific PRE-FLIGHT.md adds build commands, platform-specific layout checks, and native integration checks.

---

## Design Intent

- [ ] Brief inference (Phase 0b) was executed before any code
- [ ] One-line "Design Read" was declared
- [ ] Three dials (VARIANCE / MOTION / DENSITY) were set based on the Design Read
- [ ] Redesign mode detected: greenfield, preserve, or overhaul

---

## Color

- [ ] No AI-purple/blue glow default (THE LILA RULE)
- [ ] Premium-consumer palette is not beige+brass+espresso
- [ ] Different palette from previous project, if applicable
- [ ] Max 1 accent color, saturation < 80%
- [ ] One accent for the whole page — no warm/cool mixing
- [ ] No pure `#000000` or pure `#ffffff`
- [ ] All colors from DESIGN.md tokens, no hardcoded generics

---

## Content

- [ ] Copy self-audit: every visible string re-read
- [ ] No grammatically broken text, unclear referents, or hallucinated copy
- [ ] One copy register per page
- [ ] Fake-precise numbers flagged (invented `92%`, `4.1×`, `5.8 mm`)
- [ ] No AI copy clichés ("Elevate", "Seamless", "Unleash", "Next-Gen")
- [ ] No placeholder names ("John Doe", "Acme Corp") without context
- [ ] Quotes ≤ 3 lines, with proper attribution

---

## Motion

- [ ] Every animation is motivated (articulate the reason in one sentence)
- [ ] Motion claimed (dial value) = motion shown in the output
- [ ] No `window.addEventListener('scroll')` — use platform scroll APIs
- [ ] Only `transform` and `opacity` animated (never `top`, `left`, `width`, `height`)
- [ ] `prefers-reduced-motion` or platform equivalent honored (static fallback for all animations)
- [ ] No `linear` or `ease-in-out` — use spring physics or custom easing

---

## AI Tells

- [ ] No neon / outer glows
- [ ] No pure `#000000` or pure `#ffffff`
- [ ] No div-based fake screenshots
- [ ] No fake version footers
- [ ] No section-number eyebrows on non-sequential content
- [ ] No middle-dot overuse as separators
- [ ] No `<br>`-broken headlines
- [ ] No vertical rotated text on section edges
- [ ] No crosshair grid lines overlay
- [ ] No scroll cues ("scroll down", arrow indicators)

---

## Technical

- [ ] Dark mode implemented (both system + manual toggle)
- [ ] Page theme lock: ONE theme per page (no random section inversions)
- [ ] One design system used (not mixed)
- [ ] Dependencies verified in `package.json` (or equivalent) before importing
- [ ] Mobile/responsive tested at minimum supported viewport
- [ ] All effects have cleanup functions where applicable
- [ ] Accessibility: contrast 4.5:1, focus indicators, reduced motion
- [ ] Every image has descriptive `alt` text (or platform equivalent)
