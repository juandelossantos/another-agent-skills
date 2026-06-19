# Install Guide

Phase 4 installation patterns for `dev-environment-audit`.

## Presentation Format

```
🔧 DEV ENVIRONMENT AUDIT

Project type: [Frontend / Backend / Fullstack / etc.]

INSTALLED ✅:
- Node.js 20.11 ✅
- Git 2.43 ✅
- pnpm 8.15 ✅
- Playwright MCP ✅

MISSING ❌:
🔴 BLOCKING:
- Docker (project has Dockerfile, needed for local DB)

🟠 HIGH:
- Figma MCP (design workflow — manual export workaround)
- Vercel CLI (deployment target per SPEC.md)

🟡 MEDIUM:
- GitHub Actions MCP (CI/CD visibility)

RECOMMENDED ACTIONS:
1. Install Docker Desktop
2. Configure Figma MCP for design token sync
3. Install Vercel CLI for preview deployments

→ Which install now?
→ Reply with numbers (e.g., "1, 2") or "all" or "none".
```

## Installation Rules

- Only install what user explicitly approves.
- If "none" → document decision, proceed with workarounds.
- If BLOCKING missing and user refuses → warn strongly:
  ```
  ⚠️ Docker is BLOCKING. Project includes Dockerfile.
  Without it, full dev environment won't run locally.
  ```
- Provide exact commands:
  ```bash
  brew install --cask docker  # macOS
  npm i -g vercel             # Vercel CLI
  ```
