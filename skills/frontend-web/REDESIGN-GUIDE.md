# Frontend Web — Redesign Guide

Protocol for auditing and improving existing codebases. Use when the task is "fix this UI" or "make this look better" on an existing project.

---

## Phase 1: Mode Detection

| Signal | Mode |
|---|---|
| User says "build", "create", "new" | **Greenfield** — skip redesign protocol |
| User says "fix", "update", "make it look better" on existing code | **Redesign** — run this guide |
| Existing site with clear brand identity | **Preserve** — keep brand tokens, fix only layout/spacing |
| Existing site with no clear identity | **Overhaul** — full redesign within current stack |

---

## Phase 2: Audit (Scan Before Touch)

### Typography (12 checks)
- [ ] Current font stack identified
- [ ] Inter/Roboto/Arial detected as defaults? Flag for replacement
- [ ] Font hierarchy documented (h1-h6 sizes, weights, line-height)
- [ ] Readability at body size (min 16px, line-height ≥ 1.5)
- [ ] Line length constrained (max 65-75ch)
- [ ] Orphans and widows in headings
- [ ] Loading strategy (`next/font`, `@font-face` + `font-display: swap`)

### Color & Surfaces (15 checks)
- [ ] Palette extraction (dominant, accent, neutrals)
- [ ] AI-purple detected? Flag for replacement
- [ ] Premium-consumer palette detected (beige+brass)? Flag for replacement
- [ ] Contrast ratio (WCAG AA 4.5:1 body, 3:1 large text)
- [ ] Color used as sole state indicator
- [ ] Pure `#000000` or `#ffffff` detected
- [ ] Dark mode exists or needs creation
- [ ] Hardcoded hex values vs. CSS variables

### Layout (14 checks)
- [ ] Page sections identified and inventoried
- [ ] Generic centered card grid detected
- [ ] Hero fits viewport
- [ ] Nav wraps to 2 lines at desktop
- [ ] Section spacing consistent
- [ ] Mobile tested at 375px
- [ ] Content density appropriate (not data-dump sections)
- [ ] Eyebrow tags overused (count them)

### Interactivity & States (10 checks)
- [ ] Hover states exist on all interactive elements
- [ ] Active/focus states exist
- [ ] Loading states (skeleton, not spinner)
- [ ] Empty states
- [ ] Error states
- [ ] Button contrast verified
- [ ] CTA labels distinct (no duplicate intent)

### Content (12 checks)
- [ ] Em-dashes present? Replace all
- [ ] AI copy clichés ("Elevate", "Seamless", "Next-Gen")
- [ ] Generic placeholder names ("John Doe", "Acme Corp")
- [ ] Lorem ipsum or placeholder text
- [ ] Fake-precise numbers
- [ ] Headlines too long (> 8 words)
- [ ] Spec-sheet rows with `border-b` on every item

---

## Phase 3: Fix Priority Order

1. **Font swap** — Replace banned defaults (Inter, Roboto) with Geist, Satoshi, Outfit
2. **Color palette** — Replace AI defaults with intentional palette, add CSS variables
3. **Hover/active states** — Add tactile feedback to all interactive elements
4. **Layout/spacing** — Fix hero overflow, nav wrapping, section consistency
5. **Replace components** — Card grids, spec sheets, eyebrow overuse
6. **Add loading/empty/error states** — Every data-driven component
7. **Polish typography** — Line-height, max-width, italic clearance, eyebrow count

---

## Rules

- Work with the existing stack. Don't switch frameworks.
- Don't break existing functionality. Changes are visual only unless data is wrong.
- Check `package.json` before adding new dependencies.
- Keep changes reviewable. One fix category per commit.
- Update `DESIGN.md` and `DESIGN-LOCK.md` after redesign is approved.
