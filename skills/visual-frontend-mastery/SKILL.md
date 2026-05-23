---
name: visual-frontend-mastery
description: >
  Build distinctive, production-grade frontend interfaces with intentional visual design,
  high-performance animations, and modern stack discipline. Use when creating or
  modifying web UIs, landing pages, dashboards, React/Next.js components, or when the
  user asks for design, styling, animation, or frontend implementation. Triggers on:
  "build a website", "design a landing page", "create a component", "add animations",
  "make it look better", "frontend work", "UI/UX", "redesign", or any visual task.
license: MIT
compatibility: opencode
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-shadcn
  workflow: design-driven-build
---

# Visual Frontend Mastery

Build frontend interfaces that feel **intentionally designed**, not AI-generated.
This skill enforces a visual contract (`DESIGN.md`), anti-slop rules, modern animation
patterns, and a locked stack for consistency.

## When to Use

Use this skill when:
- The user asks to build, design, or redesign any web interface
- The task involves React/Next.js components, styling, layout, or visual polish
- Animations, transitions, scroll effects, or micro-interactions are requested
- The output risks looking generic (cards, gradients, default Tailwind)

Do NOT use for:
- Backend-only tasks (APIs, DB schema, infrastructure)
- Internal dashboard tools where function > form
- CLI or non-visual software

---

## Core Process

### Phase 0 — Language Detection

Detect the language of the user's request immediately. All subsequent communication MUST be in that same language.

**Detection rules:**
- If the user writes in **Spanish** (e.g., *"haz"*, *"diseña"*, *"crea"*, *"desarrolla"*, *"quiero"*, *"necesito"*), respond entirely in **Spanish**.
- If the user writes in **English** (e.g., *"build"*, *"design"*, *"create"*, *"make"*), respond entirely in **English**.
- If the user writes in **Portuguese**, **French**, or another language, respond in that language to the best of your ability, falling back to English if uncertain.

**Never mix languages.** Do not ask questions in English if the user spoke Spanish, and vice versa. All questions, assumptions, specs, and code comments must match the detected language.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

This skill triggers on requests like: *"build a website"*, *"design a landing page"*, *"create a component"*, *"add animations"*, *"make it look better"*, *"frontend work"*, *"UI/UX"*, *"redesign"*, or any visual task. It also triggers on Spanish equivalents: *"haz una web"*, *"diseña una landing"*, *"desarrolla una app"*, *"crea una página"*.

Before any file is created, you **MUST** complete this gated checklist. Do not skip steps. Do not assume answers. The spec's entire purpose is to surface misunderstandings *before* code gets written.

#### Step 1: Surface Assumptions

List at least 5 assumptions you are making about the project. Present them to the user for confirmation or correction **in the detected language**:

**English example:**
```
ASSUMPTIONS I'M MAKING:
1. This is a web application (not native mobile)
2. The primary language is English
3. This is for desktop/mobile/both
4. No user authentication is needed
5. Data does not need to persist between sessions
→ Correct me now or I'll proceed with these.
```

**Spanish example:**
```
SUPOSICIONES QUE ESTOY HACIENDO:
1. Esta es una aplicación web (no móvil nativa)
2. El idioma principal es español
3. Es para escritorio/móvil/ambos
4. No se necesita autenticación de usuario
5. Los datos no necesitan persistir entre sesiones
→ Corrígeme ahora o procederé con estas.
```

#### Step 2: Discovery Interview (Minimum 5 Questions)

Ask these questions **in the user's detected language**. Do not proceed until answered:

**English:**
1. **Audience**: Who will use this? (Age, tech-savviness, context)
2. **Purpose**: What problem does this solve in one sentence?
3. **Scope**: Is this an MVP or a complete product? What features are MUST vs. NICE?
4. **Context**: Where and how will this be used? (Phone on a court, office desktop...)
5. **Stack preference**: Any existing tech constraints? (React, Vue, vanilla...)

