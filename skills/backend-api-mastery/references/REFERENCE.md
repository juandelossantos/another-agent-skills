# Reference: Rationalizations, Red Flags, Walkthroughs

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "Express with no ORM." | Raw SQL = error-prone. ORM prevents injection + enables refactoring. |
| "JWT is modern, so better." | JWT insecure for sessions. Server-side sessions are more revocable. |
| "GraphQL > REST." | GraphQL for complex multi-consumer queries. REST for simple CRUD. |
| "I'll build my own auth." | Auth is security-critical. Use NextAuth, Clerk, Supabase Auth. |
| "400 and 422 are the same." | 400 = malformed. 422 = valid syntax, invalid semantics. Fix helps clients debug. |

## Red Flags

- Defaults to Express + MongoDB without justification
- Proposes JWT for traditional web apps without discussing sessions
- Designs auth from scratch instead of using established libraries
- Omits input validation or rate limiting
- Uses 200 OK for errors or mixes up 401/403
- Skips API documentation
- Uses hardcoded year in research queries (must use [current year])

## Walkthroughs

See guides: `guides/DISCOVERY-GUIDE.md` (simple CRUD blog API), `guides/PROTOCOL-GUIDE.md` (e-commerce with GraphQL + Stripe).
