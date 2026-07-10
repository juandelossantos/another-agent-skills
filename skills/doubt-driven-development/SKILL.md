---
name: doubt-driven-development
description: Review every non-trivial decision with a fresh-context adversarial review. Use when correctness matters, stakes are high, or code is unfamiliar. Do NOT use for trivial changes.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: review
---

# Doubt-Driven Development

## Overview

A confident answer is not a correct one. Long sessions accumulate context that quietly turns assumptions into "facts". Doubt-driven development materializes a fresh-context reviewer biased to **disprove** before any non-trivial output stands.

This is not `/review`. `/review` is a verdict on a finished artifact. This is an in-flight posture for course-correction when it's still cheap.

## When to Use

A decision is **non-trivial** when it introduces branching logic, crosses a module boundary, asserts unverifiable properties (thread safety, idempotence), has irreversible blast radius (production deploy, data migration, public API change), or depends on context the future reader cannot see.

Apply when: about to make an architectural decision, commit non-trivial code, claim a non-obvious fact, or work in code you don't fully understand.

**When NOT to use:** mechanical operations (renaming, formatting), clear unambiguous instructions, reading/summarizing code, one-line changes, pure tooling. If you doubt every keystroke, you ship nothing.

## Output Contract

Doubt cycle log + adversarial review findings — CLAIM statement, isolated ARTIFACT + CONTRACT, fresh-context reviewer findings classified by precedence (contract misread / actionable / trade-off / noise), cross-model offer recorded, stop condition met.

## Loading Constraints

Designed for the **main-session orchestrator** — Step 3 spawns a fresh-context reviewer. Do NOT add this skill to a persona's `skills:` frontmatter (personas must not invoke other personas). If inside a subagent context, surface to the user that doubt-driven cannot run nested. As last resort, use degraded self-questioning fallback (flag as degraded in output).

## The Process

```
Doubt cycle:
- [ ] Step 1: CLAIM — wrote the claim + why-it-matters
- [ ] Step 2: EXTRACT — isolated artifact + contract, stripped reasoning
- [ ] Step 3: DOUBT — invoked fresh-context reviewer with adversarial prompt
- [ ] Step 4: RECONCILE — classified every finding against the artifact text
- [ ] Step 5: STOP — met stop condition (trivial findings, 3 cycles, or override)
```

### Step 1: CLAIM — Surface what stands

Name the decision in 2-3 lines. If you can't write it that compactly, you have a vibe, not a decision.

### Step 2: EXTRACT — Smallest reviewable unit

Pass the reviewer the **artifact** and the **contract**, not your reasoning or the journey. The unit must fit in one read — if it's a 500-line PR, decompose first.

### Step 3: DOUBT — Invoke the fresh-context reviewer

Prompt **must be adversarial**. Find what is wrong. Do NOT validate. Do NOT summarize. Pass ARTIFACT + CONTRACT only — never the CLAIM (biases toward agreement).

→ See `guides/CROSS-MODEL.md` for cross-model escalation (mandatory offer in interactive cycles).

### Step 4: RECONCILE — Fold findings back

The reviewer's output is data, not verdict. Re-read the artifact text against each finding. Classify (first match wins):

1. **Contract misread** — contract was unclear. Fix contract, re-loop.
2. **Valid + actionable** — real issue. Fix artifact, re-loop.
3. **Valid trade-off** — cost of fixing > cost of accepting. Document explicitly.
4. **Noise** — reviewer lacked context. Note it.

### Step 5: STOP — Bounded loop

Stop when: next iteration returns only trivial findings, 3 cycles completed (escalate to user), or user says "ship it". If after 3 cycles issues remain substantive, the artifact may not be ready.

## Interaction with Other Skills

- **`code-review-and-quality` / `/review`**: complementary. `review` is post-hoc PR verdict; doubt-driven is in-flight per-decision.
- **`source-driven-development`**: SDD verifies facts about frameworks; doubt-driven verifies your reasoning about the artifact.
- **`test-driven-development`**: TDD's RED step satisfies the doubt step for behavioral claims.
- **`debugging-and-error-recovery`**: when reviewer surfaces a real failure mode, use this skill to localize and fix.
- **`shipping-and-launch`**: use TOOL_GAP — if you can't reach the real world, report "ship status unknown".

## Verification

- [ ] Every non-trivial decision named as a CLAIM before standing
- [ ] At least one fresh-context review per non-trivial artifact
- [ ] Reviewer received ARTIFACT + CONTRACT — not CLAIM or your reasoning
- [ ] Prompt was adversarial ("find issues"), not validating
- [ ] Findings classified using precedence: contract misread / actionable / trade-off / noise
- [ ] Stop condition met (trivial findings, 3 cycles, or user override)
- [ ] Interactive: cross-model offered. Non-interactive: skip announced
- [ ] CLI: PATH check + binary test + syntax confirmed + user authorized
- [ ] No rule conflicts — checked (Rule 0h, 0i, 12)
