---
name: critique-skill
description: Evaluate interfaces with two-pass design review: scoring, persona tests, AI slop detection, Nielsen heuristics, and 25 anti-patterns. Do NOT use for implementation bugs.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-designers
  stack: any
  workflow: evaluate-refine
---

# Critique Skill

**Two-pass design review: LLM evaluation + automated detection.**

Scored report with prioritized issues. Does not fix — use with `polish`, `distill`, `typeset`, or `clarify` for fixes.

## When to Use

- Reviewing a **design plan** before any code is written (use Phase 0)
- Page is functionally complete, before ship (use Phase 1-3)
- "Does this feel right?" — need an honest second opinion
- User flags AI tells, generic layout, or sloppy design
- Before handing off for polish pass

Do NOT use for:
- Technical quality (use `audit-skill`)
- Incomplete work (use `shape` or `craft` first)
- Running Phase 0 on built code (use Phase 1-3)
- Running Phase 1-3 on a plan with no code (use Phase 0)

## Process

### Phase 0 — Design Plan Review (before code)

Use when the design is still a plan: a token system, typeface pairings, layout sketches. Do NOT build before this phase passes.

1. **Verify the contract:** Was Subject, Audience, and Single Job stated? If not, stop and require it (see `frontend-web` Phase 0b).
2. **Critique each token against the brief:** Does each color, typeface, and layout decision trace back to the Subject, Audience, or Single Job? Flag any choice that reads like a generic default.
3. **Check the bold choice:** Was one real aesthetic risk identified? If every decision is safe, the design will read as templated.
4. **Cross-reference against DESIGN-CORE.md:** Are any design principles violated? (e.g., Lila Rule violated? Typography defaults? Structure-is-information ignored?)
5. **Render verdict:** PASS (proceed to build) or REVISE (fix flagged items before coding).

Output format:
```
Design Plan Review:
  Contract: [Subject / Audience / Single Job]
  Verdict: PASS / REVISE
  Bold choice: [one sentence]
  Issues:
    [P1] — [what doesn't trace back to the brief]
    [P2] — [generic default that needs a specific choice]
```

### Phase 1 — LLM Design Review

Load `engineering-fundamentals/guides/DESIGN-CORE.md` for universal design principles.

Evaluate the interface across six dimensions:

1. **Nielsen Heuristics** (10 metrics, score 0-4 each):
   - Visibility of status, Match real world, User control, Consistency, Error prevention, Recognition, Flexibility, Aesthetic design, Help errors, Help docs
2. **Cognitive Load** (8 failure modes):
   - Visual noise, Split attention, Redundant info, Complex choices, Hidden actions, Inconsistent patterns, Memory burden, Task complexity
3. **Emotional Journey**:
   - Trace user's feeling through the flow. Map moments of confidence vs confusion.
4. **Persona Lenses** (4 personas, score 1-4 each):
   - The Evaluator, The Returning User, The Skeptic, The Power User
5. **AI Slop Detection**:
   - Flag any of the 25 anti-patterns present. See `ANTI-PATTERNS.md`.
6. **DO/DON'T Catalog**:
   - Cross-reference against DESIGN-CORE.md principles.

### Phase 2 — Automated Detection

Run deterministic checks against 25 anti-pattern families. See `ANTI-PATTERNS.md` for full catalog.

### Phase 3 — Merge & Prioritize

Merge both passes into one report:

```
AI slop verdict: PASS / FAIL (with specific tells)
Heuristic scores: [10 numbers, 0-4]
Cognitive load: [failures / 8]
Persona scores: [4 numbers, 1-4]
    ↓
Priority issues (3-5 items):
  [P0] — Blocks ship. Must fix.
  [P1] — Fix this pass.
  [P2] — Next cycle.
Questions to answer:
  [N] — Provocative questions the interface itself can't decide
```

P0-P2 severity follows `redesign-skill` convention. Route P0-P1 to `polish`, `distill`, `typeset`, or `clarify`.

## Output Example

```
AI slop verdict: FAIL
  Tells: gradient-text, ai-color-palette, nested-cards

Heuristics (Nielsen):
  Visibility of status    3/4
  Match with real world   2/4
  Consistency & standards 2/4
  Error prevention        3/4
  Recognition over recall 1/4

Personas:
  The Evaluator   2/4  (comparing alternatives)
  The Returning   3/4  (knows the product)
  The Skeptic     1/4  (seen every SaaS landing)
  The Power User  2/4  (needs speed)

Priority:
  P1: Gradient text on CTAs — replace with solid accent
  P1: Nested cards in 3 places — flatten to one level
  P2: Low contrast on secondary buttons — 3.1:1 vs 4.5:1

Questions:
  Is the hero selling or explaining? Current copy does both.
```

## Pitfalls

- **Running on incomplete work** — Critique is for finished pages. Empty states score badly because they are not done.
- **Ignoring the questions** — They are usually the most impactful fix.
- **Treating scores as grades** — They are diagnostic. A low score on a less important heuristic is fine.
- **Skipping Phase 2** — Automated detection catches what the LLM is blind to (its own tells).

## Related Commands

| Result | Next command |
|---|---|
| Heuristic score low | `polish`, `typeset`, `layout` |
| Cognitive load high | `distill` (simplify), `clarify` (rewrite copy) |
| Slop detected | `anti-patterns` fixes in each skill's ANTI-SLOP-GUIDE.md |
| Persona cold | `delight` (personality), `onboard` (first-run) |

## QA Gates

### Phase 0 (Plan Review)

- [ ] Contract stated (Subject / Audience / Single Job)
- [ ] Each token traced back to contract
- [ ] One bold choice identified and justified
- [ ] No generic defaults flagged without revision
- [ ] Verdict rendered (PASS / REVISE)
- [ ] REVISE items fixed before any code written

### Phase 1-3 (Built Page)

- [ ] Both passes completed (LLM + automated)
- [ ] All 10 heuristics scored
- [ ] All 4 personas scored
- [ ] Cognitive load failures counted
- [ ] AI slop verdict rendered (PASS/FAIL)
- [ ] Priority issues extracted (3-5 items)
- [ ] Questions to answer surfaced
- [ ] Report delivered to user before any fix
