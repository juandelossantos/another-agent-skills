# Visual Frontend Mastery — Examples & Troubleshooting

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
7. **STOP.** User confirms `DESIGN.md`. Do NOT code yet.
8. **Create Design Lock:**
   - Generate `design/DESIGN-LOCK.md` with approved direction, final palette, typography, and key decisions.
   - Save `preview.html` into `design/approved/preview-final.html`.
   - Save palette/typography screenshots into `design/approved/`.
9. Invoke `spec-driven-development` → create `SPEC.md` (stack, scope, acceptance criteria).
10. Invoke `planning-and-task-breakdown` → create task plan (file order, component list, dependencies).
11. **Read `design/DESIGN-LOCK.md`** before any file creation.
12. Run setup: `create-next-app`, Tailwind v4, shadcn, Framer Motion.
13. Build all sections with tokens and `Reveal` animations.
14. Run QA gates. Fix any issues.
15. Deliver: `npm run dev` + summary of what was built.

### Example 2: Add Animation to Existing Component

User: "Make this pricing card animate in on scroll."

Agent:
1. Check for `DESIGN.md`. If exists, use its motion tokens.
2. Wrap the card in the `Reveal` component (or CSS `scroll-reveal` if no JS framework).
3. Ensure `prefers-reduced-motion` is respected.
4. Verify only `transform` and `opacity` are used.
5. Done.

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
