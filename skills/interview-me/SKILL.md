---
name: interview-me
description: "Extract what the user actually wants through one-question-at-a-time interviewing. Use when a request is underspecified. Do NOT use when requirements are already clear."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read
tier: read-only
metadata:
  audience: all-engineers
  workflow: discover
---

# Interview Me

**Surface intent before you plan, spec, or code.**

One question at a time until all 5 discovery dimensions reach ≥80% confidence. Produces `INTENT.md` — the artifact required by `spec-driven-development` before it can proceed.

## When to Use

- Request is underspecified ("build me X" without "for whom" or "why now")
- User says "interview me", "grill me", "are we sure?"
- Agent catches itself about to silently fill in ambiguous requirements
- Before `spec-driven-development` for any non-trivial request

## When NOT to Use

- Requirements already clear and documented
- Trivial, well-defined tasks (one-line fix, typo correction)
- Override: `NOINTENT: reason` in commit body

## Output Contract

`INTENT.md` (Markdown) — 5 dimensions ≥80% confidence + open questions. Produced here, consumed by `spec-driven-development` as a gate.

## Core Process

### Step 1 — Surface Assumptions

List at least 3 assumptions you're making and present them:

```
ASSUMPTIONS:
1. The user is [role/persona]
2. The core problem is [one sentence]
3. The scope is [MVP/Standard/Complex]
→ Correct me now or I proceed with these.
```

### Step 2 — Question (5 Dimensions)

One question at a time. Each answer updates one dimension's confidence score.

| Dimension | Starter Question |
|---|---|
| Audience | "Who specifically will use this? Can you name someone?" |
| Problem | "What happens today that isn't working? Tell me about the last time." |
| Context | "What exists already? What tools/stack are you on?" |
| Constraints | "What's non-negotiable? Time, budget, team limits?" |
| Success | "How will we know when this is done? What does done look like?" |

### Step 3 — Challenge

After each answer, probe: **Mom Test** (past behavior, not hypotheticals), **5 Whys** (root cause), **Branch** (unexpected dimensions).

### Step 4 — Confirm

Summarize all 5 dimensions, ask: "Is this correct? Shall I write INTENT.md?"

### Step 5 — Restate

Write `INTENT.md` with intent table, questions log, open questions.

## Confidence Heuristics

| Level | What It Means | Behavior |
|---|---|---|
| 100% | User explicitly stated, no ambiguity | Lock, no further questions needed |
| 80-99% | Clear from context + confirmation | Can proceed, note uncertainty |
| 50-79% | Inferred but not confirmed | Ask one more confirm question |
| <50% | Guessing | STOP. Must clarify before proceeding |

**Stop condition:** All 5 dimensions ≥80% OR user signals fatigue (3+ "I don't know" answers).

## Question Templates

**Openers:** "Tell me about [topic]. Where does it stand?" | "What triggered this now?" | "Who's involved?"
**Probers:** "What happened the last time?" | "What did you try that didn't work?" | "Why is that important?"
**Confirmers:** "So if I understand: [restatement]. Is that right?" | "On a scale of 1-10, how confident?"

## Anti-Patterns

1. **Leading questions** — "Wouldn't X be great?" primes yes. Ask neutrally.
2. **Future questions** — "Would you use this?" People predict badly. Ask about past behavior.
3. **Compliments as data** — "That's cool!" tells you nothing about willingness to use.
4. **Filling silence** — User pauses, agent guesses. Wait. Let user fill the space.
5. **Skipping challenge** — First answer accepted without probing. "Why" x 5 minimum.
6. **Ignoring fatigue** — 3+ "I don't know" means noise, not signal. Stop.

## Verification

- [ ] 5 assumptions surfaced and presented
- [ ] All 5 dimensions questioned (at least 1 question each)
- [ ] Each answer probed (Mom Test + 5 Whys where applicable)
- [ ] All 5 dimensions ≥80% confidence or user fatigue reached
- [ ] `INTENT.md` written with intent table, questions log, open questions
- [ ] User confirmed restatement before writing INTENT.md
