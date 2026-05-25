# ADR-002: Safeguards Against Agent Process Violations

> **Status:** Accepted  
> **Date:** 2026-05-25  
> **Deciders:** Agent (self-correcting after incident) + User directive  
> **Affected:** AGENTS.md Rule 0d, Rule 12, SESSION_CONTEXT.md

---

## Context

During execution of Roadmap v11 Phase 2, the agent committed changes without explicit user approval, violating Rule 12 (Mutation Approval Gate) and ADR-001 (Self-review for changes >50 lines).

The agent asked for approval in Phase 1, then skipped it in Phase 2, interpreting "sigamos" (from the previous phase) as blanket approval for all subsequent commits.

**This incident proved that passive rules are insufficient. Active, mechanical safeguards are required.**

---

## Decision

### We will add three layers of protection:

1. **Rule 0d: Pre-Action Checklist** — Mechanical checklist verbalized before any irreversible action.
2. **Rule 12 Strengthening** — Add explicit "MECHANICAL CHECK" step and ban batch approval.
3. **Session-Level Compliance Log** — Visible accountability trail read at session start.

### We will NOT:

- Remove Rule 12 or make it optional.
- Rely on agent memory alone.
- Add complexity that obscures the rules.

---

## Rationale

### Why passive rules fail

Rule 12 existed in AGENTS.md since v10.0. The agent read it, then forgot it after 20+ messages of context. Compaction moved it to "background." The rule was present but not active.

**Analogy:** A speed limit sign is a passive rule. A speed bump is an active safeguard. We need speed bumps.

### Why mechanical checks work

Pilots use checklists not because they don't know the procedures, but because memory is unreliable under cognitive load. The act of verbalizing each item creates an unskippable pause.

By forcing the agent to ask "Did the user say yes for THIS specific action?" we create a speed bump that is harder to ignore than a rule in a file.

### Why batch approval is dangerous

Approval for Phase 1's commit does not imply approval for Phase 2's commit. Each commit is a separate decision with separate risks. Treating "sigamos" as blanket approval enabled the violation.

---

## Consequences

### Positive

- **Mechanical reliability:** The checklist is harder to skip than a remembered rule.
- **User trust:** Explicit per-action approval prevents surprise commits.
- **Self-correction:** The compliance log creates visible accountability.
- **Precedent:** Future process failures can reference this ADR's pattern.

### Negative

- **Slight friction:** Every irreversible action now requires checklist verbalization.
- **Context cost:** Rule 0d adds ~20 lines to AGENTS.md.
- **Cannot prevent all failures:** A determined agent could still fake the checklist. But the barrier is higher.

---

## Implementation

| Safeguard | Where | Status |
|---|---|---|
| Rule 0d (Pre-Action Checklist) | AGENTS.md | Implemented |
| Rule 12 speed bump | AGENTS.md Rule 12 | Implemented |
| Compliance log | `development/SESSION_CONTEXT.md` | Pending |
| Incident report | `development/INCIDENT_001_RULE12_VIOLATION.md` | Written |

---

## Compliance Log Template

To be included in every `SESSION_CONTEXT.md`:

```markdown
## Process Compliance Log

| Timestamp | Rule | Complied? | Action | Notes |
|---|---|---|---|---|
| YYYY-MM-DD HH:MM | Rule 12 | ✅/❌ | [commit name] | [details] |
```

**At session start, the agent MUST read the last 3 entries.** If a ❌ is found, the agent must acknowledge it before proceeding.

---

## Verification

- [ ] Rule 0d exists in AGENTS.md with 5 checkbox items
- [ ] Rule 12 includes "MECHANICAL CHECK" step
- [ ] Rule 12 explicitly bans batch approval
- [ ] SESSION_CONTEXT.md contains compliance log
- [ ] Agent reads compliance log at session start

---

## Related

- ADR-001: Self-review principle (cites this ADR as precedent for process safeguards)
- Rule 0d: Pre-Action Checklist
- Rule 12: Mutation Approval Gate
- `development/INCIDENT_001_RULE12_VIOLATION.md`

---

**Anti-rationalization:** "Adding a checklist is bureaucracy." → No. Adding a checklist is acknowledging that even well-intentioned agents make mistakes. The checklist protects both the agent and the user.
