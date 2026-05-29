# Change Sizing

Small, focused changes are easier to review, faster to merge, and safer to deploy.

## Target Sizes

```
~100 lines changed   → Good. Reviewable in one sitting.
~300 lines changed   → Acceptable if it's a single logical change.
~1000 lines changed  → Too large. Split it.
```

## What Counts as "One Change"

A single self-contained modification that:
- Addresses one thing
- Includes related tests
- Keeps the system functional after submission

## Splitting Strategies

| Strategy | How | When |
|----------|-----|------|
| **Stack** | Submit a small change, start the next based on it | Sequential dependencies |
| **By file group** | Separate changes for different reviewers | Cross-cutting concerns |
| **Horizontal** | Create shared code/stubs first, then consumers | Layered architecture |
| **Vertical** | Smaller full-stack slices of the feature | Feature work |

**When large changes are acceptable:**
- Complete file deletions
- Automated refactoring where intent is verifiable

**Separate refactoring from feature work.** A change that refactors AND adds behavior is two changes.

## Change Descriptions

Every change needs a description that stands alone in version control history.

**First line:** Short, imperative, standalone.
- Good: "Delete the FizzBuzz RPC"
- Bad: "Deleting the FizzBuzz RPC"

**Body:** What is changing and why. Include context and reasoning not visible in the code.

**Anti-patterns:** "Fix bug," "Fix build," "Add patch," "Phase 1," "Add convenience functions."

## Review Speed

- **Respond within one business day** — maximum, not target
- **Typical cadence:** Multiple review rounds in a single day
- **Large changes:** Ask author to split rather than reviewing one massive changeset

## Handling Disagreements

1. **Technical facts and data** override opinions
2. **Style guides** are the authority on style
3. **Software design** on engineering principles, not preference
4. **Codebase consistency** acceptable if it doesn't degrade health

**Don't accept "I'll clean it up later."** Require cleanup before submission.

## Dependency Discipline

Before adding any dependency:
1. Does the existing stack solve this?
2. How large is it? (Check bundle impact)
3. Is it actively maintained?
4. Does it have known vulnerabilities? (`npm audit`)
5. What's the license?

**Rule:** Prefer standard library and existing utilities. Every dependency is a liability.
