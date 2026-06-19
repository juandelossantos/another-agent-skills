# Audit Checklist Guide

Phase 2 tool audit for `dev-environment-audit`.

## 2A: MCP Servers (Agent Capabilities)

Read `~/.config/opencode/opencode.json`.

**Check for** (examples — exact names depend on agent config):
- Browser testing (playwright, browserbase, or similar)
- Documentation context (context7, or similar)
- Design system integration (figma, penpot, or similar)
- Repository/CI management (github, gitlab, or similar)
- Documentation access (gitbook, notion, or similar)

Record: present, missing, enabled/disabled.

## 2B: CLI Tools (User Machine)

Check `--version` or equivalent:

**Runtime:** `node`, `npm`/`pnpm`/`yarn`, `python`, `go`, `rust`
**Version Control:** `git`, `gh`
**Containerization:** `docker`, `docker-compose`
**Cloud CLIs:** `vercel`, `aws`, `gcloud`, `flyctl`, `railway`
**Database:** `psql`, `mysql`, `mongosh`
**Testing:** `vitest`, `jest`, `playwright`
**Lint/Format:** `eslint`, `prettier`, `biome`
**Build:** `tsc`, `vite`, `webpack`

Record: version installed or "NOT FOUND".

## 2C: Project-Specific Tools

Check project directory:
- `package.json` scripts
- `Dockerfile` or `docker-compose.yml`
- `.github/workflows/`
- `prisma/schema.prisma`
- `supabase/config.toml`
