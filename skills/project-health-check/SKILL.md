---
name: project-health-check
description: Audit existing projects before new work. Use when entering a codebase for the first time or after a gap. Do NOT use for new projects with no existing code.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: action-allowed
metadata:
  audience: engineers
  workflow: audit-before-build
---

# Project Health Check

**No new code until this completes.**

Diagnose before operating. Audit against engineering standards. Surface misalignments. Force conscious decision: fix first, or proceed with documented risk.

## When to Use

**MANDATORY** when:
1. Project has code AND no `HEALTH-CHECK.md` within 7 days.
2. User asks for audit, health check, or technical debt review.
3. Return after gap >3 days.
4. Before "significant change" (>3 files or new feature).

**Skip when:** Project initialized this session (already compliant). Single-line fix in audited project.

---

## Core Process

### Phase 0 — Detect Context

1. **Check `HEALTH-CHECK.md`:**
   - Within 7 days → Read. Skip to Phase 3 (Re-audit decision).
   - Older than 7 days → Read, then Phase 1.
   - Missing → Phase 1.

2. **Check `AGENTS.md`:** Missing → HIGH risk.

3. **Check `SPEC.md`:** Missing → decisions undocumented.

---

### Phase 1 — Full Audit

**NO CODE WRITTEN.**

→ **See `guides/AUDIT-CHECKLIST-GUIDE.md` for complete 6-category checklist (stack, structure, code quality, config, dependencies, workflow compliance).**

For each check: record `PASS`, `WARN`, `FAIL`.

### Phase 1b — Drift Detection

Inspired by Sub-Zero Skill. Check for drift between what docs claim and what's actually true.

| Drift Type | Check | How |
|---|---|---|
| **Stats drift** | README says "38 skills" but count differs | `ls skills/ \| wc -l` vs README claim |
| **Version drift** | VERSION file != README badge | `cat VERSION` vs grep badge in README |
| **Feature drift** | Docs mention feature X, X doesn't exist | Grep for feature references, verify existence |
| **Command drift** | README says `npm test`, project uses `cargo test` | Check STACK_CONFIG.md vs actual |
| **Link drift** | Docs reference page X, X doesn't exist | Check internal links |

**Output drift as:**
```
⚠️ DRIFT: [description] — expected [X], found [Y]
```

Drift is a WARNING, not a BLOCKER. Document it, let user decide.

---

### Phase 2 — Generate Report

→ **See `guides/REPORT-TEMPLATE-GUIDE.md` for `HEALTH-CHECK.md` template.**

Write report in project root. Include: summary, stack versions, structure, code quality, recommendations (prioritized), decision log.

**Rules:** Honest. No sugarcoat. Link files and line numbers. Distinguish blocking vs non-blocking. One-sentence impact per issue.

---

### Phase 3 — User Decision Gate (BLOCKING)

**FULL STOP.** Present report. Wait explicit decision.

```
🏥 PROJECT HEALTH CHECK COMPLETE

[Summary: X critical, Y warnings, Z passes]

Top issues:
1. [Most critical]
2. [Second most critical]
...

Options:
A. FIX FIRST — Remediation plan, fix criticals before new features.
B. PROCEED WITH CAUTION — Document risks, build without degrading standards further.
C. IGNORE — Proceed as requested, note technical debt increase.

→ What do you choose?
```

**Valid:** "A"/"Fix first" → Phase 4. "B"/"Proceed" → Phase 5. "C"/"Ignore" → Phase 5 with risk.

**Invalid:** Vague "ok" or "sure". Ask again with explicit options.

---

### Phase 4 — Remediation (If A)

1. Create `REMEDIATION.md` with ordered tasks.
2. Invoke `planning-and-task-breakdown`.
3. Execute ONE AT A TIME.
4. Re-run health check after.
5. Then proceed to original request.

**Example tasks:** Upgrade Next.js, migrate `tailwind.config.ts` → CSS `@theme`, replace Inter → distinctive font, add Vitest, create `SPEC.md`.

---

### Phase 5 — Proceed with Risk (If B or C)

1. Append to `HEALTH-CHECK.md`:
   ```markdown
   ## Decision
   - **Chosen:** B
   - **Date:** YYYY-MM-DD
   - **Rationale:** [Reason]
   - **Accepted risks:** [List]
   ```
2. If C: Add WARNING comment at top of new files.
3. Proceed to original request.

---

## Recursive Behavior

**Re-audit every 7 days.** Codebases rot fast.

- New session: Check `HEALTH-CHECK.md` age.
- >7 days: Re-run full audit before significant work.
- <=7 days: Read `HEALTH-CHECK.md`, verify no new criticals.
- After remediation: Re-run immediately.

---

## Examples

**User:** "Add dark mode toggle."

**Agent:**
1. Check `HEALTH-CHECK.md` → 14 days old.
2. Run full audit.
3. Find: Next.js 14, no `DESIGN.md`, hardcoded `bg-gray-900`.
4. Report: 2 critical, 4 warnings.
5. Present A/B/C. User chooses B.
6. Document. Build with CSS custom properties (prep for token migration).

---

## Common Rationalizations

| Excuse | Response |
|---|---|
| "User wants quick fix, don't slow them." | 5-min audit prevents hours debugging degraded codebase. |
| "Audited last week, probably fine." | Codebases rot in days. Re-audit mandatory. |
| "User didn't ask for audit." | Doctor doesn't wait for patient to ask for diagnosis. |
| "No time to fix everything." | Option B exists for reason. |
| "Someone else's mess." | Any code we touch becomes our responsibility. |
| "I'll match existing style." | Matching slop creates more slop. |

---

## Red Flags

- Agent writes code before checking `HEALTH-CHECK.md` age.
- Agent ignores failing checks without user confirmation.
- Agent "fixes" silently without documenting.
- User says "just do it" and agent doesn't present A/B/C.
- Agent audits but doesn't write `HEALTH-CHECK.md`.
- Agent uses bad patterns (`bg-blue-500`) in new code.

---

## Verification

- [ ] `HEALTH-CHECK.md` exists and dated.
- [ ] Existing project: Audit before new code.
- [ ] Returning project: Audit age checked.
- [ ] User explicitly chose A, B, or C.
- [ ] Decision documented in `HEALTH-CHECK.md`.
- [ ] If B/C: Risks listed and accepted.
- [ ] New code doesn't replicate red flags found.
- [ ] Drift detected between docs and reality (stats, version, features, commands, links).

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Audit takes too long | Sample 10 files max per category, note "sampled". |
| `package.json` missing | Adapt checks for Python/Go/Rust. |
| User frustrated by gate | Emphasize: prevents debugging later. |
| Health check always failing | Review if standards fit project maturity. |
| User always chooses C | Explain long-term cost, respect autonomy. |
