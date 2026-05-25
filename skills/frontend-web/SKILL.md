---
name: frontend-web
description: >
  Build distinctive, production-grade web interfaces. Built on engineering-fundamentals.
  Use when creating or modifying web UIs, landing pages, dashboards, React/Next.js
  components, or when the user asks for web design, styling, animation, or frontend
  implementation. Triggers on: "build a website", "design a landing page", "create a
  component", "add animations", "make it look better", "frontend work", "UI/UX",
  "redesign", "Next.js", "React", "Vue", "web app".
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
web-specific implementation to the universal philosophy.

## When to Use

Use when the user asks to build, design, or redesign any **web interface**:
- Websites, landing pages, dashboards, web apps
- Components, styling, layout, visual polish
- Animations, transitions, scroll effects, micro-interactions

Do NOT use for:
- Backend-only tasks, CLI, or non-visual software
- Mobile native apps (use `frontend-mobile`)
- Installable offline apps (use `frontend-pwa`)

### Stack Detection

Before applying instructions, check for `STACK_CONFIG.md` in the project root.

**If exists:** Adapt all examples to the chosen stack. Principles remain the same.
**If missing:** Default to React 19 + Next.js 16 + Tailwind v4.

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
→ See `engineering-fundamentals` Phase 1 for the universal discovery process.

**Web-specific questions (add to universal):**
1. **Pages**: How many pages/sections? (landing, dashboard, multi-page app)
2. **SEO**: Is this public-facing and indexable?
3. **Animations**: Scroll effects, entrance animations, micro-interactions?

Read `DISCOVERY-GUIDE.md` in this skill directory for the complete web checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**Web-specific contract additions:**
- SPEC.md must include: Tech stack (locked versions), Project structure, SEO requirements if public
- DESIGN.md: Same rules as fundamentals
- Design Asset Lock: `design/` directory with `DESIGN-LOCK.md` + `approved/`

---

### Phase 3 — Aesthetic Direction
→ See `engineering-fundamentals` Phase 3.

Same 8 directions (ED, SM, LDW, CB, UE, NB, PG, RT). Pick ONE.

---

### Phase 4 — Stack Lock-in (Non-Negotiable)

| Tool | Minimum | Notes |
|---|---|---|
| Node.js | 20.9+ | |
| Next.js | 16.1.1+ | App Router, async params, RSC by default |
| React | 19.2+ | |
| TypeScript | 5.7+ | |
| Tailwind CSS | v4 | Uses `@theme` in CSS, not `tailwind.config.ts` |
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
- NEVER use Inter, Roboto, Arial, Space Grotesk, or Geist as display fonts.
- ALWAYS pair a distinctive display font with a refined body font.
- Use `next/font/google` with CSS variables (`--font-display`, `--font-body`).

**Color**
- NEVER use Tailwind generic colors (`bg-blue-500`, `text-gray-700`).
- ALWAYS use CSS custom properties from `DESIGN.md` or `globals.css` tokens.
- Commit to a dominant color with sharp accents.

**Layout**
- NEVER use generic centered card grids as the default.
- ALWAYS consider asymmetry, overlap, diagonal flow, or controlled density.
- Mobile-first: verify 375px before 1280px.

**Motion**
- NEVER animate `width`, `height`, `top`, `left`, `margin`, or `padding`.
- ALWAYS animate `transform` and `opacity` only for 60fps.
- Use `will-change` sparingly and remove after animation.

**Backgrounds**
- NEVER default to flat solid colors.
- ALWAYS consider: gradient meshes, subtle noise textures, geometric patterns, layered transparencies, dramatic shadows, grain overlays.

---

### Phase 6 — Animation System

Read `ANIMATION-GUIDE.md` in this skill directory.

**Summary:**
- **Primary pattern:** Framer Motion `Reveal` component.
- **Fallback:** CSS `animation-timeline` for scroll effects, WAAPI for precise JS animations.
- **Accessibility:** Every animation MUST respect `prefers-reduced-motion`.
- **Performance:** Only `transform` and `opacity` may be animated.

---

### Phase 7 — Build with Tokens

**BEFORE WRITING CODE:**

1. **Read `design/DESIGN-LOCK.md`** — Verify approved direction, palette, typography.
2. **Check `design/approved/`** — Screenshots, previews, moodboards are ground truth.
3. **Cross-check with `DESIGN.md`** — Tokens in code must match the locked system.

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
9. Ensure `"use client"` is only used when hooks, events, or state are present.

---

### Phase 8 — QA Gates

→ See `engineering-fundamentals` Phase 5 for universal gates.

**Web-specific checks:**

1. **TypeScript** — `npx tsc --noEmit` passes.
2. **Build** — `npm run build` succeeds.
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

Read `EXAMPLES.md` in this skill directory:
- Landing page walkthrough (15 steps)
- Adding animation to existing component
- Troubleshooting table (Next.js 16 params, fonts, FOUC, hydration, build)

---

## Red Flags (Web-Specific)

- Output uses `bg-blue-500`, `text-gray-700`, or Tailwind defaults.
- Display font is Inter, Roboto, Space Grotesk, or Geist.
- Layout is a generic centered card grid with no variation.
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
