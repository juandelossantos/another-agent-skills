---
name: redesign-skill
description: >
  Systematic approach to improving existing codebases. Scan the UI, diagnose
  issues across 8 categories, then fix in priority order. Works with existing
  stack, never breaks functionality.
version: 1.0.0
license: MIT
compatibility: opencode
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: frontend-developers
  stack: any
  workflow: audit-fix
---

# Redesign Skill

**Scope:** Existing projects that need a visual upgrade. Not for greenfield builds.

## When to Use

Use when: upgrading visual design of existing codebase. Not for greenfield projects.

## Process: Scan → Diagnose → Fix

### Phase 1: Scan

Before touching code, run the full audit from `frontend-web/REDESIGN-GUIDE.md`:
- Typography (12 checks)
- Color & Surfaces (15 checks)
- Layout (14 checks)
- Interactivity & States (10 checks)
- Content (12 checks)
- Component Patterns (10 checks)
- Iconography (7 checks)
- Code Quality (7 checks)

### Phase 2: Diagnose

Categorize findings:

| Severity | Definition | Action |
|---|---|---|
| 🔴 Critical | Accessibility failure, broken layout, unreadable text | Fix immediately |
| 🟡 High | AI tells, banned defaults, missing states | Fix in this pass |
| 🔵 Medium | Suboptimal spacing, inconsistent tokens | Fix if time allows |
| ⚪ Low | Nice-to-have polish | Document for future |

### Phase 3: Fix (Priority Order)

1. **Font swap** — Replace Inter/Roboto with Geist, Satoshi, Outfit
2. **Color palette** — Replace AI defaults with intentional system, add CSS variables
3. **Hover/active/focus states** — Add to all interactive elements
4. **Layout & spacing** — Hero overflow, nav wrapping, section consistency
5. **Component replacement** — Card grids, spec sheets, eyebrow overuse
6. **States** — Add loading (skeleton), empty, error states
7. **Typography polish** — Line-height, max-width, italic clearance, eyebrow count

### Rules

- Work with existing stack. Do not switch frameworks.
- Do not break existing functionality — visual changes only unless data is wrong.
- Check `package.json` before adding dependencies.
- One fix category per commit. Keep changes reviewable.
- Update `DESIGN.md` and `DESIGN-LOCK.md` after approval.
