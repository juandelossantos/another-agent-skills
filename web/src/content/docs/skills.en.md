---
title: "Skills"
description: "How the 57 skills are organized, how they load, and how they map to the six-phase lifecycle."
lang: "en"
order: 11
section: "concepts"
tldr: "57 curated skills are mapped to the lifecycle and load on demand when the agent detects a matching task. You describe what you need; you do not call skills by hand."
---

## What a skill is

A skill is a small, focused instruction set with an output contract. Each one is a roughly 250-line index that points at deeper guides, loaded only when the task needs them. The lazy-loading architecture keeps the always-on context small while keeping the detail available.

Skills are not a menu you order from. They load when the agent recognizes a matching task, and the skill gate records which ones were consulted.

## How skills activate

You describe what you need. The agent matches the task to one or more skills.

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

## Categories

| Category | Examples |
|---|---|
| Foundation | `engineering-fundamentals`, `context-engineering`, `user-onboarding` |
| Frontend | `frontend-web`, `frontend-mobile`, `frontend-desktop`, `frontend-pwa` |
| Backend | `backend-api-mastery`, `api-and-interface-design`, `cli-tools` |
| Process | `spec-driven-development`, `planning-and-task-breakdown`, `incremental-implementation`, `multi-agent-orchestration` |
| Quality | `code-review-and-quality`, `test-driven-development`, `security-and-hardening`, `performance-optimization`, `code-simplification` |
| Design | `critique-skill`, `audit-skill`, `polish-skill`, `typeset-skill`, `adapt-skill`, `delight-skill` |
| DevOps | `ci-cd-and-automation`, `shipping-and-launch`, `fullstack-shipping` |
| Meta | `skill-creator`, `skill-improver`, `self-improvement` |

## Skills by phase

- **Define:** `spec-driven-development`, `architecture-analysis`, `interview-me`, `idea-refine`
- **Plan:** `planning-and-task-breakdown`
- **Build:** `incremental-implementation`, `test-driven-development`, `source-driven-development`, `doubt-driven-development`
- **Verify:** `test-driven-development`, `debugging-and-error-recovery`, `browser-testing-with-devtools`
- **Review:** `code-review-and-quality`, `security-and-hardening`, `performance-optimization`
- **Ship:** `git-workflow-and-versioning`, `ci-cd-and-automation`, `shipping-and-launch`

## Meta-skills

Three skills work on the framework itself. `skill-creator` generates a new skill from a workflow description, `skill-improver` reads failing eval cases and proposes improvements, and `self-improvement` runs the audit, diagnose, fix, and record loop.

## The eval for each skill

Every skill ships with an eval that checks it triggers on the right tasks and produces the expected shape. The eval gate runs on changed skills before a commit lands, so a skill that stops working is caught the same way code is.

> 57 skills, 74 guides, 6 harness components, and an eval for each.
