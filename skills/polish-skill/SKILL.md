---
name: polish-skill
description: >
  Fix design detail issues: spacing, alignment, consistency, token
  compliance. Bridges what audit finds and what the design system
  specifies. Use after audit or when visual inconsistencies are spotted.
license: MIT
compatibility: opencode
metadata:
  audience: all-designers
  stack: any
  workflow: audit-polish
---

# Polish Skill

**Fix design detail issues — spacing, alignment, consistency, token drift.**

Where `harden` fixes technical issues, `polish` fixes visual ones. Works within the existing design system; does not redesign.

## When to Use

- After `audit` finds P1-P2 theming/consistency issues
- When components look "off" but structurally work
- User says "make this look more polished"
- During design QA before shipping
- When design tokens exist but aren't applied consistently

Do NOT use for:
- Technical issues (use `harden`)
- UX flow issues (use `redesign`, `distill`)
- Structural redesign (use `redesign`)
- Copy rewriting (use `clarify`)

## Process

### 1. Scan for Drift

Compare components against the design system tokens:

| What | Check |
|---|---|
| Spacing | Indents match the scale (4, 8, 12, 16, 24, 32, 48, 64) |
| Border radius | Consistent per component type (button: x, card: y) |
| Shadows | Elevation layers match token values |
| Colors | No hardcoded hexes outside token system |
| Type scale | Headings/body sizes match the type ramp |
| Alignment | Text, icons, and containers share baselines |
| Density | Padding/margin is consistent across similar components |
| Focus states | All interactive elements have the same focus style |

### 2. Fix by Category

#### Spacing

| Issue | Fix |
|---|---|
| Inconsistent padding between cards | Normalize to token spacing scale |
| Orphaned margins | Remove half-spacing gaps (use token multiples only) |
| Missing breathing room | Add gap between grouped elements |
| Crowded icons | Add horizontal gap between icon + text |

#### Alignment

| Issue | Fix |
|---|---|
| Misaligned form labels | Set consistent label width or grid |
| Icon-text baseline drift | Vertically align icon with text center |
| Button text not centered | Check flexbox / text-align on button |
| Input text padding | Normalize input left padding across form |

#### Consistency

| Issue | Fix |
|---|---|
| Mixed radius on same element type | Unify per component type |
| Mixed shadow depths | One elevation per layer (card, modal, toast) |
| Different hover effects | Same effect pattern across similar components |
| Mixed border weights | Normalize to token weights (0, 1, 2) |

#### Token Compliance

| Issue | Fix |
|---|---|
| Hardcoded value | Replace with design token |
| Wrong token usage | Replace with correct semantic token |
| Missing dark mode token | Add `dark:` variant |

### 3. Output Format

```
/polish the profile card

Fix 1: Spacing
  - Before: padding 15px (not on scale)
  - After: padding 16px (token --spacing-4)

Fix 2: Border radius
  - Before: 12px
  - After: 8px (token --radius-card)

Fix 3: Shadow
  - Before: 0 4px 6px (custom)
  - After: token --shadow-card (0 2px 8px)

Fix 4: Alignment
  - Before: icon 2px above text baseline
  - After: flex align-items: center
```

### 4. Escalation Rules

| Finding | Escalate to |
|---|---|
| Wrong typeface, weight, or size | `typeset` |
| Missing tokens (need new ones) | Design system review |
| Layout breaks at breakpoint | `adapt` |
| Performance issue in animation | `optimize` |
| Confusing visual hierarchy | `redesign`, `distill` |

## Pitfalls

- **Over-polishing** — Not every component needs to be perfect. Polish the ones users see.
- **Changing design decisions** — If the design intent is unclear, ask. Don't guess the designer's intent.
- **Token zealotry** — A one-off custom value with a clear reason is fine. Systematic drift is not.

## QA Gates

- [ ] All spacing values on the token scale
- [ ] Consistent border radius per component type
- [ ] Shadow depth is consistent per elevation layer
- [ ] No hardcoded colors (confirmed token-only)
- [ ] Icons aligned with text baselines
- [ ] Hover/focus states consistent across similar components
- [ ] Dark mode tokens applied where missing
- [ ] No design decisions silently overridden
