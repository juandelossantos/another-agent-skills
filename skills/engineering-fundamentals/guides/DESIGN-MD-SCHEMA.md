# DESIGN.md Schema — Universal 17-Section Contract

**Shared by all platform skills.** Defines what a complete DESIGN.md must contain.
Platform skills fill sections 13-17 via their DESIGN-GUIDE.md.
Direction skills (brutalist, minimalist, premium) fill sections 1-12.

Design gates (`design-gate.sh`) validate against this schema.

---

## Schema Overview

| Group | Sections | Filled By | Gate Behavior |
|---|---|---|---|
| **Visual Identity (1-12)** | Principles, Dials, Typography, Color, Spacing, Grid, Motion, Components, Layout, Anti-Patterns, Accessibility, Artifacts | Direction skills + agent | **Block** if missing required fields |
| **Implementation (13-17)** | CSS Architecture, Theme, Framework, Responsiveness, Assets | Platform DESIGN-GUIDE.md | **Warn** if missing (informational, platform-specific) |

---

## Section 1: Design Principles (Universal)

3-5 principles naming what guides design decisions.

| Field | Required | Validation |
|---|---|---|
| Principles | 3-5 items | Block if <3 or >5 |
| Each principle | One sentence, specific | Flag if generic ("keep it simple" without context) |

**Direction skill input:** All three provide principles matching their aesthetic.

---

## Section 2: Three Dials (Universal)

| Field | Required | Validation |
|---|---|---|
| DESIGN_VARIANCE | 1-10 | Block if outside range |
| MOTION_INTENSITY | 1-10 | Block if outside range |
| VISUAL_DENSITY | 1-10 | Block if outside range |
| Justification | One sentence per dial | Flag if missing |

---

## Section 3: Typography (Universal)

| Field | Required | Validation |
|---|---|---|
| Display face | Font name + fallback | Block if missing |
| Body face | Font name + fallback | Block if missing |
| Mono face (or N/A) | Font name or "no mono" | Block if missing |
| Type scale | Min 5 sizes with px/rem/clamp | Block if <5 |
| Font-loading strategy | Method (next/font, Google Fonts, self-host, system) | Block if missing |

**Checkable:** Every field is verifiable against the actual CSS.

---

## Section 4: Color Palette (Universal)

| Field | Required | Validation |
|---|---|---|
| Dark theme tokens | Min 5 (bg, text, accent, border, surface) | Block if <5 |
| Light theme tokens | Min 5 (same structure) | Block if <5 |
| Contrast ratio per text token | AA (4.5:1) or AAA (7:1) | Block if missing or below AA |
| Each token | Hex value + usage description | Block if missing usage |

**Direction skill input:** Each direction fills with its palette. Brutalist: hazard red. Minimalist: warm monochrome. Premium: deep blacks + creams.

---

## Section 5: Spacing Scale (Universal)

| Field | Required | Validation |
|---|---|---|
| Baseline unit | 4px or 8px | Block if missing |
| Spacing tokens | Min 5 values (xs, sm, md, lg, xl, 2xl, 3xl) | Block if <5 |
| Each value | px or rem | Flag if mixed units |

---

## Section 6: Grid System (Universal)

| Field | Required | Validation |
|---|---|---|
| Max-width or column count | Value | Block if missing |
| Breakpoints | Min 2 (mobile + desktop) | Block if <2 |
| Each breakpoint | px or rem value | Flag if missing context |

---

## Section 7: Motion (Universal — Mixed Checkable/Felt)

| Field | Required | Validation |
|---|---|---|
| Fast/base/slow durations | 3 values with units | Block if <3 |
| Easing curve | Named or cubic-bezier | Block if missing |
| Reduced-motion strategy | prefers-reduced-motion + CSS fallback | Block if missing |
| Animation quality | — | Flag for human review |

---

## Section 8: Component Specs (Universal)

| Field | Required | Validation |
|---|---|---|
| Components | Min 3 documented | Block if <3 |
| Per component states | Min: default + hover + active + disabled + focus | Block if <3 states per component |
| Per component dimensions | Padding, radius, gap | Flag if missing |

---

## Section 9: Layout Patterns (Universal — Felt)