**Spanish:**
1. **Audiencia**: ¿Quién usará esto? (Edad, conocimiento técnico, contexto)
2. **Propósito**: ¿Qué problema resuelve esto en una oración?
3. **Alcance**: ¿Es un MVP o un producto completo? ¿Qué características son OBLIGATORIAS vs. OPCIONALES?
4. **Contexto**: ¿Dónde y cómo se usará? (Teléfono en una cancha, escritorio de oficina...)
5. **Preferencia de stack**: ¿Hay restricciones técnicas existentes? (React, Vue, vanilla...)

#### Step 3: Extended Discovery (For non-trivial projects)

If the project involves logic, data, or user interactions, also ask:

6. **Data / Datos**: What data needs to be stored? Where? (localStorage, database, none)
7. **Security / Seguridad**: Any auth, private data, or compliance needs? (GDPR, accessibility laws)
8. **Scalability / Escalabilidad**: 10 users or 10,000? Single match or tournament management?
9. **Offline / Sin conexión**: Does it need to work without internet?
10. **Integration / Integración**: Does it connect to other systems? (APIs, payment, analytics)

#### Step 4: Visual Direction (if applicable)

If the project has a visual component, ask:

11. **References / Referencias**: Any websites, apps, or styles you like?
12. **Mood / Tono**: Playful, serious, luxury, brutalist, minimalist?
13. **Brand / Marca**: Do you have existing colors, fonts, or a logo?

#### Step 5: Confirm & Lock

Summarize everything in a concise paragraph. Ask: **"¿Es esto correcto? ¿Arrancamos? / Is this correct? Shall we proceed?"**

Only after explicit confirmation ("sí", "yes", "adelante", "perfecto", "vamos"), proceed to Phase 2.

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md (for new projects/features)

If there is **no `SPEC.md`** and this is a **new feature or page** (not a one-off component tweak), invoke `spec-driven-development` to write one.

The SPEC.md **must** include:
- Objective (what + why + who)
- Scope (in/out)
- Tech stack (locked versions)
- Project structure
- Acceptance criteria (testable)
- Boundaries (Always / Ask First / Never)

#### 2B: DESIGN.md (for visual work)

Check for `DESIGN.md` in the project root.

- **Path A — DESIGN.md exists:**
  - Read it. Extract tokens (colors, typography, spacing, motion).
  - Build STRICTLY within those tokens.
  - If a task requires a token not in the contract, pause and ask to extend it.

- **Path B — No DESIGN.md, user wants a visual system:**
  - Use answers from Phase 1 Discovery to pick an aesthetic direction.
  - Pick ONE direction from the 8 below (do not default).
  - Generate a `DESIGN.md` with tokens and save it.
  - Present it for confirmation before building.

- **Path C — No DESIGN.md, one-off task:**
  - Do the task. Mention once that a `DESIGN.md` improves long-term consistency.
  - Do not nag again.

#### 2C: Lifecycle Awareness

If the project has an `AGENTS.md` with lifecycle mapping, respect it:
- **DEFINE** → `spec-driven-development`
- **PLAN** → `planning-and-task-breakdown`
- **BUILD** → This skill + `incremental-implementation`
- **VERIFY** → `debugging-and-error-recovery`
- **REVIEW** → `code-review-and-quality`
- **SHIP** → `shipping-and-launch`

### Phase 2 — Choose Aesthetic Direction (Path B only)

Pick ONE direction based on the sector. Do not blend.

| ID | Direction | Best For |
|---|---|---|
| ED | Editorial Serif | Media, personal brand, luxury |
| SM | Swiss Minimal | SaaS B2B, devtools, fintech |
| LDW | Luxury Dark Warm | Hospitality, jewelry, fashion |
| CB | Corporate Bold | Enterprise, education, legal |
| UE | Understated Elegance | Cafes, agencies, wellness, portfolio |
| NB | Neo-Brutalist | Startups, creative communities |
| PG | Playful Gradient | Consumer apps, edtech |
| RT | Retro Terminal | DevTools, technical docs |

### Phase 3 — Stack Lock-in (No Negotiable)

If the project uses React/Next.js, enforce this stack:

