---
title: "Overview"
description: "What Another Agent Skills is: 57 composable skills and mechanical enforcement that turn AI coding agents into disciplined senior engineers."
lang: "en"
order: 1
section: "start"
tldr: "Another Agent Skills is a framework of 57 composable skills plus mechanical enforcement (L1 local hooks, L2 a required remote gates check, L3 CODEOWNERS review) that turns AI coding agents into disciplined senior engineers."
---

## What it is

Another Agent Skills is a framework of 57 composable skills that turn AI coding agents into disciplined senior engineers. Most skill libraries sell capability. This one sells discipline you can verify: every task follows a six-phase lifecycle, and the parts that matter are enforced by mechanisms, not by prompts.

The core idea is simple. A rule that lives only in a file is a suggestion. A rule that lives in a layer is a gate. The framework ships the layers: local git hooks for fast feedback, a required remote `gates` check for authority, and `CODEOWNERS` review for the gate configuration itself.

## The thesis

- Capable models still skip tests, review, and context. The gap is process, not intelligence.
- Skills map to a lifecycle: Define, Plan, Build, Verify, Review, Ship. No phase is optional.
- Enforcement has three layers. A code change with no matching test is blocked, locally and remotely.
- The agent never runs `git commit` or `git push`. The human does.

## At a glance

| Fact | Value |
|---|---|
| Skills | 57, mapped to the six-phase lifecycle |
| Guides | 74 |
| Harness components | 6 |
| Enforcement | L1 local hooks, L2 required `gates` check, L3 `CODEOWNERS` |
| License | MIT |
| Install channels | `git clone` and pinned `curl` bootstrap (live); npm wrapper and Homebrew (coming soon) |
| Agents | OpenCode first, portable to Claude Code, Cursor, Codex, Gemini CLI, Copilot, and any agent that reads `AGENTS.md` |

## Where to go next

- [Getting started](getting-started/) walks through install and your first project.
- [Lifecycle](lifecycle/) explains the six phases and their exit criteria.
- [Enforcement](enforcement/) shows the L1/L2/L3 model with real output.
- [Branch protection](branch-protection/) turns on the remote authority layer.

## Guides

Five short walkthroughs, each with copy-paste commands and the output you should see:

- [Your first gated commit](first-gated-commit/) — watch the local gate block a code change with no test.
- [Wire the remote enforcement](wire-remote-enforcement/) — make `gates` a required check.
- [Start without git, add it later](no-git-and-later-git/) — grow the layers as they appear.
- [Migrate a legacy project](migrate-a-legacy-project/) — `aas doctor` → `--dry-run` → `--repair`.
- [Move to another machine](move-to-another-machine/) — reinstall the same version and confirm.

The [FAQ](faq/) answers the common questions directly and cites the facts.

> The framework works offline after install, has no external runtime dependencies, and ships no trackers.
