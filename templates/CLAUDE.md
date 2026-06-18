# CLAUDE.md — Another Agent Skills (Claude Code Adapter)

This project uses [Another Agent Skills](https://github.com/juandelossantos/another-agent-skills) — a production-grade skill framework for AI coding agents.

## Global Skills Reference

Skills are installed at `~/.config/opencode/skills/` (or `$AGENT_SKILLS_DIR/skills/`). When assigned a task, load the matching skill before writing code:

| Task | Skill |
|---|---|
| Web UI (React/Next.js) | `frontend-web` |
| Mobile app (React Native/Flutter) | `frontend-mobile` |
| Desktop app (Tauri/Electron) | `frontend-desktop` |
| PWA / offline-first | `frontend-pwa` |
| API design / backend | `backend-api-mastery` |
| Spec / requirements | `spec-driven-development` |
| Architecture decisions | `architecture-analysis` |
| Git init / branching | `git-init-and-versioning` |
| CI/CD / deploy | `fullstack-shipping` |
| Code audit | `project-health-check` |
| Environment audit | `dev-environment-audit` |
| Multi-agent orchestration | `multi-agent-orchestration` |

## Core Rules

- **Think Before Coding** — State assumptions, surface tradeoffs, ask before guessing.
- **Simplicity First** — Minimum code. No speculative abstractions.
- **Surgical Changes** — Touch only what the request requires.
- **Goal-Driven Execution** — Define success criteria before implementing. Verify after.
- **No Code Before Contract** — SPEC.md, DESIGN.md, and .gitignore must exist before any file is created.
- **Mutation Approval** — Never commit, push, or merge without explicit user approval.

## Quality Gates

Before marking any task complete:
1. Skill was invoked and followed
2. Required artifacts (specs, tests) exist
3. .gitignore covers the stack
4. No .env or secrets committed
5. Build passes
6. Changes trace to the original request
