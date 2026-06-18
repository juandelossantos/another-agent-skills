---
name: context-engineering
description: Optimizes agent context setup. Use when starting a new session, when agent output quality degrades, when switching between tasks, or when you need to configure rules files and context for a project.
version: 1.0.0
license: MIT
compatibility: opencode
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: setup
---

# Context Engineering

Feed agents the right information at the right time. Context is the single biggest lever for agent output quality — too little and the agent hallucinates, too much and it loses focus.

## When to Use

- Starting a new coding session
- Agent output quality is declining
- Switching between parts of a codebase
- Setting up a new project for AI-assisted development

## Context Hierarchy

```
1. Rules Files (AGENTS.md, CLAUDE.md)  ← Always loaded, project-wide
2. Spec / Architecture Docs             ← Loaded per feature/session
3. Relevant Source Files                 ← Loaded per task
4. Error Output / Test Results           ← Loaded per iteration
5. Conversation History                  ← Accumulates, compacts
```

### Level 1: Rules Files

Create a rules file that persists across sessions. This is the highest-leverage context you can provide.

```markdown
# Project: [Name]
## Tech Stack: [list]
## Commands: build, test, lint, dev, typecheck
## Conventions: [project-specific patterns]
## Boundaries: [what never to do]
```

**Equivalent files:** `.cursorrules` (Cursor), `AGENTS.md` (OpenCode/Codex), `.github/copilot-instructions.md` (Copilot)

### Level 2: Specs and Architecture

Load only the relevant section. Effective: "Here's the auth section." Wasteful: "Here's the entire 5000-word spec."

### Level 3: Relevant Source Files

Before editing, read the file. Before implementing a pattern, find an existing example. Trust levels: source code (trusted) → config files (verify) → external docs (untrusted).

### Level 4: Error Output

Feed the specific error, not the entire 500-line output. Effective: "TypeError at UserService.ts:42." Wasteful: full stack trace when only one line matters.

### Level 5: Conversation Management

- Start fresh sessions when switching major features
- Summarize progress when context gets long
- Compact deliberately before critical work

## Context Packing Strategies

### Brain Dump (session start)
```
PROJECT CONTEXT:
- Building [X] using [tech stack]
- Relevant spec: [excerpt]
- Constraints: [list]
- Files involved: [list]
- Patterns: [pointer to example]
```

### Selective Include (per task)
```
TASK: [description]
RELEVANT FILES: [list]
PATTERN: [one example]
CONSTRAINT: [what must not change]
```

## Confusion Management

When context conflicts, STOP. Don't silently pick one interpretation:

```
CONFUSION:
Spec says X, but existing code does Y.

Options:
A) Follow spec → [consequence]
B) Follow existing code → [consequence]
C) Ask → this seems intentional

→ Which approach?
```

When requirements are incomplete: check existing code for precedent. If none exists, stop and ask. Don't invent requirements.

## Continuation Over Recap

After context loss (compaction, session restart, truncation), CONTINUE from last verified state. Don't recap everything.

**The protocol:**
1. Check git status — what's the last committed state?
2. Check PROGRESS_STATUS.md — what's in progress?
3. Ask user: "Where were we?" — don't recap, ask
4. Resume from last verified checkpoint
5. Only recap if user explicitly asks

**Why:** Recap wastes tokens on what's already known. Continuation preserves momentum. After truncation, "where were we?" is cheaper and more accurate than "let me summarize everything."

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Context starvation | Agent invents APIs, ignores conventions | Load rules file + relevant source files |
| Context flooding | Agent loses focus with >5000 lines of non-task context | Aim for <2000 lines of focused context |
| Stale context | Agent references deleted code | Start fresh sessions when context drifts |
| Silent confusion | Agent guesses when it should ask | Surface ambiguity explicitly |
| Recap after restart | Wastes tokens re-explaining known state | Use "Where were we?" — continue, don't recap |

## Rationalizations

| Rationalization | Reality |
|---|---|
| "Agent should figure out conventions" | It can't read your mind. Write a rules file. |
| "I'll correct it when it goes wrong" | Prevention is cheaper than correction. |
| "More context is always better" | Research shows performance degrades with too much. Be selective. |
| "Context window is huge, use it all" | Window size ≠ attention budget. Focused wins. |

## Red Flags

- Agent output doesn't match project conventions
- Agent invents APIs or imports that don't exist
- Agent re-implements existing utilities
- Agent quality degrades as conversation grows
- No rules file in the project

## Verification

- [ ] Rules file exists and covers stack, commands, conventions, boundaries
- [ ] Agent output follows patterns in rules file
- [ ] Context is refreshed when switching major tasks
- [ ] After context loss: continuation, not recap
