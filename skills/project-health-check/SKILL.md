---
name: project-health-check
description: >
  Audit existing projects for compliance with modern engineering standards before
  any new work begins. Use when entering a project that already contains code,
  configuration files, or an established repository. Triggers on: any project with
  existing code, returning to a project after time away, or when the user asks
  "check project health", "audit codebase", "what needs fixing", "technical debt".
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  workflow: audit-before-build
---

# Project Health Check

**No new code is written until this check completes.**

Entering a project with existing code is like entering an emergency room. Before
operating, you diagnose. This skill audits the codebase against our engineering
standards, surfaces misalignments, and forces a conscious decision: fix the
foundation first, or proceed with documented risk.

## When to Use

**MANDATORY** — Run this skill when:

1. You open a project that already has code AND does not have a recent `HEALTH-CHECK.md` (within 7 days).
2. The user explicitly asks for an audit, health check, or technical debt review.
3. You return to a project after a gap of more than 3 days.
4. Before starting any "significant change" (touches >3 files or adds a new feature).

**When NOT to use:**
- The project was initialized by our skills in this session (already compliant).
- You're making a single-line fix in an already-audited project.

---

## Core Process

### Phase 0 — Detect Context

First, determine the project state:

1. **Check for `HEALTH-CHECK.md`** in the project root.
   - If it exists and is dated within 7 days → Read it. Skip to Phase 3 (Re-audit decision).
   - If it exists but is older than 7 days → Read it, then run Phase 1 (Full audit).
   - If it does NOT exist → Run Phase 1 (Full audit).

2. **Check for `AGENTS.md`**:
   - If missing → This project has never been initialized with our workflow. Risk is HIGH.

3. **Check for `SPEC.md`**:
   - If missing → No specification exists. Engineering decisions may be undocumented.

---

### Phase 1 — Full Audit (MANDATORY)

**NO CODE IS WRITTEN DURING THIS PHASE.**

Scan the project systematically. For each check, record: `PASS`, `WARN`, or `FAIL`.

#### 1.1 Stack & Versions

Read `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, or equivalent:

| Check | Standard | Status |
|---|---|---|
| Node.js version | >= 20.9 | ? |
| Next.js version | >= 16.1.1 | ? |
| React version | >= 19.2 | ? |
| TypeScript version | >= 5.7 | ? |
| Tailwind CSS | v4 (CSS `@theme`, no `tailwind.config.ts`) | ? |
| Test framework | Vitest/Jest/Playwright present | ? |
| Linting | ESLint/Prettier/Biome configured | ? |

**If any version is below standard:** Record FAIL with recommended upgrade path.

#### 1.2 Project Structure & Contracts

| Check | Standard | Status |
|---|---|---|
| `SPEC.md` exists | Documents what + why + boundaries | ? |
| `DESIGN.md` exists | Visual contract with tokens | ? |
| `README.md` exists | Setup, commands, context | ? |
| Test directory exists | `tests/`, `__tests__/`, or `*.test.*` files | ? |
| `src/` or `app/` organized | Clear separation of concerns | ? |
| No code in root | Config files only at root | ? |

#### 1.3 Code Quality Red Flags

Scan source files (sample 5-10 representative files):

| Check | Status |
|---|---|
| No `bg-blue-500`, `text-gray-700`, `bg-red-500` (Tailwind generics) | ? |
| No Inter, Roboto, Arial, Space Grotesk as display font | ? |
| No `any` types in TypeScript (except truly unavoidable) | ? |
| No `console.log` in production code | ? |
| No unused imports or variables | ? |
| `prefers-reduced-motion` exists in CSS | ? |
| No `width`/`height`/`margin` animations | ? |
| Components have single responsibility | ? |

#### 1.4 Configuration & Tooling

| Check | Standard | Status |
|---|---|---|
| `.gitignore` exists and is sensible | Excludes node_modules, .env, build dirs | ? |
| `.env.example` exists | Documents required environment variables | ? |
| CI/CD config exists | GitHub Actions, GitLab CI, etc. | ? |
| `package-lock.json` or equivalent committed | Reproducible installs | ? |
| No secrets in code | No API keys, tokens, passwords | ? |

#### 1.5 Dependencies Audit

Run or simulate `npm audit` / `pnpm audit`:

| Check | Status |
|---|---|
| No critical vulnerabilities | ? |
| No deprecated packages | ? |
| No duplicated functionality | ? |

#### 1.6 Agent Workflow Compliance

| Check | Standard | Status |
|---|---|---|
| `AGENTS.md` exists | Skill-driven workflow enabled | ? |
| Evidence of spec-driven work | `SPEC.md` referenced in commits | ? |
| No "agent slop" patterns | Code shows intentional design | ? |

---

### Phase 2 — Generate Report

Write `HEALTH-CHECK.md` in the project root. This file is the audit artifact.

```markdown
# Project Health Check

