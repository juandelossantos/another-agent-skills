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

### Phase 3 — Aesthetic Direction
→ See `engineering-fundamentals` Phase 3.

Same 8 directions (ED, SM, LDW, CB, UE, NB, PG, RT). Pick ONE.

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

**Web-specific rules:**

**Typography**
- No Inter, Roboto, Arial, Space Grotesk, Geist as display fonts.
- Pair distinctive display + refined body font.
- Use `next/font/google` with `--font-display`, `--font-body`.

**Color**
- No Tailwind generics (`bg-blue-500`, `text-gray-700`).
- Use CSS custom properties from DESIGN.md or `globals.css` tokens.
- Dominant color + sharp accents. No timid palettes.

**Layout**
- No generic centered card grids as default.
- Consider asymmetry, overlap, diagonal flow, controlled density.
- Mobile-first: verify 375px before 1280px.

**Motion**
- No animation of `width`, `height`, `top`, `left`, `margin`, `padding`.
- Only `transform` and `opacity` for 60fps.
- Use `will-change` sparingly, remove after animation.

**Backgrounds**
- No flat solid colors as default.
- Consider: gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, grain overlays.

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
6. Build sections with canonical order:
   - Navbar (sticky, background change on scroll)
   - Hero (H1 + subtitle + CTA + visual)
   - Value proposition (3-4 blocks)
   - Services / Products (grid or zig-zag)
   - About / Philosophy
   - Testimonials / Logos
   - Final CTA
   - Footer
7. Use `whileInView` for entrance animations.
8. Use `<Image>` from Next.js with descriptive `alt` text.
9. Ensure `"use client"` only used when hooks, events, or state present.

---

### Phase 8 — QA Gates

→ See `engineering-fundamentals` Phase 5 for universal gates.

**After QA gates, log metrics:**
```
LOG METRIC: gate
- project: [detect from git remote or directory]
- gate_name: frontend-web-qa
- result: pass/fail
- checks_passed: [N]/12
```

**Web-specific checks:**

1. **TypeScript** — `npx tsc --noEmit` passes.
2. **Build** — `npm run build` succeeds.
   
   **After build, log metric:**
   ```
   LOG METRIC: build
   - project: [detect from git remote or directory]
   - result: pass/fail
   - duration: [measure]
   - errors: [count]
   - warnings: [count]
   ```
3. **No template residue** — Remove default Next.js text.
4. **No hardcoded colors** — Search `bg-blue-`, `text-gray-`, `bg-red-`. Replace with tokens.
5. **Responsive** — Check 375px, 768px, 1280px.
6. **Accessibility** — Contrast 4.5:1, focus indicators 2px, `prefers-reduced-motion`.
7. **Images** — Every `<Image>` has `alt`. Above-the-fold image has `priority`.
8. **SEO/LLMO** — `sitemap.ts`, `robots.ts`, `llms.txt`, `identity.json` if public.
9. **Reduced motion** — CSS fallback present in `globals.css`.
10. **Animation performance** — Only `transform` and `opacity`. No layout thrashing.
11. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read.
12. **Visual consistency** — No color, font, or spacing deviates without explicit approval.

---

## Examples & Troubleshooting

Read `EXAMPLES.md`:
- Landing page walkthrough (15 steps)
- Adding animation to existing component
- Troubleshooting (Next.js 16 params, fonts, FOUC, hydration, build)

---

## Red Flags (Web-Specific)

- `bg-blue-500`, `text-gray-700`, or Tailwind defaults.
- Display font is Inter, Roboto, Space Grotesk, or Geist.
- Generic centered card grid with no variation.
- Animations use `width`, `height`, or `margin` transitions.
- No `prefers-reduced-motion` fallback.
- Code generated before DESIGN.md confirmed or PLAN created.
- Stack versions outdated (Next.js < 16, Tailwind < 4).

---

## Verification

- `DESIGN.md` exists in project root.
- `design/DESIGN-LOCK.md` exists with approved decisions.
- `globals.css` contains CSS custom property tokens.
- `alt` text on every `<Image>`.
- `prefers-reduced-motion` block in CSS.
- Build passes (`npm run build`).
- No generic Tailwind color utilities.
- Animation code only touches `transform` and `opacity`.
