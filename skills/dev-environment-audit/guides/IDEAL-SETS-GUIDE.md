# Ideal Tool Sets Guide

Phase 3 gap analysis for `dev-environment-audit`.

## Tool Sets by Project Type

| Type | Core | Testing | Design | Deploy | Optional |
|---|---|---|---|---|---|
| **Frontend Web** | Node 20+, npm/pnpm, Git | Playwright MCP, Vitest | Figma/Penpot MCP | Vercel CLI | GitHub Actions MCP |
| **Backend API** | Node/Python/Go, Docker | Vitest/Jest, Postman/Bruno | — | Railway/Fly/AWS CLI | Database MCP |
| **Fullstack** | All frontend + backend | Playwright + Vitest | Figma/Penpot MCP | Vercel + Railway | GitHub Actions MCP |
| **Mobile (RN)** | Node, Expo CLI, Git | Maestro/Jest | Figma MCP | EAS CLI | — |
| **Desktop** | Node/Rust, Tauri/Electron CLI | Playwright | Figma MCP | — | — |
| **Documentation** | Node/Git | — | — | GitBook/Notion MCP | — |

## Priority Levels

| Level | Meaning | Example |
|---|---|---|
| **BLOCKING** | Cannot proceed without | No Node.js for Node project |
| **HIGH** | Strongly recommended | No Playwright for web app |
| **MEDIUM** | Useful, workarounds exist | No Figma MCP |
| **LOW** | Nice to have | Advanced linting |
