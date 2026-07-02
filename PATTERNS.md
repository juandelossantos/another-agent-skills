# Patterns — Agent Workflow Engineering

> Quick-reference catalog of agent workflow patterns with use cases, trade-offs, and diagrams.
> For anti-patterns, see `ANTI-PATTERNS.md`. For full rule reference, see `AGENTS-EXTENDED.md`.

---

## Pattern Selection Guide

```mermaid
flowchart TD
    Q{"What do you need to do?"}
    Q -->|"Prevent unapproved mutations"| GP[Guardian Pattern]
    Q -->|"Save context tokens"| LL[Lazy Loading]
    Q -->|"Ensure skills are loaded"| SG[Skill Gate]
    Q -->|"Protect file integrity"| EB[Edit Barrier]
    Q -->|"Get commit approval"| CM[Commit Manifest]
    Q -->|"Validate visual work"| DG[Design Gate]
    Q -->|"Secure production commits"| TA[Three-Gate Approval]
    Q -->|"Manage context window"| CB[Context Budget]
```

---

## Pattern Catalog

### Guardian Pattern

**Trigger:** Before any git mutation (commit, push, merge, rebase).

**Trade-off:** Safety vs speed. The gate adds friction to every mutation but prevents unapproved changes.

**Description:** The meta-pattern that governs all git operations. Before every mutation, the agent must present a DECISION POINT block and receive explicit user approval. No batch-mode commits, no implied consent.

```mermaid
sequenceDiagram
    participant Agent
    participant User
    participant Git
    
    Agent->>User: DECISION POINT: propose change
    User-->>Agent: "yes commit"
    Agent->>Git: commit
    
    Note over Agent,Git: Every mutation = separate decision
```

**Implementation:**
- Rule 12 in `rules/common/enforcement.md`
- `scripts/commit-approval.sh` writes time-windowed approval token
- `scripts/git-hooks/commit-msg` v6 verifies 3 gates

**See also:** Rule 12, `AGENTS-EXTENDED.md` — Commit Manifest Protocol

---

### Lazy Loading

**Trigger:** A skill file exceeds ~100 lines, or a skill is not immediately needed.

**Trade-off:** Context efficiency vs load latency. Skills are loaded on-demand, saving ~45% of always-loaded tokens.

**Description:** Skills are kept as compact ~250-line indexes. Detailed guides are stored as separate files and loaded only when the `skill()` tool is invoked. This is the architecture that keeps context windows manageable across long sessions.

```mermaid
flowchart LR
    A["Session Start"] --> B["Load AGENTS.md (core)"]
    B --> C{"Skill needed?"}
    C -->|Yes| D["skill('name') loads SKILL.md"]
    C -->|No| E["Continue with core rules"]
    D --> E
```

**Implementation:**
- Rule 6 in `rules/common/context.md`
- SKILL.md as index (≤250 lines), guides as separate files
- `skill()` tool or direct read of `skills/<name>/SKILL.md`

**See also:** Rule 6, Rule 0e (Context Budget)

---

### Skill Gate

**Trigger:** Before any implementation or code generation.

**Trade-off:** Discipline vs friction. Forces skill consultation before implementation, preventing "just code it" shortcuts.

**Description:** A mechanical gate (`scripts/skill-gate.sh`) that creates a filesystem marker when a skill is loaded. The pre-commit hook verifies the marker exists before allowing commits. Without it, agents implement directly without consulting skills.

```mermaid
flowchart LR
    A["Task arrives"] --> B{"Skill applies?"}
    B -->|Yes| C["skill('name') loads skill"]
    C --> D["skill-gate.sh mark <name>"]
    D --> E["Implement"]
    B -->|No| E
    E --> F["pre-commit checks skill-gate.sh"]
    F -->|"Marked ✓"| G["Commit allowed"]
    F -->|"Not marked ✗"| H["BLOCKED"]
```

**Implementation:**
- `scripts/skill-gate.sh` — mark, check, reset
- Pre-commit hook — gate checks marker
- Created after INCIDENT_004 (implementation without skills)

**See also:** Rule 1, `AGENTS-EXTENDED.md` — Skill Gate Enforcement

---

### Edit Barrier

**Trigger:** Before and after every file edit via `edit()` or `write()` tool.

**Trade-off:** Prevention vs overhead. Adds ~2s per edit for verification but prevents file corruption and structural damage.

**Description:** A protocol (`scripts/edit-guard.sh`) that verifies file integrity at edit boundaries. Pre-flight checks that the file exists and structural markers are present. Post-flight verifies line count hasn't changed unexpectedly and markers remain intact.

```mermaid
flowchart LR
    A["Before edit"] --> B["edit-guard.sh preflight"]
    B -->|"Markers verified"| C["Perform edit"]
    C --> D["edit-guard.sh verify"]
    D -->|"Line count OK"| E["Continue"]
    D -->|"Line count changed >20%"| F["STOP - Recover"]
```

**Implementation:**
- `scripts/edit-guard.sh preflight <file> <markers>`
- `scripts/edit-guard.sh verify <file>`
- Line count delta check (>20% = BLOCKING)

**See also:** Rule 0d, `AGENTS-EXTENDED.md` — Edit Guard Protocol

---

### Commit Manifest

**Trigger:** Before every `git commit`.

