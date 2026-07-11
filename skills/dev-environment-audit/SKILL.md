---
name: dev-environment-audit
description: Audit development environment (CLI tools, runtimes) before code. Proposes installations with justification. Use when starting a project. Do NOT use for running existing environments.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: action-allowed
metadata:
  audience: engineers
  workflow: audit-gap-install-document
---

# Dev Environment Audit

**Right tools make good code possible. Wrong tools make it painful.**

Audit agent capabilities (MCPs), user CLI tools, project runtime requirements. Propose precise installations with justification — never "install everything just in case."

## When to Use

**MANDATORY** when:
- Starting new project (after spec, before build)
- User asks "what do I need to install" or "setup environment"
- Before build if `docs/DEV-ENVIRONMENT.md` missing or outdated
- Project requires testing, deployment, or design tools

**Invoked by:** `spec-driven-development` Phase 7, `shipping-and-launch`, `frontend-*` (if MCPs absent)

## When NOT to Use

- Fresh `DEV-ENVIRONMENT.md` (<7 days) with all tools verified (skip audit)
- Pure documentation task with no tooling needs

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Development environment audit + configuration | `docs/DEV-ENVIRONMENT.md` + installed tool versions | `docs/DEV-ENVIRONMENT.md` + user's machine | BLOCKING tools installed or have approved workaround, user explicitly approved every installation, MCP status documented, CLI versions recorded (or "NOT FOUND"), workarounds described, next audit date set, doc dated and <7 days old |

---

## Core Process

### Phase 0 — Context Assessment

1. **Check `docs/DEV-ENVIRONMENT.md`:**
   - <7 days → Read. Verify tools still available.
   - >7 days → Read, re-audit.
   - Missing → Full audit.

2. **Determine project type:**
   - Read `SPEC.md` Tech Stack and Testing Strategy.
   - No `SPEC.md` → Infer from conversation.

3. **Assess complexity:**
   - Simple (single-page, no backend) → Lightweight audit
   - Non-trivial (multi-page, backend, tests) → Full audit
   - Complex (multi-platform, enterprise) → Extended + security/compliance

---

### Phase 1 — Discovery

If project type unclear, ask:
1. **Type**: Web app, API, mobile, desktop, or CLI?
2. **Testing**: Unit, integration, E2E, visual regression?
3. **Design workflow**: Figma, Penpot, or similar?
4. **Deploy target**: Vercel, AWS, GCP, self-hosted?
5. **Team tools**: GitHub Actions, docs generators, collaboration?

Only after confirmation, proceed to Phase 2.

---

### Phase 2 — Audit Installed Tools

→ **See `guides/AUDIT-CHECKLIST-GUIDE.md` for complete 3-category checklist (MCPs, CLI tools, project-specific).**

Summary: Check MCP servers, CLI tools (`--version`), project files (`package.json`, `Dockerfile`, etc.).

---

### Phase 3 — Gap Analysis

→ **See `guides/IDEAL-SETS-GUIDE.md` for tool sets by project type and priority levels.**

Compare installed vs "Ideal Set" for this project type. Determine priority per missing tool: BLOCKING, HIGH, MEDIUM, LOW.

---

### Phase 4 — Recommend & Install (BLOCKING)

→ **See `guides/INSTALL-GUIDE.md` for presentation format and installation rules.**

**Present findings. Don't install without explicit confirmation.**

- Only install what user approves.
- If "none" → document, proceed with workarounds.
- If BLOCKING missing and user refuses → warn strongly.
- Provide exact install commands.

---

### Phase 5 — Document

→ **See `guides/ENV-TEMPLATE-GUIDE.md` for `docs/DEV-ENVIRONMENT.md` template.**

Create/update doc with tools, MCPs, installed-by-audit log, workarounds, next audit date.

**Rules:** Document installed AND missing. Record workarounds. Set next audit (7 days or after major changes).

---

## Example

**Context:** SPEC.md indicates Next.js + PostgreSQL + Prisma + Vercel.

**Agent:**
1. Phase 0: No `DEV-ENVIRONMENT.md`.
2. Phase 1: Not needed — type clear from SPEC.md.
3. Phase 2: MCPs: browser-testing ✅, design-integration ❌, repo-management ✅. CLI: Node ✅, pnpm ✅, Git ✅, Docker ❌, Vercel ❌.
4. Phase 3: BLOCKING: Docker (local PostgreSQL). HIGH: Vercel CLI, Figma MCP.
5. Phase 4: Present. User approves Docker + Vercel. Declines Figma.
6. Phase 5: Create `docs/DEV-ENVIRONMENT.md` with tools, workarounds, next audit.

---

## Common Rationalizations

| Excuse | Response |
|---|---|
| "Install everything to be safe." | Bloat slows machines. Install only what project needs. |
| "User didn't ask for audit." | Missing tools cause cryptic errors later. Proactive > reactive. |
| "They probably have Docker." | Assume nothing. Check. |
| "MCPs are optional." | MCPs unlock testing superpowers. Without them, agent is blind. |
| "I'll install silently." | Never install without consent. User owns their machine. |
| "They'll figure it out." | "Figuring out" wastes hours. 2-min audit saves debugging time. |

---

## Red Flags

- Assumes tools exist without checking.
- Installs without user confirmation.
- Skips audit because "probably fine."
- Doesn't document missing tools or workarounds.
- Recommends unrelated tools (K8s for landing page).
- Doesn't create/update `docs/DEV-ENVIRONMENT.md`.

---

## Verification

- [ ] `docs/DEV-ENVIRONMENT.md` exists and dated.
- [ ] BLOCKING tools installed or have approved workaround.
- [ ] User explicitly approved every installation.
- [ ] MCP status documented.
- [ ] CLI versions recorded (or "NOT FOUND" noted).
- [ ] Workarounds described.
- [ ] Next audit date set.
