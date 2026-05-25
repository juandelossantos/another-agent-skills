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
- Spanish keywords (*"haz"*, *"diseña"*, *"crea"*, *"desarrolla"*) → **Spanish**.
- English keywords (*"build"*, *"design"*, *"create"*, *"make"*) → **English**.
- Other languages → Respond in that language, fallback to English if uncertain.

**Never mix languages.** All questions, specs, and code comments must match the detected language.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

Read `DISCOVERY-GUIDE.md` in this skill directory for the complete checklist.

**Summary:** Surface assumptions, ask minimum 5 discovery questions (audience, purpose, scope, context, stack), extend to 10 for non-trivial projects (data, security, scalability, offline, integration), plus 3 visual direction questions (references, mood, brand). Confirm with user before proceeding.

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md

If there is **no `SPEC.md`** and this is a **new feature or page** (not a one-off component tweak), invoke `spec-driven-development` to write one.

The SPEC.md **must** include: Objective, Scope, Tech stack (locked versions), Project structure, Acceptance criteria, Boundaries.

#### 2B: DESIGN.md (VISUAL ONLY — No Architecture)

Check for `DESIGN.md` in the project root.

**CRITICAL RULE:** `DESIGN.md` is for **visual identity and design tokens ONLY**. Never architecture, folder structure, API routes, business logic, or stack decisions. Those belong in `SPEC.md`.

**What goes in:** Colors, Typography, Spacing, Rounded corners, Elevation/shadows, Motion tokens, Component visual tokens, Visual Do's and Don'ts.

**What NEVER goes in:** Tech versions, folder structure, API routes, state management, auth, database schema.

**Paths:**
- **Path A** — DESIGN.md exists: Read it, extract tokens, build strictly within them.
- **Path B** — No DESIGN.md, user wants visual system: Use Phase 1 answers to pick 1 of 8 directions below. Generate DESIGN.md with visual tokens only. Present for confirmation.
- **Path C** — No DESIGN.md, one-off task: Do the task. Mention once that a DESIGN.md improves consistency.

**AFTER DESIGN.md IS CONFIRMED — MANDATORY STOP:**

Do NOT write code yet. You have completed DEFINE, not BUILD.

1. Check if a `SPEC.md` exists. If not, invoke `spec-driven-development` to create one.
2. Invoke `planning-and-task-breakdown` to produce a concrete implementation plan.
3. Only after the plan exists and is confirmed, proceed to Phase 3 (Stack) and Phase 6 (Build).

#### 2D: Design Asset Lock (MANDATORY after visual approval)

Create a `design/` directory in the project root:

```
design/
├── DESIGN-LOCK.md          # Snapshot of all approved visual decisions
└── approved/
    ├── preview-final.html    # Approved preview
    ├── palette.png           # Approved palette screenshot
    ├── typography.png        # Approved font screenshot
    └── moodboard/            # Reference images
```

`DESIGN-LOCK.md` must contain: Direction (aesthetic ID + mood), Final Palette (all colors with HEX + usage), Final Typography (display + body fonts + scale), Key Decisions (every explicit user decision), References (links to approved assets).

**Rules:**
- DESIGN-LOCK.md is a SNAPSHOT. It never changes after approval unless the user explicitly requests a redesign.
- All screenshots, previews, and references from Phase 1/2 MUST be copied into `design/approved/`.
- During BUILD (Phase 6), you MUST read `design/DESIGN-LOCK.md` before writing any component. Do not rely on memory.

#### 2C: Lifecycle Awareness

Respect `AGENTS.md` lifecycle mapping:
- DEFINE → `spec-driven-development`
- PLAN → `planning-and-task-breakdown`
- BUILD → This skill + `incremental-implementation`
- VERIFY → `debugging-and-error-recovery`
- REVIEW → `code-review-and-quality`
- SHIP → `shipping-and-launch`

### Phase 2 — Choose Aesthetic Direction (Path B only)

Pick ONE direction. Do not blend.

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

---

### Phase 3 — Stack Lock-in (Non-Negotiable)

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

Optional add-ons (only if requested): `lenis`, `split-type`, `gsap` + `@gsap/react` (pinned sections only), `react-hook-form` + `zod`, `@tanstack/react-table`.

