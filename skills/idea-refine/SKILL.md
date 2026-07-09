---
name: idea-refine
description: "Refine raw ideas into sharp, actionable concepts through divergent and convergent thinking. Use when an idea is vague or needs stress-testing. Do NOT use when requirements are already clear."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: ideate-converge
---

# Idea Refine

**Turn vague concepts into actionable specifications.**

Sits between `interview-me` (extracting intent) and `spec-driven-development` (writing specs). Uses structured divergent thinking (expand options) followed by convergent thinking (select best path).

## Pipeline Position

```
interview-me → idea-refine (this skill) → spec-driven-development
```

## When to Use

- Idea is still vague or incomplete
- Need to stress-test assumptions before committing
- Want to explore alternatives before converging on one

## When NOT to Use

- Requirements are already clear and documented
- Trivial changes with obvious scope

## Core Process: Double Diamond

Adapted from Design Council's framework. Two diamonds, each with diverge + converge:

```
Diamond 1 — Problem Space:
  Diverge: Explore alternatives, challenge assumptions, expand options
  Converge: Define the specific problem, select direction

Diamond 2 — Solution Space:
  Diverge: Generate solution variants, combine approaches
  Converge: Select best solution, prepare for spec
```

### Phase 1 — Diverge (Expand Options)

Goal: generate span, not depth. Resist evaluating during this phase.

Use techniques from `guides/DIVERGENT-CONVERGENT.md`:

| Technique | Best For |
|---|---|
| SCAMPER | Reimagining existing approaches |
| Reverse Thinking | Breaking out of incremental ruts |
| First Principles | Decomposing to fundamentals |
| How Might We | Reframing the problem |
| Worst Idea | Lowering inhibition, unlocking creativity |

**Facilitation prompts:**
- "What if we did the opposite?"
- "What if budget/time/tech weren't factors?"
- "Who else has this problem? How do they solve it?"
- "What would this look like at 10x scale?"
- "What if it could only have one feature?"

### Phase 2 — Converge (Select Path)

Goal: filter, prioritize, commit. Use evidence, not instinct.

| Technique | Best For |
|---|---|
| Impact/Effort Matrix | Prioritizing by value vs cost |
| NUF Test | Scoring novelty, usefulness, feasibility |
| Assumption Audit | Surfacing unvalidated bets |
| Pre-mortem | Stress-testing chosen direction |

**Facilitation prompts:**
- "What could kill this idea? If it failed in 12 months, why?"
- "What must be true for this to work?"
- "Would users switch from their current approach?"
- "Which failure modes are acceptable? Which are dealbreakers?"

### Output

The selected direction feeds directly into `spec-driven-development` as the starting point for SPEC.md.

## Anti-Patterns

1. **Premature convergence** — Picking the first idea without alternatives explored.
2. **Anchoring** — First idea (especially from senior person) becomes default.
3. **Confirmation bias** — Seeking evidence that supports preferred idea, dismissing counter-evidence.
4. **Solution-anchored framing** — "How do we add X?" instead of "What problem are we solving?"
5. **Skipping assumption audit** — Moving to spec without surfacing what must be true.
6. **Yes-machine facilitation** — Never pushing back on weak ideas.

## Verification

- [ ] Divergent phase completed (2+ techniques used, 3+ alternatives generated)
- [ ] Convergent phase completed (selection criteria defined and applied)
- [ ] Assumption audit surfaced must-be-true statements
- [ ] Selected direction has clear rationale (not just "felt right")
- [ ] Output ready to feed into `spec-driven-development`
- [ ] `bash scripts/skill-lint.sh skills/idea-refine` passes
