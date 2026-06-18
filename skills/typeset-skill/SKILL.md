---
name: typeset-skill
description: >
  Fix typography and reading rhythm issues. Covers typeface, weight, size,
  line-height, letter-spacing, paragraph spacing, and type ramp compliance.
  Use when text feels cramped, inconsistent, or off-scale.
version: 1.0.0
license: MIT
compatibility: opencode
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-designers
  stack: any
  workflow: audit-typeset
---

# Typeset Skill

**Fix typography and reading rhythm. Applies the type ramp. Restores consistency.**

Poor typesetting is the most visible "almost right" failure. Fixing it has outsized impact on perceived quality.

## When to Use

- Text feels cramped or airy
- Headings and body don't feel co-ordinated
- Type sizes don't follow a consistent ramp
- Line-height is inconsistent between similar texts
- Font weights vary without reason
- Letter-spacing is random or missing
- After changing type scale or introducing a new variant

Do NOT use for:
- Choosing a new typeface (design decision, not polish)
- Rewriting copy (use `clarify`)
- Color/token issues (use `polish`)
- Spacing/layout issues (use `polish`)

## Process

### 1. Scan the Type Ramp

Check every text style against the ramp. Typical inconsistencies:

| What | Symptom |
|---|---|
| Heading size | 28px when scale says 24px |
| Body size | 15px when scale says 16px |
| Caption size | 13px when scale says 12px |
| Weight | Bold headline correct but subheading also bold (should be medium) |
| Line-height | Heading 1.2 correct, but same size used as body with 1.2 (too tight) |
| Letter-spacing | Headings missing -0.01em, body missing 0 |
| Paragraph gap | Body text has 0 margin-bottom (no rhythm) |

### 2. Fix by Property

#### Size
- Map every text element to the nearest ramp value
- Never use a size between ramp values
- Apply responsive: min size on mobile, ramp size on desktop

#### Weight
- Headings: Bold only for the primary heading, lighter for sub-levels
- Body: Regular (400) or Book (350)
- Strong emphasis: Semi-bold (600), never Bold (700) in body
- Test weight contrast: adjacent text elements should differ by at least 100

#### Line-Height
| Text type | Target |
|---|---|
| Headings (display) | 1.0-1.1 |
| Headings (section) | 1.15-1.25 |
| Body | 1.5-1.7 |
| Caption | 1.4-1.5 |
| Button | 1.0-1.2 |

Narrow columns need taller line-height. Wide columns need tighter.

#### Letter-Spacing
| Text type | Target |
|---|---|
| Display / all-caps | +0.05em to +0.1em |
| Heading | -0.01em to -0.02em |
| Body | 0 (normal) |
| Caption | +0.01em |
| Button | +0.02em to +0.05em |

#### Paragraph Spacing
- Set `margin-bottom` (not `<br>`) between paragraphs
- Value should be 0.5x to 1x of line-height
- Never leave paragraph spacing to default (0)

### 3. Output Format

```
/typeset the article component

Fix 1: Body size
  - Before: font-size 15px (not on ramp)
  - After: font-size 16px (token --type-body)

Fix 2: Heading line-height
  - Before: line-height 1.3 on h2 (too tall for section heading)
  - After: line-height 1.2 (token --leading-section)

Fix 3: Paragraph spacing
  - Before: no margin-bottom between <p>
  - After: margin-bottom 1em

Fix 4: Letter-spacing on button
  - Before: letter-spacing 0
  - After: letter-spacing 0.03em
```

### 4. Escalation Rules

| Finding | Escalate to |
|---|---|
| Wrong typeface | Design decision — needs spec |
| Missing type ramp | Define one in `polish` |
| Overcrowded layout | `distill` or `redesign` |
| Accessibility contrast | `harden` |

## Pitfalls

- **Mixing typefaces** — Never introduce a second typeface during typeset. That's a design decision.
- **Responsive orphans** — Check mobile. A heading that looks great on desktop may be too large or too tight on mobile.
- **Forgetting for long-form** — Body text in a blog needs taller line-height than body text in a dashboard.

## QA Gates

- [ ] All sizes on the type ramp
- [ ] Heading line-height is tight, body line-height is airy
- [ ] Weight contrast: adjacent texts differ by ≥ 100
- [ ] Letter-spacing intentional (not default everywhere)
- [ ] Paragraph spacing set (not 0)
- [ ] Responsive type: check mobile + desktop
- [ ] No `<br>` for paragraph spacing
