---
name: frontend-web
description: >
  Build production-grade web interfaces. Built on engineering-fundamentals.
  Triggers on: "website", "landing page", "web app", "Next.js", "React", "Vue".
license: MIT
compatibility: opencode
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-shadcn
  workflow: design-driven-build
  foundation: engineering-fundamentals
---

# Frontend Web

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
web-specific implementation.

## When to Use

Build, design, or redesign any **web interface**.

Do NOT use for:
- Backend-only, CLI, non-visual software
- Native mobile (use `frontend-mobile`)
- Installable offline apps (use `frontend-pwa`)

### Context Persistence Check

Before starting work:
1. Check `design/DESIGN-LOCK.md`:
   - Exists and < 7 days → Read it. Extract direction, palette, typography, key decisions.
   - > 7 days → Read it, ask: "Still valid?"
   - Missing → Proceed with Phase 1.
2. Check `SPEC.md`:
   - Exists → Read it. Respect locked stack and boundaries.
   - Missing → If non-trivial, invoke `spec-driven-development`.
3. If context exists → Resume from detected phase. Do NOT re-run discovery unless user requests changes.

### Stack Detection

Check for `STACK_CONFIG.md`:
- **Exists** → Adapt examples to chosen stack.
- **Missing** → Default to React 19 + Next.js 16 + Tailwind v4.

**Adaptation examples:**
- React → Vue: `.vue` files, `ref()` instead of `useState`
- React → Svelte: `.svelte` files, `svelte/motion` instead of Framer Motion
- React → Angular: `.component.ts` with decorators

---

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

---

### Phase 0b — Brief Inference (MANDATORY before code)

**Read 6 signals before any code:** page kind, vibe words, reference URLs, audience, existing brand assets, quiet constraints (a11y-first, regulated, trust-first).

**Output a one-line "Design Read":** `"Reading this as: <page kind> for <audience>, <vibe>, leaning toward <system>."`

**Anti-Default Discipline:** Do not default to AI-purple gradients, centered hero over dark mesh, three equal feature cards, or Inter + slate-900.

See `DESIGN-GUIDE.md` for vibe → dial mapping tables and signal extraction details.

---

### Phase 1 — Discovery Gate
→ See `engineering-fundamentals` Phase 1 for universal discovery.

**Web-specific questions:**
1. **Pages**: How many pages/sections?
2. **SEO**: Public-facing and indexable?
3. **Animations**: Scroll effects, entrance animations, micro-interactions?

Read `DISCOVERY-GUIDE.md` for complete web checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**Web-specific additions:**
- SPEC.md must include: Tech stack (locked versions), Project structure, SEO requirements if public.

---

### Phase 3 — Three Dials System

Replace 8 fixed aesthetic directions with **3 parametric dials** set after Design Read (Phase 0b):

- **`DESIGN_VARIANCE: 7`** — 1 = Perfect Symmetry, 10 = Artsy Chaos
- **`MOTION_INTENSITY: 5`** — 1 = Static, 10 = Cinematic / Physics
- **`VISUAL_DENSITY: 4`** — 1 = Art Gallery / Airy, 10 = Cockpit / Packed Data

| Use case | VAR | MOT | DEN |
|---|---|---|---|
| SaaS landing | 7 | 5 | 4 |
| Agency portfolio | 8 | 7 | 3 |
| Premium consumer | 7 | 5 | 3 |
| Editorial / Blog | 6 | 3 | 3 |
| Public-sector service | 3 | 2 | 5 |

See `DESIGN-GUIDE.md` for vibe→dial inference, technical dial definitions, and mobile collapse rules.

---

### Phase 3b — Design System Map

| Brief reads as… | Use |
|---|---|
| Enterprise / Microsoft-adjacent | `@fluentui/react-components` |
| Material-flavored | `@material/web` + M3 tokens |
| IBM-style B2B | `@carbon/react` |
| Shopify surfaces | Polaris React |
| Atlassian product | `@atlaskit/*` |
| GitHub-style devtool | `@primer/react-brand` |
| Public-sector (UK/US) | `govuk-frontend` / `uswds` |
| Modern accessible React | `@radix-ui/themes` |
| Modern SaaS | shadcn/ui |
| Tailwind indie build | Tailwind v4 + `dark:` |

**Rules:** One system per project. Use official packages — do not recreate CSS by hand. For aesthetics without packages (glassmorphism, bento, brutalism, editorial, dark tech), build with native CSS + Tailwind.

---

### Phase 4 — Stack Lock-in

