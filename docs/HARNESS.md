# Harness: The System That Builds Software

> *"A raw model is not an agent. It becomes one once a harness gives it state, tool execution, feedback loops, and enforceable constraints."*
> — Osmani, Saboo & Kartakis, *The New SDLC With Vibe Coding*, May 2026

## Agent = Model + Harness

The model is the reasoning engine. The harness is everything around it that turns raw intelligence into reliable output.

When an agent does something wrong, the instinct is to blame the model. More often, the failure traces back to a missing tool, a vague rule, an absent guardrail, or a context window stuffed with noise. **Most agent failures, examined honestly, are harness failures.**

This project is a complete open-source Harness.

---

## The Six Components

| Component | What It Is | In This Project |
|---|---|---|
| **1. Instructions & Rules** | Who the agent is, what it cares about, what it must never do | `AGENTS.md`, `AGENTS-EXTENDED.md`, `SOUL.md`, `STEERING-GUIDE.md`, `STACK_CONFIG.md` |
| **2. Tools** | Task-specific capabilities loaded on demand | 57 skills in `skills/`, 54 guides, MCP servers, shell scripts |
| **3. Sandboxes & Execution** | Where the agent's code actually runs | Terminal, git workspace, CI environment, Docker |
| **4. Orchestration** | When each tool fires, how agents coordinate | `skill-gate.sh`, `init-agents.sh`, `multi-agent-orchestration` skill, `.sessionrc` |
| **5. Guardrails & Hooks** | Deterministic code at lifecycle points — things the agent should never forget but often does | `pre-commit` hook v8 (9 gates), `commit-msg` hook v5, `edit-guard.sh`, `commit-approval.sh`, `task-manifest.sh` |
| **6. Observability** | Evidence that it's working or quietly drifting | `project-metrics`, `HEALTH-CHECK.md`, `PROGRESS_STATUS.md`, `development/INCIDENT_*` |

---

## How the Harness Operates Across the SDLC

### Phase 1: Requirements & Planning (Configure the Harness)

Before any code, the harness is configured:

- **STEERING-GUIDE.md** defines which files are canonical and their severity
- **STACK_CONFIG.md** declares the project's technology and commands
- **AGENTS.md** + **SOUL.md** set identity, process, and boundaries
- **.sessionrc** defines session purpose and skill weighting

The human designs the system. The harness encodes those decisions.

### Phase 2: Implementation (Run the Harness)

During active coding, the harness keeps the agent focused:

- **Skills** load on-demand via task matching (lazy loading — ~250-line indexes, guides on-demand)
- **STEERING-GUIDE.md** gates which files the agent can modify
- **Session context** is maintained via `.sessionrc` and `AGENTS.md` Rule 0b

### Phase 3: Testing & QA (Feedback Loop)

The harness routes failures back to the agent for self-correction:

- **Pre-commit hook v8** runs 9 gates before every commit
- **validate-skill-table.sh** ensures PROGRESS_STATUS.md matches disk
- **skill-lint.sh** ensures all skills stay ≤ 250 lines
- **bash -n** verifies shell script syntax

### Phase 4: Code Review, Deployment & Maintenance (Observe the Harness)

The harness ensures safe behavior in production:

- **commit-msg hook v6** checks three gates (TEST_LOG + MANIFEST + APPROVED) — agent writes approval after "yes commit" in chat
- **commit-approval.sh** writes `.git/COMMIT_APPROVED` with timestamp after user says "yes commit" in chat (time-window based, no friction)
- **HEALTH-CHECK.md** is re-audited every 7 days (Rule 0b)
- **PROGRESS_STATUS.md** tracks project state against actual disk

---

## The Spectrum: From Vibe Coding to Agentic Engineering

| Dimension | Vibe Coding | This Project (Agentic Engineering) |
|---|---|---|
| Intent specification | Casual prompts | Formal specs, AGENTS.md, STEERING-GUIDE.md |
| Verification | "Does it seem to work?" | Automated gates, time-window approval, validate-skill-table.sh |
| Codebase understanding | Minimal | 57 skills with lazy-loaded guides |
| Error handling | Copy-paste errors back to AI | Pre-commit blocks, edit-guard integrity checks |
| Appropriate scope | Prototypes, scripts | Production systems, team-scale |
| Risk profile | High | Low — systematic verification at every stage |

---

## The Economics

The upfront investment in harness components (CapEx) pays for itself in reduced operational cost (OpEx):

- **Without harness (vibe coding):** Low CapEx (just prompts), high OpEx (token burn from repeated failures, debugging time, security remediation)
- **With harness (this project):** Higher CapEx (setting up AGENTS.md, skills, hooks), dramatically lower OpEx (first-pass success, mechanical verification, no context rot)

**Context engineering is a financial lever.** Passing an entire 100,000-token repo into every prompt is financially unviable at scale. This project's lazy-loading architecture ensures the model receives dense, high-signal context — exactly when it's needed.

---

## References

- Osmani, A., Saboo, S., & Kartakis, S. (2026). *The New SDLC With Vibe Coding: From ad-hoc prompting to Agentic Engineering.*
- Osmani, A. (2026). *The Factory Model.* https://addyosmani.com/blog/factory-model/
- Osmani, A. (2026). *From Conductors to Orchestrators.* https://addyosmani.com/blog/future-agentic-coding/
- Google. (2025). *Introduction to Agents.* Agents Whitepaper Series.