| Field | Required | Validation |
|---|---|---|
| Section order | List of sections in order | Block if missing |
| Layout types | Per section: type (grid, flex, stacked) | Flag for review |

---

## Section 10: Anti-Pattern Bans (Universal)

| Field | Required | Validation |
|---|---|---|
| Bans | Min 5 explicit bans | Block if <5 |
| Each ban | Specific, actionable ("no border-radius above 8px" not "be consistent") | Block if generic |

**Direction skill input:** Each direction provides its own bans. Brutalist: zero radius. Minimalist: no shadows. Premium: no Inter.

---

## Section 11: Accessibility Baseline (Universal)

| Field | Required | Validation |
|---|---|---|
| Contrast target | AA (4.5:1) or AAA (7:1) | Block if missing |
| Focus indicator | Style + width | Block if missing |
| Touch target size | px/dp value or N/A | Block if missing |
| Reduced motion | Present/required | Block if missing |

---

## Section 12: Approved Artifacts (Universal)

| Field | Required | Validation |
|---|---|---|
| References | Min 1 path to `design/approved/` | Block if file doesn't exist on disk |
| Each reference | Must be a real file | Block if path doesn't resolve |

---

## Section 13: CSS Architecture (Platform-Specific)

| Field | Filled By | Content |
|---|---|---|
| Token strategy | Platform DESIGN-GUIDE.md | CSS custom properties, StyleSheet.create, or Tauri config |
| Implementation | Platform DESIGN-GUIDE.md | How tokens are applied to components |

---

## Section 14: Theme Implementation (Platform-Specific)

| Field | Filled By | Content |
|---|---|---|
| Toggle mechanism | Platform DESIGN-GUIDE.md | data-theme attribute, Appearance API, system preference listener |
| Dark mode approach | Platform DESIGN-GUIDE.md | CSS variables, ThemeProvider, native appearance |

---

## Section 15: Component Framework (Platform-Specific)

| Field | Filled By | Content |
|---|---|---|
| Framework/library | Platform DESIGN-GUIDE.md | React/shacdn, SwiftUI, Jetpack Compose, Tauri Webview |
| Animation engine | Platform DESIGN-GUIDE.md | Framer Motion, Reanimated, platform-native |

---

## Section 16: Platform Responsiveness (Platform-Specific)

| Field | Filled By | Content |
|---|---|---|
| Breakpoints/device sizes | Platform DESIGN-GUIDE.md | Tailwind breakpoints, iPhone/Android sizes, window sizes |
| Orientation handling | Platform DESIGN-GUIDE.md | Portrait/landscape, foldable, tablet |

---

## Section 17: Asset Pipeline (Platform-Specific)

| Field | Filled By | Content |
|---|---|---|
| Font loading | Platform DESIGN-GUIDE.md | next/font, expo-font, system fonts, bundled |
| Image strategy | Platform DESIGN-GUIDE.md | next/Image, expo-image, native assets |
| Icon approach | Platform DESIGN-GUIDE.md | Lucide, Phosphor, SF Symbols, system icons |

---

## Direction Skill → Section Mapping

| Skill | Fills Sections | Key Constraints |
|---|---|---|
| `industrial-brutalist-ui` | 1-12 | Zero border-radius, macro type, Swiss grid, hazard red accent, ASCII elements, scanlines/noise |
| `minimalist-ui` | 1-12 | Warm monochrome, bento grids, muted pastels, 8px base, ultra-subtle shadows |
| `soft-premium-ui` | 1-12 | Double-Bezel cards, spring motion, glass surfaces, premium fonts, py-24 sections |

---

## Platform Skill → Section Mapping

| Skill | Fills Sections | Key Content |
|---|---|---|
| `frontend-web` | 13-17 | CSS custom properties, data-theme toggle, React/Framer Motion, Tailwind breakpoints, next/font |
| `frontend-mobile` | 13-17 | StyleSheet tokens, Appearance API, React Native/Reanimated, device sizes, expo-font |
| `frontend-desktop` | 13-17 | Tauri config, OS theme listener, frontend framework, window breakpoints, bundled assets |
| `frontend-pwa` | 13-17 | CSS vars + SW cache, data-theme + system preference, Capacitor/Next.js, device matrix, offline-first assets |
