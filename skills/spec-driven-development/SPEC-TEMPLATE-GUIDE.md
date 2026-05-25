# Spec-Driven Development — Spec Template Guide

This guide contains the complete SPEC.md template for `spec-driven-development`.

## Phase 4 — Write SPEC.md

**The spec is the contract. Complete enough that another engineer could build it without talking to you.**

### Template

```markdown
# Spec: [Project/Feature Name]

## Objective
[What + why + who. 2-3 sentences max. Include user story if helpful.]

## Research Context
[What we learned from Phase 1 research. Link to sources if specific.]
- Domain insight: [...]
- Technology context: [...]
- Risks identified: [...]

## Architecture Decisions
[From architecture-analysis, or "Simple project, standard stack"]
- Chosen: [stack/pattern] because [justification]
- Rejected: [alternative] because [reason]
- Trade-offs accepted: [...]

## Tech Stack
[Framework, language, key dependencies with LOCKED versions]
- Frontend: [...]
- Backend (if applicable): [...]
- Database: [...]
- Auth: [...]
- Hosting: [...]
- Testing: [...]

## Commands
[Full executable commands with flags]
```bash
# Development
npm run dev

# Testing
npm test -- --coverage

# Build
npm run build

# Lint
npm run lint
```

## Project Structure
```
src/
├── app/               → Next.js App Router
├── components/        → Reusable UI components
├── lib/               → Utilities, helpers
├── hooks/             → Custom React hooks
└── types/             → Shared TypeScript types

public/               → Static assets

tests/
├── unit/              → Component tests
├── integration/       → API/module tests
└── e2e/               → Playwright tests

docs/                 → Documentation
design/               → Design assets and lock
architecture/         → Architecture docs
```

## Code Style
```typescript
// Example of expected code quality
export function Button({ variant = 'primary', children }: ButtonProps) {
  // Use CSS custom properties, not hardcoded values
  return <button className={`btn btn-${variant}`}>{children}</button>;
}
```

- Naming: PascalCase components, camelCase functions, kebab-case files
- Types: Strict TypeScript, no `any`
- Comments: Why, not what. No commented-out code.

## Testing Strategy
- **Unit:** Vitest for components and utilities
- **Integration:** API routes, database queries
- **E2E:** Playwright for critical user flows
- **Coverage:** Minimum 70% for new code

## Acceptance Criteria
[Checklist of done conditions. Be specific and testable.]

- [ ] [Criterion 1: specific, measurable]
- [ ] [Criterion 2: specific, measurable]
- [ ] [Criterion 3: specific, measurable]

## Boundaries
[What is NOT included. Prevent scope creep.]

- Out of scope: [...]
- Phase 2 (future): [...]
- Won't do: [...]

## Dependencies
[What must exist before this work starts]

- [ ] [External API account]
- [ ] [Design system tokens]
- [ ] [Database schema v2]

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [...] | High/Med/Low | High/Med/Low | [...] |

## Timeline
[If known. Optional for early-phase specs.]

- Week 1: [...]
- Week 2: [...]

## Notes
[Anything else. Links, references, context.]
```

---

## After Writing the Spec

1. **Read it aloud.** Does it make sense? Is anything ambiguous?
2. **Check for holes.** Are edge cases covered? Are error paths described?
3. **Validate with user.** "This is what I understood. Correct?"
4. **Save as `SPEC.md`** in project root.
5. **Treat as living document.** Update when decisions change.