**Date:** YYYY-MM-DD
**Auditor:** OpenCode Agent
**Status:** ⚠️ REQUIRES ATTENTION / ✅ HEALTHY

## Summary

- **Critical Issues:** N
- **Warnings:** N
- **Passes:** N
- **Overall:** HEALTHY / DEGRADED / CRITICAL

---

## Stack & Versions

| Check | Current | Required | Status |
|---|---|---|---|
| Node.js | 18.x | >= 20.9 | 🔴 FAIL |
| Next.js | 14.2 | >= 16.1.1 | 🔴 FAIL |
| ... | ... | ... | ... |

**Recommendation:** Upgrade Node.js and Next.js before any new features.

---

## Project Structure

| Check | Status | Notes |
|---|---|---|
| SPEC.md | 🔴 Missing | No specification exists |
| DESIGN.md | 🔴 Missing | No visual contract |
| Tests | ⚠️ Partial | Only 2 test files found |
| ... | ... | ... |

---

## Code Quality

| Check | Status | Files Affected |
|---|---|---|
| No Tailwind generics | 🔴 FAIL | `src/components/Button.tsx` uses `bg-blue-500` |
| Distinctive fonts | 🔴 FAIL | `layout.tsx` uses Inter |
| ... | ... | ... |

---

## Recommendations (Priority Order)

1. **🔴 CRITICAL:** Upgrade Next.js 14 → 16 (breaking changes likely)
2. **🔴 CRITICAL:** Create `SPEC.md` for all future work
3. **⚠️ WARN:** Replace `bg-blue-500` with design tokens
4. **⚠️ WARN:** Add test coverage for `src/lib/` utils
5. **💡 NICE:** Add `CONTRIBUTING.md`

---

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| YYYY-MM-DD | User chose to proceed without upgrades | Time pressure for demo |

```

**Rules for the report:**
- Be honest. Do not sugarcoat.
- Link to specific files and line numbers when possible.
- Distinguish between "must fix" (blocking) and "should fix" (non-blocking).
- Include a one-sentence impact for each issue: "This means..."

---

### Phase 3 — User Decision Gate (BLOCKING)

**THIS IS A FULL STOP.** Present the report to the user and wait for explicit decision.

**Presentation format:**

```
🏥 PROJECT HEALTH CHECK COMPLETE

I've audited your project against our engineering standards.
Here's what I found:

[Summary: X critical, Y warnings, Z passes]

Top issues:
1. [Most critical issue and why it matters]
2. [Second most critical]
...

You have three options:

A. **FIX FIRST** — I create a remediation plan and we fix the critical issues before any new features.
B. **PROCEED WITH CAUTION** — I document the risks and we build the new feature, but I will NOT degrade standards further.
C. **IGNORE** — I proceed as requested, but I must note that this increases technical debt.