| Tool | Minimum | Notes |
|---|---|---|
| Node.js | 20.9+ | Required by Next.js 16 |
| Next.js | 16.1.1+ | App Router, async params, RSC by default |
| React | 19.2+ | Auto-installed |
| TypeScript | 5.7+ | |
| Tailwind CSS | v4 | Uses `@theme` in CSS, not `tailwind.config.ts` |
| shadcn CLI | latest | Registry-based, copy-not-install |
| Framer Motion | 12+ (package `motion`) | Primary animation engine |
| lucide-react | latest | Default icons |

Optional add-ons (only if requested):
- `lenis` — smooth scroll
- `split-type` — kinetic typography
- `gsap` + `@gsap/react` — scroll storytelling (pinned sections only)
- `react-hook-form` + `zod` + `@hookform/resolvers` — form validation
- `@tanstack/react-table` — data tables

Forbidden defaults:
- GSAP by default (too heavy for simple reveals)
- `tailwind.config.ts` (Tailwind v4 uses CSS-based config)
- `middleware.ts` (Next.js 16 uses `proxy.ts`)
- Spline (use Three.js + R3F if 3D is needed)

### Phase 4 — Anti-AI-Slop Rules

These rules are non-negotiable. They prevent the generic "AI look."

**Typography**
- NEVER use Inter, Roboto, Arial, Space Grotesk, or Geist as display fonts.
- ALWAYS pair a distinctive display font with a refined body font.
- Use `next/font/google` with CSS variables (`--font-display`, `--font-body`).

**Color**
- NEVER use Tailwind generic colors (`bg-blue-500`, `text-gray-700`).
- ALWAYS use CSS custom properties from `DESIGN.md` or `globals.css` tokens.
- Commit to a dominant color with sharp accents. Timid palettes are forbidden.

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
- ALWAYS consider: gradient meshes, subtle noise textures, geometric patterns,
  layered transparencies, dramatic shadows, grain overlays.

### Phase 5 — Animation System

**Default Pattern (Framer Motion + React)**
Use this canonical reveal component:

```tsx
"use client";
import { motion } from "motion/react";

export function Reveal({
  children,
  delay = 0,
}: {
  children: React.ReactNode;
  delay?: number;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, delay, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  );
}
```

**Scroll-Driven Animations (CSS)**
For scroll-linked effects without JS overhead, use `animation-timeline`:

```css
@supports (animation-timeline: scroll()) {
  .scroll-reveal {
    animation: fade-up 1ms linear;
    animation-timeline: view();
    animation-range: entry 10% cover 40%;
  }
}
```

**Web Animations API (WAAPI)**
Use for synchronized, precise JS-controlled animations:

```js
const el = document.querySelector(".target");
const anim = el.animate(
  [{ opacity: 0, transform: "translateY(20px)" },
   { opacity: 1, transform: "translateY(0)" }],
  { duration: 600, easing: "cubic-bezier(0.22, 1, 0.36, 1)", fill: "forwards" }
);
```

**Reduced Motion (WCAG 2.3.3)**
Every animation MUST respect `prefers-reduced-motion`:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Phase 6 — Build with Tokens

1. Apply tokens from `DESIGN.md` to `src/app/globals.css`.
2. Use `next/font/google` for fonts in `layout.tsx`.
3. Build sections with the canonical order:
   - Navbar (sticky, background change on scroll)
   - Hero (H1 + subtitle + CTA + visual)
   - Value proposition (3-4 blocks)
   - Services / Products (grid or zig-zag)
   - About / Philosophy
   - Testimonials / Logos
   - Final CTA
   - Footer
4. Use `whileInView` for entrance animations on each section.
5. Use `<Image>` from Next.js with descriptive `alt` text.
6. Ensure `"use client"` is only used when hooks, events, or state are present.

### Phase 7 — QA Gates

Before declaring the task complete, verify:

1. **TypeScript** — `npx tsc --noEmit` passes.
2. **Build** — `npm run build` succeeds.
3. **No template residue** — Remove Next.js default text ("Get started by editing").
4. **No hardcoded colors** — Search for `bg-blue-`, `text-gray-`, `bg-red-`. Replace with tokens.
5. **Responsive** — Check 375px, 768px, 1280px.
6. **Accessibility** — axe-core or manual check: contrast 4.5:1, focus indicators 2px, `prefers-reduced-motion`.
7. **Images** — Every `<Image>` has a descriptive `alt`. Above-the-fold image has `priority`.
8. **SEO/LLMO** — `sitemap.ts`, `robots.ts`, `llms.txt`, `identity.json` present if this is a public site.
9. **Reduced motion** — CSS fallback present in `globals.css`.
10. **Animation performance** — Only `transform` and `opacity` animated. No layout thrashing.