| Tool | Minimum | Notes |
|---|---|---|
| Node.js | 20.9+ | |
| Next.js | 16.1.1+ | App Router, async params, RSC by default |
| React | 19.2+ | |
| TypeScript | 5.7+ | |
| Tailwind CSS | v4 | `@theme` in CSS, not `tailwind.config.ts` |
| shadcn CLI | latest | Registry-based, copy-not-install |
| Framer Motion | 12+ | Primary animation engine |
| lucide-react | latest | Default icons |

Optional: `lenis`, `split-type`, `gsap` + `@gsap/react` (pinned sections only).

Forbidden: GSAP by default, `tailwind.config.ts`, `middleware.ts`, Spline.

---

### Phase 5 — Anti-Slop Rules (Web)

→ See `engineering-fundamentals` Phase 4 for universal principles.

**Typography**
- BANNED as display: Inter, Roboto, Arial, Space Grotesk, Geist.
- BANNED as serif defaults: Fraunces, Instrument Serif. Serif is very discouraged as default.
- **Em-dash ban:** `—` banned in all visible text. Use comma, colon, or sentence break.
- Preferred sans: Geist, Outfit, Satoshi. Pairings: Geist+GeistMono, Satoshi+JetBrainsMono.

**Color**
- **THE LILA RULE:** No AI-purple/blue glow default. Neutral bases (Zinc/Slate/Stone) + singular saturated accent.
- **PREMIUM-CONSUMER PALETTE BAN:** Beige+brass+espresso (`#f5f1ea`, `#b08947`…) banned as default. Rotate: Cold Luxury, Forest, Black+Tan, Cobalt+Cream, Terracotta+Slate.
- Max 1 accent (< 80% sat). One palette per project. No warm/cool gray mixing.

**Layout & Content**
- **Eyebrow restraint:** Max 1 per 3 sections. Count mechanically before shipping.
- **Zigzag cap:** Max 2 consecutive text+image splits. Break pattern with full-width or bento.
- **Section-layout ban:** 8 sections → ≥4 different layout families.
- **Hero:** Fits viewport, ≤2 headline lines, ≤20 subtext words, top padding max `pt-24`. No trust strip inside hero.
- **No duplicate CTA intent.** No wrapped CTAs at desktop. **Copy self-audit** before shipping.

**Images & Assets**
- See `IMAGE-STRATEGY.md` for image generation pipeline, social proof rules, and photography guidelines.
- **No div-based fake screenshots** — BANNED.
- Use `next/image` with `priority` on above-the-fold images.

See `ANTI-SLOP-GUIDE.md` for 85+ AI tells catalogue, content density rules, spec-sheet alternatives, and full copy protocol.

---

### Phase 6 — Animation System

Read `ANIMATION-GUIDE.md`.

**Summary:**
- **Primary:** Framer Motion `Reveal` component.
- **Fallback:** CSS `animation-timeline` for scroll effects, WAAPI for precise JS animations.
- **Accessibility:** Every animation MUST respect `prefers-reduced-motion`.
- **Performance:** Only `transform` and `opacity` may be animated.

---

### Phase 7 — Build with Tokens

**BEFORE WRITING CODE:**

1. **Read `design/DESIGN-LOCK.md`** — Verify approved direction, palette, typography.
2. **Check `design/approved/`** — Screenshots, previews, moodboards.
3. **Cross-check with `DESIGN.md`** — Tokens in code must match locked system.

**Then build:**

4. Apply tokens from `DESIGN.md` to `src/app/globals.css`.
5. Use `next/font/google` for fonts in `layout.tsx`.
6. Build sections in canonical order: Nav → Hero → Value Prop → Services → About → Testimonials → CTA → Footer.
7. Use `whileInView` for entrance animations.
8. Use `<Image>` with descriptive `alt` text.
9. `"use client"` only when hooks, events, or state present.

---

### Phase 8 — QA Gates

→ See `engineering-fundamentals` Phase 5 for universal gates.

**Run `PRE-FLIGHT.md` before declaring done.** Every box must pass — this is a mechanical gate, not optional.

**Quick checks:** Run `PRE-FLIGHT.md` (covers TypeScript, build, template residue, hardcoded colors, responsive, a11y, images, reduced motion, animation, design lock).

**Log metrics:**
```
LOG METRIC: gate - project: [detect] - gate_name: frontend-web-qa - result: pass/fail
LOG METRIC: build - project: [detect] - result: pass/fail - warnings: [count]
```

---

## Examples & Troubleshooting

Read `EXAMPLES.md`:
- Landing page walkthrough (15 steps)
- Adding animation to existing component
- Troubleshooting (Next.js 16 params, fonts, FOUC, hydration, build)


