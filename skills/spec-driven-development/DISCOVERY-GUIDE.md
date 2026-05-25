# Spec-Driven Development — Discovery Guide

This guide contains the complete Phase 2 Deep Discovery for `spec-driven-development`.

## Phase 2 — Deep Discovery (MANDATORY)

**NO SPEC IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

### Step 1: Surface Assumptions

List at least 5 assumptions. Present for confirmation:

```
ASSUMPTIONS I'M MAKING:
1. [Assumption about product type]
2. [Assumption about users/audience]
3. [Assumption about tech constraints]
4. [Assumption about data/storage]
5. [Assumption about timeline/scope]
→ Correct me now or I'll proceed with these.
```

### Step 2: Discovery Interview (Minimum 6 Questions)

Ask in user's detected language. Do not proceed until answered:

1. **Objective**: What problem does this solve? Who is the user? What does success look like?
2. **Scope**: MVP or complete product? What features are MUST vs. NICE vs. OUT?
3. **Context**: Where and how will this be used? (Device, environment, offline needs)
4. **Constraints**: Hard constraints? (Budget, timeline, compliance, existing systems)
5. **Stack preference**: Existing technology? Anything hated or loved?
6. **Success metrics**: How will we know this is done? (Numbers, user actions, performance targets)

### Step 3: Critical Challenge (Where We Differ from Obedient Agents)

**Analyze answers critically. Look for:**

- **Over-engineering:** "I need microservices" for 2-user MVP → Challenge: "Microservices add operational complexity. For MVP, monolith deploys faster. Would modular monolith work?"
- **Under-engineering:** "Store everything in localStorage" for sensitive data → Challenge: "localStorage is readable by any script and has no encryption. Security risk. Can we use IndexedDB with encryption or lightweight backend?"
- **XY Problem:** User asks for X but needs Y → Challenge: "You asked for [implementation]. I'm wondering if you actually need [underlying need]. Would [alternative] work better?"
- **Scope creep:** "And also..." → Challenge: "That's 3 features. For MVP, focus on [most critical] first. Others = Phase 2. Does that work?"
- **Missing context:** "I want it fast" → Challenge: "Fast to develop or fast to run? We can optimize for one but it trades off with the other. Which matters more for launch?"

**Presentation format:**
```
CRITICAL OBSERVATIONS:

1. [Observation about potential issue] → Suggestion: [better approach]
2. [Observation about trade-off] → Question: [what does user prioritize?]
3. [Observation about missing info] → Need: [specific detail]

→ Please respond to each. Your answers will go into the spec.
```

### Step 4: Confirm & Lock Discovery

Summarize EVERYTHING: research + discovery + critical analysis + resolutions.

```
SPEC FOUNDATION — CONFIRM THIS IS CORRECT:

We're building: [one sentence]
For: [audience]
That solves: [problem]
Using: [high-level approach, if decided]
Success means: [metrics]

Key decisions made:
- [Decision 1 with rationale]
- [Decision 2 with rationale]
- [Trade-off accepted: X over Y because Z]

→ Is this correct? Reply "yes" or correct me.
```

Only after explicit "yes/sí/proceed", proceed to Phase 3.
