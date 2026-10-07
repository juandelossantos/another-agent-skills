---
title: "FAQ"
description: "Direct answers about installing, upgrading, enforcement, agents, and what the framework does and does not guarantee."
lang: "en"
order: 30
section: "help"
tldr: "Short, citable answers: one install per machine, POSIX-first with Windows via Git Bash, local hooks are feedback and the remote gates check is authority, and no system can fully prevent an agent from acting against protocol."
---

## What is Another Agent Skills?

A framework of 57 composable skills that turn AI coding agents into disciplined senior engineers. It adds mechanical enforcement, not just prompts. Skills follow a six-phase lifecycle: Define, Plan, Build, Verify, Review, Ship.

## Do I install it per project or once?

Once per machine. The installer places the skills globally, and any project can use them without duplicating the files. You run `init-agents` in each project to activate the framework there.

## Does it work on Windows, macOS, and Linux?

Yes. The installer is POSIX-first and works on Linux and macOS. On Windows, use Git for Windows (Git Bash); `install.ps1` provides Claude Code parity. The npm wrapper is the portable path for Node users.

## A teammate clones my project and does not have the framework. Does it break?

No. The project still runs. Your teammate can install the framework when they want it, and the remote `gates` check enforces the rules for everyone on the repository regardless of their local setup.

## I inherited or migrated a project that used the framework. How do I repair it?

Run `aas doctor`, then `init-agents --dry-run`, then `init-agents --repair`. The repair merges without losing data.

## I changed machines. What do I do?

Install the same version with `aas install`, then run `aas doctor` to confirm the environment.

## There is a new release. Do I have to update the project?

No. A non-blocking drift advisory appears in `pre-commit` and `doctor` when the installed version differs from the project's pinned version. When you are ready, run `aas upgrade`, then `init-agents --dry-run` and `init-agents --repair`.

## What are L1, L2, and L3, and what is actually enforced?

L1 is local git hooks for fast, advisory feedback. L2 is a required remote `gates` check that the committer cannot skip. L3 is `CODEOWNERS` review for sensitive paths. L2 and L3 require GitHub. A code change with no matching test is blocked, locally and remotely.

## Which git and GitHub setups are supported?

Four flows, and the framework works in all of them. **No git:** convention only (rules, skills, `AGENTS.md`); run `git init` and re-run `init-agents` to add the local hooks. **Local git:** L1 hooks only, no remote gate. **Git and GitHub:** full L1, L2, and L3. **Git later:** the layers grow as they appear; re-run `init-agents` after `git init` and after adding the remote, because it installs each layer conditionally. Step-by-step: [Start without git, add it later](../no-git-and-later-git/) and [Wire the remote enforcement](../wire-remote-enforcement/).

## Where are the step-by-step guides?

The Tutorials section walks through the common jobs with copy-paste commands and the output you should see: your first gated commit, wiring the remote enforcement, starting without git, migrating a legacy project, and moving to another machine. See [Your first gated commit](../first-gated-commit/).

## Which agents does it support?

Designed for OpenCode. Portable to Claude Code, Cursor, Codex, Gemini CLI, GitHub Copilot, Windsurf, Aider, Kiro, Zed, and any agent that reads `AGENTS.md`. The installer detects the agent and wires the matching skills and hooks.

## Is it free?

Yes. MIT License, open source, no subscriptions and no paid tiers. The installer, the skills, and the enforcement are all free.

## Can an agent still break the rules?

Yes. The hooks make it harder, not impossible. An agent could misread an ambiguous approval or act outside protocol. These gates create friction, not guarantees. The human stays in the loop, and the human stays alert.

## What is the Harness?

The Harness is everything around the model that turns raw intelligence into reliable output: instructions, tools, sandboxes, orchestration, guardrails, and observability. Agent equals Model plus Harness. Most agent failures are configuration failures.

## How do I install it?

Clone and run `install.sh`, or use the pinned `curl` bootstrap from the latest release. Git, curl and npm are available today. Then run `init-agents` in any project. See [Getting started](../getting-started/).
