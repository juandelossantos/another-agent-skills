# SOUL.md

> This document defines who we are. Not what we do — that's AGENTS.md.
> Not how we work — that's the skills. This is why we exist.

---

## Who We Are

We are engineers who believe AI coding agents should be **accountable, not autonomous**.

We don't make agents faster. We make them **reliable**.

We don't add more skills. We add **discipline**.

We don't trust the agent. We **verify**.

---

## Why We Exist

AI coding agents ship generic, sloppy, insecure output by default.

They commit without tests. They push without review. They overwrite each other's work. They produce code that looks correct but breaks in production. And when they fail, they fail silently — leaving humans to discover the damage hours later.

The industry's response has been more skills, more prompts, more context windows. We took a different approach: **mechanical enforcement**. Rules that don't depend on memory. Gates that don't depend on attention. Verification that doesn't depend on trust.

We exist because **the gap between "capable agent" and "reliable agent" is not intelligence — it's process**.

---

## What We Believe

### 1. Quality emerges from explicit contracts, not implicit trust

An agent that "knows" the rules will eventually break them. An agent that must present a DECISION BLOCK before every mutation cannot skip the decision. The difference is architectural, not behavioral.

### 2. Rules that depend on memory fail. Rules that depend on visible blocks succeed.

Three incidents taught us this. Rule 12 violations happened not because the agent didn't know the rule, but because knowing isn't doing. The fix was never "remind the agent harder." The fix was mechanical enforcement.

> "A rule that lives only in a file is a suggestion. A rule that lives in a checklist is a gate."
> — INCIDENT_001

### 3. A hook that accepts any token is a suggestion. A hook that verifies integrity is a gate.

Evolution of enforcement:
- v1: Process rules (agent remembers)
- v2: Visible manifest (agent presents)
- v3: SHA256 hash-bound token (hook verifies)

Each level removed a failure mode. The agent cannot bypass what it cannot forge.

### 4. Speed is a side effect of precision, never the primary goal

The METR study found developers 19% slower with AI but feeling 20% faster. Speed without correctness is liability. We optimize for getting it right, and speed follows.

### 5. Context is finite. Evict before you drown.

Agent context windows degrade before they fill. Our lazy-loading architecture (skills as ~250-line indexes, guides loaded on-demand) saves 45% of always-loaded tokens. We don't make the agent dumber. We make the instruction manual thinner.

### 6. "No, that's overcomplicated" is more valuable than blind compliance

The Mayéutic Challenge: agents that push back, surface tradeoffs, and question scope creep. An agent that says "no" when justified prevents more damage than an agent that says "yes" to everything.

### 7. We learn from our own failures faster than competitors ship features

Three Rule 12 violations in 48 hours produced three levels of enforcement. Each incident was documented, analyzed, and mechanically prevented. The project's learning velocity is its strongest signal.

### 8. Verification without evidence is inspection

A claim that cannot be verified is not verified. When tools cannot reach the world — no network, no build environment, no test runner — the honest answer is "ship status unknown," not "looks good to me." Inspired by Sub-Zero's TOOL_GAP verdict: never fake a win on a gap.

---

## What We Will NEVER Do

- **Never prioritize speed over approval.** Every mutation requires explicit human consent. No batch-mode commits. No "the user said yes before."
- **Never ship without mechanical enforcement.** If a rule can be bypassed by forgetting, it's not a rule — it's a suggestion.
- **Never make the agent dumber to save tokens.** Token optimization affects instruction tokens only. User-facing communication is untouched.
- **Never add quantity over quality.** 31 curated skills beat 313 mediocre ones. We will never chase skill count.
- **Never trust the agent's self-report.** "Tests pass" means nothing without running them. "Code is clean" means nothing without verification. Trust is mechanical, never verbal.
- **Never abandon the human in the loop.** The agent suggests. The human decides. This is non-negotiable.

---

## When Values Conflict

| Conflict | Winner | Why |
|---|---|---|
| Speed vs. Safety | **Safety** | A bad commit is faster to make than to fix. |
| Breadth vs. Depth | **Depth** | One skill that works completely beats five that are stubs. |
| Simplicity vs. Completeness | **Simplicity** | If a senior engineer would say "this is overcomplicated," it is. |
| Automation vs. Control | **Control** | The agent suggests. The human decides. Always. |
| Features vs. Enforcement | **Enforcement** | A feature without a gate is a liability. |
| Recap vs. Continuation | **Continuation** | Recap wastes tokens. Continuation preserves momentum. |

---

## How We Measure Ourselves

Not by stars. Not by skill count. Not by lines of code.

By these metrics:

1. **Build pass rate** — Does the project compile and pass tests?
2. **Gate pass rate** — How often do mechanical gates catch real issues?
3. **Rework rate** — How often do we have to fix what we already shipped?
4. **Token efficiency** — How much context do we use vs. alternatives?
5. **User override frequency** — How often does the user have to bypass our gates? (Lower is better — it means the gates are correctly calibrated.)

---

## The Compact Version

If you need to explain this project in one sentence:

> **We turn AI coding agents from obedient servants into disciplined senior engineers — through mechanical enforcement, not suggestions.**

If you need to explain it in one paragraph:

> AI agents are capable but undisciplined. They commit without tests, push without review, and produce generic output. Another Agent Skills adds the process layer that agents lack: mechanical enforcement that can't be forgotten, context engineering that doesn't waste tokens, and behavioral guardrails that challenge bad ideas instead of executing them. The result is an agent that works like a senior engineer — precise, accountable, and reliable.

---

## For New Contributors

When you contribute to this project, you're not just adding code. You're reinforcing a philosophy:

- Every skill must have a "when to activate" section (discoverability)
- Every guide must be lazy-loaded (context efficiency)
- Every rule must have mechanical enforcement (reliability)
- Every change must pass through the Guardian Pattern (human control)

If your contribution doesn't align with these principles, it doesn't belong here. That's not gatekeeping — it's quality control. The same principle we apply to agents, we apply to ourselves.

---

*This document is the soul of the project. It doesn't change with features. It changes only when we learn something fundamental about what we are.*
