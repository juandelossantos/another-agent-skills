# Quick Start Guide

You installed 57 skills and ran `init-agents`. Now what? This guide shows you how to work with your agent effectively using the skills you have.

> **Full interactive version:** [`docs/quickstart-guide.html`](docs/quickstart-guide.html)

---

## Your First Session

After `init-agents`, describe what you want to build. The agent auto-detects which skills to load.

1. **You describe the task** — "Build a login page with email and password." The agent matches this to `frontend-web`, `security-and-hardening`, and `test-driven-development`.
2. **Agent loads skills** — The skill gate logs which skills were consulted. You'll see this in the pre-commit output.
3. **Agent writes SPEC.md** — The spec defines scope, stack, acceptance criteria, and boundaries.
4. **You review the plan** — A DECISION POINT appears: "Here's the spec. Shall I proceed?" Say "yes" or request changes.
5. **Agent builds incrementally** — One slice at a time. Each slice includes code + tests.
6. **Tests run automatically** — Pre-commit Gate 14 runs before every commit. If tests fail, the commit blocks.
7. **Agent presents commit decision** — Type "yes commit" to approve.

## How Skills Activate

Skills load automatically when the agent detects a matching task. You don't call skills — you describe what you need.

| You Say | Skill That Loads |
|---|---|
| "Add a login page" | `frontend-web` + `spec-driven-development` + `test-driven-development` |
| "Build a REST API" | `backend-api-mastery` + `api-and-interface-design` |
| "Review this code" | `code-review-and-quality` |
| "Fix this bug" | `debugging-and-error-recovery` |

**Pro tip:** If auto-detection misses, say "load the [skill-name] skill" or "use TDD for this."

## The 6 Phases from Your Side

| Phase | Agent Does | You Do |
|---|---|---|
| **DEFINE** | Writes SPEC.md. Asks discovery questions. | Read the spec. Say "yes" to proceed. |
| **PLAN** | Breaks work into tasks with acceptance criteria. | Review and confirm. |
| **BUILD** | Implements one slice. Writes tests. | Review each increment. |
| **VERIFY** | Runs test suite. Checks gates. | Fix if a gate blocks. |
| **REVIEW** | Reviews its own code. | Read the review. Approve or request changes. |
| **SHIP** | Commits. Pushes. CI runs. | Type "yes commit" when you see the DECISION POINT. |

## Guardian Pattern — Your Role in Quality

Before every mutation, the agent presents a DECISION POINT block. This is your opportunity to review before giving consent.

**Valid responses:** "yes", "yes commit", "sí", "proceed", "adelante", "let's go"
**Invalid responses:** "ok", "sure", "mmhm", "continue"

**Plan ≠ Commit:** Approving the plan does NOT approve the commit. Each mutation is a separate decision.
**You can reject:** Say "no" or "change X" to send it back.

## Tips for Better Results

- **Be specific about your stack.** "Build a React app using Next.js 14 with TypeScript" gets better results.
- **Use skill names when it matters.** "Load the test-driven-development skill" forces TDD.
- **Read DECISION POINTs carefully.** If it sounds wrong, say "no" or "change X."
- **If the agent loads the wrong skill**, say "load the [correct-skill] skill instead."
- **Run tests before creating a PR.** Pre-commit Gate 14 catches failures locally.
