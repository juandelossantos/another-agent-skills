# Memory — Backend API Mastery

## API Antipatterns Observed in AI-Generated Code

| Antipattern | Example | Fix |
|---|---|---|
| Single endpoint returns everything | `GET /api/data` with 50KB response | Split into domain-specific endpoints; add pagination |
| No input validation | Endpoint accepts raw JSON without schema validation | Add Zod/Joi/Pydantic schema before any handler logic |
| Leaky auth: checking auth in handlers instead of middleware | Each route duplicates `if (!user) return 401` | Move auth check to middleware/filter/interceptor |
| No rate limiting | Public endpoints have no throttle | Add rate limiter middleware (Redis-backed for distributed) |
| Sync operations in async context | `requests.get()` inside `async def` | Use `httpx.AsyncClient` or equivalent |
| Magical error responses | `return {"error": str(e)}` leaking internals | Define error schema; log internal details, return safe messages |
| No health check endpoint | No way to verify API is alive | Add `GET /health` returning `{"status": "ok"}` |

## Rule of Thumb

AI-generated APIs optimize for the happy path. Your review must verify: auth fails, invalid input, rate limits, downstream timeouts, and malformed responses — because the AI won't generate those paths on its own.