Forbidden defaults: GSAP by default, `tailwind.config.ts`, `middleware.ts`, Spline.

---

### Phase 4 — Anti-AI-Slop Rules

Non-negotiable rules to prevent the generic "AI look."

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
- ALWAYS consider: gradient meshes, subtle noise textures, geometric patterns, layered transparencies, dramatic shadows, grain overlays.

---

### Phase 5 — Animation System

Read `ANIMATION-GUIDE.md` in this skill directory for complete implementation details.

**Summary:**
- **Primary pattern:** Framer Motion `Reveal` component.
- **Fallback patterns:** CSS `animation-timeline` for scroll effects, WAAPI for precise JS animations.
- **Accessibility:** Every animation MUST respect `prefers-reduced-motion`.
- **Performance:** Only `transform` and `opacity` may be animated.

---

### Phase 6 — Build with Tokens

**BEFORE WRITING CODE:**

1. **Read `design/DESIGN-LOCK.md`** — Verify approved direction, palette, typography, key decisions.
2. **Check `design/approved/`** — Screenshots, previews, moodboards are ground truth.
3. **Cross-check with `DESIGN.md`** — Tokens in code must match the locked visual system.

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

### Phase 7 — QA Gates

Before declaring complete, verify:

1. **TypeScript** — `npx tsc --noEmit` passes.
2. **Build** — `npm run build` succeeds.
3. **No template residue** — Remove default Next.js text.
4. **No hardcoded colors** — Search `bg-blue-`, `text-gray-`, `bg-red-`. Replace with tokens.
5. **Responsive** — Check 375px, 768px, 1280px.
6. **Accessibility** — Contrast 4.5:1, focus indicators 2px, `prefers-reduced-motion`.
7. **Images** — Every `<Image>` has descriptive `alt`. Above-the-fold image has `priority`.
8. **SEO/LLMO** — `sitemap.ts`, `robots.ts`, `llms.txt`, `identity.json` if public site.
9. **Reduced motion** — CSS fallback present in `globals.css`.
10. **Animation performance** — Only `transform` and `opacity`. No layout thrashing.
11. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read before coding.
12. **Visual consistency** — No color, font, or spacing deviates from `DESIGN.md` without explicit user approval.

---

## Examples & Troubleshooting

Read `EXAMPLES.md` in this skill directory for:
- Detailed walkthrough of a new landing page (15 steps)
- Adding animation to an existing component
- Troubleshooting table (Next.js 16 params, fonts, FOUC, hydration, build issues)

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
| "The user is eager, I'll start coding now that DESIGN.md is approved." | DESIGN.md approval completes DEFINE, not BUILD. You MUST plan first. |
| "I remember the design, I don't need to look at the files again." | Agent context can drift or reset. The `design/DESIGN-LOCK.md` is the ground truth. |

---

## Red Flags

Watch for these signals that the skill is being violated:
- The output uses `bg-blue-500`, `text-gray-700`, or similar Tailwind defaults.
- The display font is Inter, Roboto, Space Grotesk, or Geist.
- The layout is a generic centered card grid with no variation.
- Animations use `width`, `height`, or `margin` transitions.
- There is no `prefers-reduced-motion` fallback.
- The agent generates code before confirming or creating a `DESIGN.md` (Path B).
- The agent writes code immediately after `DESIGN.md` is approved without creating a PLAN.
- The agent does not read `design/DESIGN-LOCK.md` before writing code.
- The stack versions are outdated (Next.js < 16, Tailwind < 4).

---

## Verification

Evidence that this skill was followed:
- `DESIGN.md` exists in the project root (for Path A and B).
- `design/DESIGN-LOCK.md` exists and contains approved direction, palette, typography, and key decisions.
- `design/approved/` contains any previews, screenshots, or moodboards.
- `globals.css` contains CSS custom property tokens, not hardcoded hex values in components.
- `alt` text is present on every `<Image>`.
- `prefers-reduced-motion` block exists in CSS.
- Build passes (`npm run build` or `tsc --noEmit`).
- No generic Tailwind color utilities in the final code.
- Animation code only touches `transform` and `opacity`.
