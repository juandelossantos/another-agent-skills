# Interview Protocol

> **Sources:** The Mom Test (Rob Fitzpatrick) — asking about past behavior, not hypotheticals. 5 Whys (Sakichi Toyoda / Toyota) — root cause through iterative questioning. Contextual Inquiry (Beyer & Holtzblatt) — observing users in context.

## The Interview Flow

```
OPEN (broad context) → PROBE (deepen dimension) → CONFIRM (verify) → NEXT DIMENSION
```

Complete one cycle per dimension. Do NOT skip the confirm step — without it, you don't know if you heard correctly.

## 5 Whys Technique

When an answer feels shallow, dig:

```
User: "The current system is too slow."
Agent: "Why is that a problem now?" (Why 1)
User: "Because we're losing customers during checkout."
Agent: "Why are they leaving specifically?" (Why 2)
User: "The payment page takes 8 seconds to load."
Agent: "Why does it take 8 seconds?" (Why 3)
...
```

Stop when the answer becomes about a fundamental constraint (tech, resource, or physics) rather than a symptom.

## Mom Test — Avoiding Polite Lies

| Bad Question (future/hypothetical) | Good Question (past/behavioral) |
|---|---|
| "Would you use a tool that does X?" | "What do you use today to solve this? How's that working?" |
| "Do you think this feature is useful?" | "When was the last time this problem came up? What did you do?" |
| "Would you pay for this?" | "What have you paid for in the past to solve this?" |

**Rule:** A good answer describes something that already happened. A bad answer describes something the user *would* do.

## Branching Logic

When the user's answer opens a dimension you hadn't planned:

```
Planned: Audience → Problem → Context
User says: "The problem is we need SSO for our enterprise clients."
New dimension opens: Enterprise auth (not in original plan)

→ BRANCH: explore enterprise auth dimension first
→ Then return to original sequence
→ Log the branch in INTENT.md open questions
```

Branch when: unexpected constraint, previously unmentioned user segment, or dependency on external system.

## Confidence Scoring Rubric

| Dimension | 20% (guess) | 50% (hunch) | 80% (clear) | 100% (certain) |
|---|---|---|---|---|
| Audience | Vague persona | Role without name | Specific person/team | Named + confirmed |
| Problem | Generic pain | Second-hand complaint | Current workaround described | User demonstrated/described last episode |
| Context | "Probably uses X" | Known stack + version | Verified setup details | User showed you |
| Constraints | Assumed limits | Mentioned once | Repeated twice+ | Written in requirements doc |
| Success | "Make it better" | "Faster/cheaper" | Measurable target | Quantified + confirmed |

## Facilitation Script

```
1. OPEN: "I have some questions before we spec this. That ok?"
2. SURFACE: "Here's what I'm assuming so far: [3 assumptions]. Correct?"
3. QUESTION (per dimension):
   a. Open: "Tell me about [dimension]."
   b. Probe: "What happened the last time?" / "Why is that important?"
   c. Confirm: "So it's [restatement]. Did I get that right?"
4. SCORE: Update confidence per dimension. If any <80%, ask one more.
5. CHALLENGE: "What could kill this? If it failed in 6 months, why?"
6. RESTATE: "Let me summarize. [full restatement]. Is this correct?"
7. WRITE: If confirmed → write INTENT.md. If not → go back to Step 3.
```

Never skip Step 6. The restatement is where the user catches what you got wrong.