---

## Examples

### Example 1: New Landing Page

User: "I need a landing page for my coffee shop called Ritmo Negro."

Agent:
1. Detect no `DESIGN.md`.
2. Ask the 5 intake questions (business, audience, CTA, sector=hospitality, references?).
3. Select 3 directions for hospitality: Understated Elegance, Luxury Dark Warm, Editorial Serif.
4. Generate `preview.html` with 3 heroes side-by-side.
5. User picks "Understated Elegance" (code `STYLE:UE-L1`).
6. Generate `DESIGN.md` with tokens for UE + palette L1 + font pair F4.
7. Run setup: `create-next-app`, Tailwind v4, shadcn, Framer Motion.
8. Build all sections with tokens and `Reveal` animations.
9. Run QA gates. Fix any issues.
10. Deliver: `npm run dev` + summary of what was built.

### Example 2: Add Animation to Existing Component

User: "Make this pricing card animate in on scroll."

Agent:
1. Check for `DESIGN.md`. If exists, use its motion tokens.
2. Wrap the card in the `Reveal` component (or CSS `scroll-reveal` if no JS framework).
3. Ensure `prefers-reduced-motion` is respected.
4. Verify only `transform` and `opacity` are used.
5. Done.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll just use the default Tailwind colors for now." | Hardcoded Tailwind colors violate the token system and create inconsistency. |
| "Inter is a safe font choice." | Inter is the #1 sign of AI-generated UI. Use a distinctive font. |
| "This is too small for a DESIGN.md." | Even one-off tasks benefit from 3 lines of tokens. It prevents slop. |
| "I'll add reduced-motion later." | Accessibility is not a stretch goal. It's a gate. Add it now. |
| "GSAP is more powerful than Framer Motion." | GSAP is heavier and overkill for 90% of UI animations. Use Framer Motion first. |
| "The user didn't ask for animations." | Subtle entrance animations are standard for production-grade UI. Default to them. |
| "I'll animate width/height for this effect." | That drops frames. Use `scale` or `opacity` instead. |
| "This looks fine on my screen." | Check 375px. Mobile-first is the rule, not the exception. |

---

## Red Flags

Watch for these signals that the skill is being violated:
- The output uses `bg-blue-500`, `text-gray-700`, or similar Tailwind defaults.
- The display font is Inter, Roboto, Space Grotesk, or Geist.
- The layout is a generic centered card grid with no variation.
- Animations use `width`, `height`, or `margin` transitions.
- There is no `prefers-reduced-motion` fallback.
- The agent generates code before confirming or creating a `DESIGN.md` (Path B).
- The stack versions are outdated (Next.js < 16, Tailwind < 4).

---

## Verification

Evidence that this skill was followed:
- `DESIGN.md` exists in the project root (for Path A and B).
- `globals.css` contains CSS custom property tokens, not hardcoded hex values in components.
- `alt` text is present on every `<Image>`.
- `prefers-reduced-motion` block exists in CSS.
- Build passes (`npm run build` or `tsc --noEmit`).
- No generic Tailwind color utilities in the final code.
- Animation code only touches `transform` and `opacity`.

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `params` is a Promise error | Next.js 16 async params | `const { id } = await params` |
| Fonts not loading | Forgot `.variable` on `<html>` | `<html className={\`${displayFont.variable}\`}>` |
| FOUC on load | Animation state not in CSS | Set `opacity: 0` in CSS, animate `to` in JS |
| Hydration mismatch | `Math.random()` or `Date.now()` in RSC | Move to Client Component or use `await connection()` |
| Build fails with Prisma + Turbopack | Known incompatibility | `npm run build -- --webpack` |
| Styles not loading in preview | Offline / no Google Fonts | Ensure connection or self-host fonts |
