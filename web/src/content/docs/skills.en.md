---
title: "Skills"
description: "Detailed reference for the 58 skills: what each one does, when it activates, when to use it and when not to."
lang: "en"
order: 11
section: "concepts"
tldr: "58 skills, each with a trigger and an output contract. They are indexes that load on demand; the using-agent-skills meta-skill routes a task to the right one. You describe the task, not the skill."
---

## Index

- [Foundation](#cat-foundation) · [Ideation](#cat-ideation) · [Process](#cat-process) · [Frontend](#cat-frontend) · [Backend](#cat-backend) · [Testing](#cat-testing) · [Quality](#cat-quality)
- [Design review](#cat-design-review) · [Design skins](#cat-design-skins) · [Git](#cat-git) · [DevOps](#cat-devops) · [Metrics](#cat-metrics) · [Meta](#cat-meta)

## What a skill is

A skill is a small, focused instruction set with an output contract. Each one is a roughly 250-line index that points at deeper guides, loaded only when the task needs them. The lazy-loading architecture keeps the always-on context small while keeping the detail available.

Skills are not a menu you order from. They load when the agent recognizes a matching task, and the skill gate records which ones were consulted.

## How skills activate

You describe what you need. The `using-agent-skills` meta-skill routes the task to one or more skills based on their triggers.

| You say | Skill that loads |
|---|---|
| "Add a login page" | `frontend-web` + `spec-driven-development` + `test-driven-development` |
| "Build a REST API" | `backend-api-mastery` + `api-and-interface-design` |
| "Create a CLI tool" | `cli-tools` + `spec-driven-development` |
| "Review this code" | `code-review-and-quality` |
| "Fix this bug" | `debugging-and-error-recovery` |
| "Write tests" | `test-driven-development` |
| "Deploy to production" | `shipping-and-launch` + `ci-cd-and-automation` |
| "Design a landing page" | `frontend-web` + `critique-skill` + `polish-skill` |

If auto-detection misses, say "load the `test-driven-development` skill" or "use TDD for this."

## Reading the catalog

Each entry below is generated from the skill's own `SKILL.md`. It shows the skill **name**, a one-line **what**, the **triggers** that activate it, what it is **for**, and what it is explicitly **not for**. The count is the number of deeper guides shipped with the skill; the `SKILL.md` link opens the source of truth.

## Skills by phase

- **Define:** `spec-driven-development`, `architecture-analysis`, `interview-me`, `idea-refine`
- **Plan:** `planning-and-task-breakdown`
- **Build:** `incremental-implementation`, `test-driven-development`, `source-driven-development`, `doubt-driven-development`
- **Verify:** `test-driven-development`, `debugging-and-error-recovery`, `browser-testing-with-devtools`
- **Review:** `code-review-and-quality`, `security-and-hardening`, `performance-optimization`
- **Ship:** `git-workflow-and-versioning`, `ci-cd-and-automation`, `shipping-and-launch`

## Meta-skills

Four skills work on the framework itself. `skill-creator` generates a new skill from a workflow description, `skill-improver` reads failing eval cases and proposes improvements, `self-improvement` runs the audit, diagnose, fix, and record loop, and `customize-opencode` edits OpenCode's own configuration.

## The eval for each skill

Every skill ships with an eval that checks it triggers on the right tasks and produces the expected shape. The eval gate runs on changed skills before a commit lands, so a skill that stops working is caught the same way code is.
