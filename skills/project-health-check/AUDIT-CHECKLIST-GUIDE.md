# Audit Checklist Guide

Complete Phase 1 audit checklist for `project-health-check`.

## 1.1 Stack & Versions

Read `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`:

| Check | Standard |
|---|---|
| Node.js | >= 20.9 |
| Next.js | >= 16.1.1 |
| React | >= 19.2 |
| TypeScript | >= 5.7 |
| Tailwind CSS | v4 (CSS `@theme`, no `tailwind.config.ts`) |
| Test framework | Vitest/Jest/Playwright present |
| Linting | ESLint/Prettier/Biome configured |

**Below standard → FAIL with upgrade path.**

## 1.2 Project Structure & Contracts

| Check | Standard |
|---|---|
| `SPEC.md` exists | Documents what + why + boundaries |
| `DESIGN.md` exists | Visual contract with tokens |
| `README.md` exists | Setup, commands, context |
| Test directory exists | `tests/`, `__tests__/`, or `*.test.*` |
| `src/` or `app/` organized | Clear separation of concerns |
| No code in root | Config files only at root |

## 1.3 Code Quality Red Flags

Sample 5-10 representative files:

| Check |
|---|---|
| No `bg-blue-500`, `text-gray-700` (Tailwind generics) |
| No Inter, Roboto, Arial, Space Grotesk as display font |
| No `any` types (except truly unavoidable) |
| No `console.log` in production code |
| No unused imports or variables |
| `prefers-reduced-motion` exists in CSS |
| No `width`/`height`/`margin` animations |
| Components have single responsibility |

## 1.4 Configuration & Tooling

| Check | Standard |
|---|---|
| `.gitignore` sensible | Excludes node_modules, .env, build dirs |
| `.env.example` exists | Documents required env vars |
| CI/CD config exists | GitHub Actions, GitLab CI, etc. |
| Lockfile committed | Reproducible installs |
| No secrets in code | No API keys, tokens, passwords |

## 1.5 Dependencies Audit

Run `npm audit` / `pnpm audit`:

| Check |
|---|---|
| No critical vulnerabilities |
| No deprecated packages |
| No duplicated functionality |

## 1.6 Agent Workflow Compliance

| Check | Standard |
|---|---|
| `AGENTS.md` exists | Skill-driven workflow enabled |
| Evidence of spec-driven work | `SPEC.md` referenced in commits |
| No "agent slop" patterns | Code shows intentional design |
