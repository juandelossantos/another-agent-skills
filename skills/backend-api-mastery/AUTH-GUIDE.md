# Auth & Security Guide

This guide contains the complete Phase 5 Auth & Security for `backend-api-mastery`.

## Phase 5 — Auth & Security

### 5A: Auth Strategy

| Strategy | Best For | Avoid When |
|---|---|---|
| **Session + Cookie** | Traditional web apps, server-rendered, same-domain | Mobile apps, third-party API consumers, cross-domain |
| **JWT (short-lived + refresh)** | SPAs, mobile apps, stateless APIs | Long-lived tokens needed, token revocation critical |
| **OAuth 2.0 / OIDC** | Third-party login (Google, GitHub), SSO | Simple internal app, no external identity providers |
| **API Keys** | Service-to-service, IoT, simple integrations | User-facing auth, high security requirements |

**Critical Challenge:**
- User wants JWT for long-lived sessions → "JWTs can't be revoked individually without a blacklist, which defeats the purpose of statelessness. For long sessions with logout capability, server-side sessions are more secure."
- User wants to build their own auth → "Auth is security-critical and easy to get wrong. Use NextAuth, Clerk, Auth0, or Supabase Auth. Building your own is a liability unless you're a security company."

### 5B: Validation & Input Sanitization

- **Always use Zod** (or similar) for runtime validation of all inputs
- Never trust client data — validate at API boundary
- Sanitize outputs to prevent XSS (even in JSON APIs)

### 5C: Rate Limiting

- **Always implement** for public APIs
- Use Redis or in-memory for distributed setups
- Different limits for authenticated vs anonymous users

### 5D: Security Checklist

- [ ] HTTPS only (HSTS headers)
- [ ] CORS properly configured (not `*` in production)
- [ ] Input validation on every endpoint
- [ ] SQL injection prevention (ORM or parameterized queries)
- [ ] XSS prevention (sanitize outputs)
- [ ] Rate limiting implemented
- [ ] Secrets not in code (`.env` + `.env.example`)
- [ ] Security headers (Helmet or equivalent)
