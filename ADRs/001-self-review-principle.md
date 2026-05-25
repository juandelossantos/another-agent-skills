# Architecture Decision Record: Self-Review Principle

**Status:** ✅ Active
**Date:** 2026-05-25
**Decision:** All changes to skills, AGENTS.md, or guides require self-review before commit.

## Context

We have built a quality-focused skill ecosystem with:
- `code-review-and-quality` (5-axis review: correctness, readability, architecture, security, performance)
- `spec-driven-development` (contracts before code)
- `incremental-implementation` (small, focused changes)
- `project-metrics` (empirical quality tracking)

Yet we were applying these to user projects while **not applying them to our own codebase**. This is hypocrisy and creates blind spots.

## Decision

**Every change to this repository MUST pass self-review before commit.**

### Rules

1. **Changes > 50 lines** → MUST invoke `code-review-and-quality` skill before committing
2. **Changes > 200 lines** → MUST split into smaller commits (incremental-implementation)
3. **Refactors** → MUST verify no functionality lost (correctness axis)
4. **Deletions** → MUST verify the content is truly dead code, not just "seems unused"
5. **Token optimization** → MUST verify compressed version doesn't lose critical rules

### Self-Review Checklist (before every commit)

```
SELF-REVIEW CHECKLIST:

Correctness:
- [ ] Does this change do what I claim it does?
- [ ] Did I test it? (Build passes, skill loads correctly)
- [ ] If I deleted content, did I verify it's truly unused?
- [ ] If I compressed text, did I verify no rule was lost?

Readability:
- [ ] Is the change understandable without me explaining it?
- [ ] Are names/descriptions consistent?
- [ ] No "clever" compression that makes rules ambiguous

Architecture:
- [ ] Does this follow the skill template (foundation + implementation)?
- [ ] No duplication with engineering-fundamentals?
- [ ] Lazy loading pattern respected?

Security:
- [ ] No secrets or tokens in commits
- [ ] No .env files committed

Performance (Token Budget):
- [ ] Did I actually reduce tokens, or just move them around?
- [ ] Is the skill still < 250 lines?
- [ ] Are guides loaded on-demand, not eagerly?
```

## Consequences

**Positive:**
- We eat our own dog food
- Quality improvements are validated, not assumed
- No more "refactored and broke something" surprises
- Metrics reflect real improvements, not wishful thinking

**Negative:**
- Slower iteration (but higher quality)
- More friction per change (but fewer bugs)

## Verification

Evidence this ADR is followed:
- [ ] Last 5 commits include self-review notes
- [ ] No commit > 200 lines without split justification
- [ ] No deletions without verification comment
- [ ] No compression without before/after rule comparison
