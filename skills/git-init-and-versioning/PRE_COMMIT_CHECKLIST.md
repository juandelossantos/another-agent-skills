# Pre-Commit Auto-Review Checklist

Before every commit during BUILD phase, verify:

## 1. Correctness
- [ ] Code matches the task acceptance criteria from SPEC.md
- [ ] Edge cases handled (null, empty, boundary values)
- [ ] Error paths handled (not just happy path)
- [ ] All tests pass (`npm test` or equivalent)
- [ ] Build succeeds (`npm run build` or equivalent)

## 2. Readability
- [ ] Names are descriptive (no `temp`, `data`, `result` without context)
- [ ] No nested ternaries or deep callback nesting
- [ ] Related code is grouped logically
- [ ] Could this be simpler? (Simplicity > cleverness)
- [ ] Comments explain WHY, not WHAT (no obvious comments)

## 3. Architecture
- [ ] Follows existing patterns or new pattern is justified
- [ ] No code duplication without reason
- [ ] No circular dependencies
- [ ] Abstraction level appropriate (not over-engineered)

## 4. Security
- [ ] No secrets in code, logs, or this commit
- [ ] User input validated and sanitized
- [ ] SQL queries parameterized (no string concatenation)
- [ ] Outputs encoded to prevent XSS
- [ ] Dependencies have no known vulnerabilities (`npm audit`)

## 5. Performance
- [ ] No N+1 query patterns
- [ ] No unbounded loops or unconstrained data fetching
- [ ] No synchronous operations that should be async
- [ ] No unnecessary re-renders (UI components)

## 6. Git Hygiene
- [ ] Commit does ONE logical thing
- [ ] Commit message explains WHY (not just WHAT)
- [ ] `.gitignore` covers any new generated files
- [ ] No `.env` or secrets committed

**If ANY check fails → FIX BEFORE COMMITTING.**
**Do not commit and "fix later."**
