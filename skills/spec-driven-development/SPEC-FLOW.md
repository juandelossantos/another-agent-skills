# SPEC-FLOW: Native Pipeline

> **One-page quick reference.** Unique content not in SKILL.md: pipeline diagram, phase table, memory aid, escalation paths.  
> **For detail on any phase → see `SKILL.md`.**

---

## Pipeline Diagram

```
USER PROMPT
    ↓
P0  CONTEXT       → health-check? SPEC.md exists? complexity?
    ↓
P1  RESEARCH      → web search (non-trivial only)
    ↓
P2  DISCOVERY     → assumptions → 6 questions → critical challenge → confirm
    ↓
P3  ARCHITECTURE  → inline architecture-analysis (non-trivial)
    ↓
P4  SPEC.md       → 10-section contract
    ↓
P5  PLAN          → components, dependencies, order, risks
    ↓
P6  TASKS         → discrete chunks with acceptance criteria
    ↓
P7  ENV AUDIT     → verify tools
    ↓
P8  IMPLEMENT     → explicit "yes" → incremental-implementation + TDD
```

---

## Phase Table

| Phase | Key Question | Output | Gate |
|---|---|---|---|---|
| P0 | What are we building? | Complexity level | Cancel if trivial |
| P1 | What does the industry say? | Research findings | Present before P2 |
| P2 | What does the user really want? | Locked discovery | Explicit "yes" |
| P3 | How do we structure it? | Architecture decisions | Document or skip |
| P4 | What is the contract? | SPEC.md | Human review |
| P5 | What order? | Plan | User reviewed |
| P6 | What are the tasks? | Task list | Complete coverage |
| P7 | Do we have the tools? | Verified env | Gaps fixed |
| P8 | Do we build? | Implementation | Explicit "yes" |

---

## Escalation Paths

| Situation | Action |
|---|---|
| Existing code, no health check or >7d | Inline P0 `project-health-check` |
| Non-trivial architecture | Inline P3 `architecture-analysis` |
| Missing dev env | Inline P7 `dev-environment-audit` |
| Multi-module refactor | P8 via `multi-agent-orchestration` |
| User says "just build it" | "5 minutes planning saves hours — ok?" |

---

## Memory Aid

**8 pre-code questions:**
1. Does SPEC.md exist? → Read or create
2. How complex? → Simple / Non-trivial / Complex
3. What assumptions? → List 5+
4. Research done? → If non-trivial
5. Architecture decided? → Documented
6. Plan reviewed? → User saw it
7. Tasks clear? → Per-task acceptance criteria
8. User said "yes"? → Explicit, not "ok"