**Trade-off:** Audit trail vs fluency. Every commit requires a visible manifest, but produces a verifiable audit trail.

**Description:** A structured block presented to the user before every commit, listing files changed, line counts, commit message, and a Rule 12 checklist. The user must type "yes commit" to proceed. Invalid responses ("ok", "dale") are rejected.

```mermaid
sequenceDiagram
    participant Agent
    participant User
    
    Agent->>User: COMMIT MANIFEST
    Note over Agent,User: Files, lines, Rule 12 checklist
    User-->>Agent: "yes commit" / "sí"
    Agent->>Agent: commit-approval.sh
    Note over Agent: Writes COMMIT_APPROVED token
    Agent->>Agent: git commit
    Note over Agent: Hook verifies 3 gates
```

**Implementation:**
- `AGENTS-EXTENDED.md` — Commit Manifest Protocol
- `scripts/commit-approval.sh` — writes timestamped approval
- `scripts/git-hooks/commit-msg` — three-gate verification

**See also:** Rule 12, `AGENTS-EXTENDED.md` — Time-Window Approval

---

### Design Gate

**Trigger:** Before any visual or design work (CSS, components, layouts).

**Trade-off:** Consistency vs agility. Requires design intent to be documented before implementation, preventing aimless visual iteration.

**Description:** A mechanical gate (`scripts/design-gate.sh`) that blocks visual work unless DESIGN.md or DESIGN-LOCK.md exists and the appropriate design skill has been loaded. Prevents shipping visual output without design intent.

```mermaid
flowchart TD
    A["Visual work needed"] --> B{"DESIGN.md exists?"}
    B -->|Yes| C{"Design skill loaded?"}
    B -->|No| D["Create DESIGN.md first"]
    D --> A
    C -->|Yes| E["Proceed with visual work"]
    C -->|No| F["Load design skill"]
    F --> C
```

**Implementation:**
- `scripts/design-gate.sh` — checks DESIGN.md + skill-loaded marker
- Skills: `soft-premium-ui`, `minimalist-ui`, `industrial-brutalist-ui`, `visual-frontend-mastery`

**See also:** Rule 0d (Design Gate), `SOUL.md` Principle 1

---

### Three-Gate Approval

**Trigger:** Every `git commit` in production or shared branches.

**Trade-off:** Security vs velocity. Three mechanical gates must pass before commit is allowed, preventing common failure modes.

**Description:** The commit-msg hook v6 verifies three gates: (1) TEST_LOG must be fresh (<1 hour), proving tests were run; (2) COMMIT_MANIFEST must exist, proving the manifest was presented; (3) COMMIT_APPROVED must be fresh (<5 min), proving user approval. All three must pass.

```mermaid
flowchart LR
    A["git commit"] --> B{"Gate 1: TEST_LOG?"}
    B -->|"Fresh (<1h)"| C{"Gate 2: MANIFEST?"}
    B -->|"Expired"| Z["BLOCKED"]
    C -->|"Present"| D{"Gate 3: APPROVED?"}
    C -->|"Missing"| Z
    D -->|"Fresh (<5min)"| E["✅ COMMIT ALLOWED"]
    D -->|"Expired"| Z
```

**Implementation:**
- `scripts/git-hooks/commit-msg` — three-gate verification
- `scripts/log-test-results.sh` — writes TEST_LOG
- `scripts/commit-approval.sh` — writes COMMIT_APPROVED

**See also:** Rule 12, `scripts/git-hooks/commit-msg`

---

### Context Budget (60/25/15)

**Trigger:** Session messages exceed 20 turns or context approaches capacity.

**Trade-off:** Retention vs capacity. Active work is preserved, history is compressed.

**Description:** The allocation strategy for context window: 60% current task (instructions, code under edit), 25% core rules (AGENTS.md summary), 15% recent conversation history. Compaction is triggered when messages exceed 20 turns, and it never evicts active work artifacts.

```mermaid
pie title Context Budget 60/25/15
    "Current task" : 60
    "Core rules" : 25
    "Recent history" : 15
```

**Implementation:**
- Rule 0e in `rules/common/context.md`
- Compaction at >20 messages
- Lazy loading (Rule 6) keeps skills out of baseline context

**See also:** Rule 0e, Rule 6 (Lazy Loading), `context-engineering` skill

---

## Summary

| Pattern | Trigger | Primary Gate | Risk without it |
|---|---|---|---|
| Guardian Pattern | Before any mutation | commit-msg hook v6 | Unapproved changes in repo |
| Lazy Loading | Skill > 100 lines | skill-lint.sh Check 6 | Context saturation at message 8 |
| Skill Gate | Before implementation | pre-commit hook | Implementation without process |
| Edit Barrier | Before/after each edit | edit-guard.sh | Corrupted or truncated files |
| Commit Manifest | Before each commit | commit-approval.sh | Batch-mode, unapproved commits |
| Design Gate | Visual/design work | design-gate.sh | Undocumented visual decisions |
| Three-Gate Approval | Production commits | commit-msg v6 | Missing tests, missing approval |
| Context Budget | >20 messages | Manual compaction | Degraded output quality |

---

*See [ANTI-PATTERNS.md](./ANTI-PATTERNS.md) for what happens when these patterns are ignored.*
*See [AGENTS-EXTENDED.md](./AGENTS-EXTENDED.md) for the full rule reference.*