→ What do you choose?
```

**Valid responses:**
- "A" / "Fix first" / "Arreglemos primero" → Go to Phase 4
- "B" / "Proceed with caution" / "Continuemos" → Go to Phase 5
- "C" / "Ignore" / "Solo haz la feature" → Go to Phase 5 with risk documented

**Invalid responses (do not accept):**
- Vague "ok" or "sure" → Ask again with explicit options.
- "Just do it" without A/B/C → Explain that a conscious choice is required.

---

### Phase 4 — Remediation Plan (If user chooses A)

1. Create a `REMEDIATION.md` with ordered tasks.
2. Invoke `planning-and-task-breakdown` to break tasks into implementable chunks.
3. Execute remediation tasks ONE AT A TIME.
4. Re-run health check after remediation to verify.
5. Only then proceed to the user's original request.

**Example remediation tasks:**
- Upgrade Next.js 14 → 16 (handle breaking changes)
- Migrate `tailwind.config.ts` → CSS `@theme`
- Replace Inter → distinctive font pair
- Add Vitest + write first tests
- Create `SPEC.md` from existing codebase analysis

---

### Phase 5 — Proceed with Risk Documented (If user chooses B or C)

1. Append to `HEALTH-CHECK.md`:
   ```markdown
   ## Decision
   - **Chosen:** B (Proceed with caution)
   - **Date:** YYYY-MM-DD
   - **Rationale:** [User's reason]
   - **Accepted risks:** [List of risks being accepted]
   ```
2. If choice was C (Ignore), add a WARNING comment at the top of any new files:
   ```
   // WARNING: This file was created in a degraded codebase.
   // Health check on YYYY-MM-DD identified X critical issues.
   // See HEALTH-CHECK.md for details.
   ```
3. Proceed to the user's original request.

---

## Recursive Behavior

This skill is **recursively enforced**:

- Every new session in this project: Check `HEALTH-CHECK.md` age.
- If >7 days old: Re-run full audit before any significant work.
- If <=7 days old: Read `HEALTH-CHECK.md`, verify no new critical issues emerged.
- After any remediation: Re-run immediately to verify fixes.

**Why 7 days?** Codebases rot quickly. A week is enough time for:
- New vulnerabilities in dependencies
- "Quick fixes" that introduced slop
- Drift from agreed standards

---

## Examples

### Example 1: New Agent Session in Existing Project

User: "Add a dark mode toggle to my dashboard."

Agent:
1. Check `HEALTH-CHECK.md` → Dated 14 days ago.
2. Run full audit.
3. Find: Next.js 14, no `DESIGN.md`, uses `bg-gray-900` for dark mode (hardcoded).
4. Generate report: 2 critical, 4 warnings.
5. Present options A/B/C to user.
6. User chooses B (Proceed with caution).
7. Document decision in `HEALTH-CHECK.md`.
8. Build dark mode toggle using CSS custom properties (preparing for future token migration).

### Example 2: Project with Recent Health Check

User: "Fix this button alignment bug."

Agent:
1. Check `HEALTH-CHECK.md` → Dated 2 days ago, status: ✅ HEALTHY.
2. Skip audit.
3. Fix button alignment.

### Example 3: User Requests Audit Explicitly

User: "Check the health of my codebase."

Agent:
1. Run full audit regardless of `HEALTH-CHECK.md` age.
2. Generate fresh report.
3. Present findings.
4. Ask if user wants remediation plan.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "The user just wants a quick fix, don't slow them down." | A 5-minute audit prevents hours of debugging in a degraded codebase. |
| "I audited this last week, it's probably fine." | Codebases rot in days. Re-audit is mandatory. |
| "The user didn't ask for an audit." | A doctor doesn't wait for the patient to ask for a diagnosis. |
| "There's no time to fix everything." | That's why we offer Option B (proceed with caution), not just A. |
| "This is someone else's mess, not my problem." | Any code we touch becomes our responsibility. |
| "I'll just match the existing style." | Matching slop creates more slop. Document the deviation. |

---

## Red Flags

Watch for these signals that this skill is being violated:
- The agent writes code before checking `HEALTH-CHECK.md` age.
- The agent ignores failing checks and proceeds without user confirmation.
- The agent "fixes" issues silently without documenting them.
- The user says "just do it" and the agent doesn't present options A/B/C.
- The agent audits but doesn't write the `HEALTH-CHECK.md` file.
- The agent uses existing bad patterns (e.g., `bg-blue-500`) in new code.

---

## Verification

Evidence that this skill was followed:
- [ ] `HEALTH-CHECK.md` exists and is dated.
- [ ] If existing project: Audit was run before new code.
- [ ] If returning project: Audit age was checked.
- [ ] User explicitly chose A, B, or C.
- [ ] Decision is documented in `HEALTH-CHECK.md`.
- [ ] If B/C: Risks are listed and accepted.
- [ ] New code does not replicate red flags found in audit.

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| Audit takes too long | Large codebase | Sample 10 files max per category, note "sampled" |
| `package.json` missing | Not a Node.js project | Adapt checks for Python/Go/Rust/etc. |
| User frustrated by "another gate" | Perceived slowdown | Emphasize: "This prevents debugging later" |
| Health check is always failing | Standards too strict? | Review if standards are appropriate for project maturity |
| User always chooses C (Ignore) | Trust issue | Explain long-term cost, but respect autonomy |
