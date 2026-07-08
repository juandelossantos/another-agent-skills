---
name: frontend-web
description: "Build production-grade web interfaces. Triggers: website, landing page, web app, Next.js, React, Vue. Do NOT use for mobile native apps."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
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

Before any design decision, state the contract:

1. **Subject** — One concrete thing this page is about. Not "a productivity app" but "a Gantt chart for solo freelancers."
2. **Audience** — Who reads it. Not "users" but "freelancers checking deadlines on mobile."
3. **Single job** — What this page must accomplish. Not "look professional" but "prove this saves 2 hrs/week."

Write this as a one-line Design Read (`"Reading this as: <page kind> for <audience>, <vibe>"`) and keep it visible during all phases. Every layout, color, and type decision that follows must trace back to this contract.

See `engineering-fundamentals/guides/DESIGN-CORE.md` for the full Brief Inference protocol and Design Principles.

Then see `guides/DESIGN-GUIDE.md` for web-specific vibe → dial mapping.

---

### Phase 1 — Discovery Gate
→ See `engineering-fundamentals` Phase 1 for universal discovery.

**Web-specific questions:**
1. **Pages**: How many pages/sections?
2. **SEO**: Public-facing and indexable?
3. **Animations**: Scroll effects, entrance animations, micro-interactions?

Read `guides/DISCOVERY-GUIDE.md` for complete web checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**Web-specific additions:**
- SPEC.md must include: Tech stack (locked versions), Project structure, SEO requirements if public.

---

### Phase 3 — Three Dials System

→ See `engineering-fundamentals/guides/DESIGN-CORE.md` for the universal Three Dials System (VARIANCE, MOTION, DENSITY), vibe→dial inference, use case presets, color principles, and dark mode protocol.

Then see `guides/DESIGN-GUIDE.md` for web-specific font selection, token application, and banned lists.

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

### Phase 3c — Design Plan Review (MANDATORY before code)

Before writing any code, synthesize the design direction into a compact token system and critique it against the brief:

1. **Extract tokens:** Color palette (4-6 hex values), typeface pairings (display + body + utility), layout concept (1-2 sentence description), signature element (the one memorable thing)
2. **Review against the brief:** Does each token trace back to Subject, Audience, or Single Job? If a choice reads like the same default you'd produce for any project — revise it.
3. **One bold choice:** Identify one real aesthetic risk you can justify. Spend boldness in one place; keep everything else quiet and disciplined.

If any part of the plan reads generic, revise before writing code. Only after the plan passes its own critique should you proceed to build.

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

→ See `engineering-fundamentals/guides/ANTI-SLOP-CORE.md` for universal AI tells, content density rules, copy protocol, and UI state requirements.

Then see `guides/ANTI-SLOP-GUIDE.md` for web-specific layout tells (three feature cards, hero patterns, bento grids), font bans, and interactive patterns.

**Web-specific additions:**

**Typography**
- BANNED as display: Inter, Roboto, Arial, Space Grotesk, Geist.
- BANNED as serif defaults: Fraunces, Instrument Serif.
- Preferred sans: Geist, Outfit, Satoshi. Pairings: Geist+GeistMono, Satoshi+JetBrainsMono.

**Layout**
- **Zigzag cap:** Max 2 consecutive text+image splits.
- **Section-layout ban:** 8 sections → ≥4 different layout families.
- **Hero:** Fits viewport, ≤2 headline lines, ≤20 subtext words, top padding max `pt-24`.

**Images & Assets**
- See `guides/IMAGE-STRATEGY.md` for image generation pipeline, social proof rules, and photography guidelines.
- **No div-based fake screenshots** — BANNED.
- Use `next/image` with `priority` on above-the-fold images.

---

### Phase 6 — Animation System

Read `guides/ANIMATION-GUIDE.md`.

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

→ See `engineering-fundamentals` Phase 5 for universal gates. Read `engineering-fundamentals/guides/PRE-FLIGHT-CORE.md` for universal checks first.

**Then run `guides/PRE-FLIGHT.md` before declaring done.** Every box must pass — this is a mechanical gate, not optional.

**Log metrics:**
```
LOG METRIC: gate - project: [detect] - gate_name: frontend-web-qa - result: pass/fail
LOG METRIC: build - project: [detect] - result: pass/fail - warnings: [count]
```

---

## Examples & Troubleshooting

Read `guides/EXAMPLES.md`:
- Landing page walkthrough (15 steps)
- Adding animation to existing component
- Troubleshooting (Next.js 16 params, fonts, FOUC, hydration, build)


