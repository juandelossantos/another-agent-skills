# Environment Template Guide

Phase 5 documentation template for `dev-environment-audit`.

## docs/DEV-ENVIRONMENT.md Template

```markdown
# Dev Environment

**Project:** [Name]
**Audited:** YYYY-MM-DD
**Type:** [Frontend / Backend / Fullstack / etc.]

## Required Tools

| Tool | Version | Status | Notes |
|---|---|---|---|
| Node.js | 20.11+ | ✅ | |
| pnpm | 8.15+ | ✅ | |
| Docker | 24.x | ❌ | User declined — remote DB |
| Git | 2.43 | ✅ | |

## MCP Servers

| MCP | Status | Purpose |
|---|---|---|
| Playwright | ✅ | E2E testing |
| Figma | ❌ | Design sync (manual) |
| GitHub | ✅ | PR checks |

## Installed by This Audit

| Date | Tool | Command | Approved By |
|---|---|---|---|
| YYYY-MM-DD | Vercel CLI | `npm i -g vercel` | User |

## Workarounds

- **No Docker:** Using Supabase Cloud.
- **No Figma MCP:** Manual export to `design/approved/`.

## Next Audit

**Due:** YYYY-MM-DD (7 days or after major tool changes)
```

## Rules

- Document installed AND missing tools.
- Record workarounds — don't pretend missing tools don't exist.
- Set "next audit" date (7 days or after major changes).
