# Meta-Skills Guide

> **Create, improve, and harvest your own skills.**

This guide covers the meta-skill cycle: three complementary skills that let
you create new skills from descriptions, improve existing ones from eval
failures, and harvest successful agent traces as reusable skills.

---

## The Meta-Skill Cycle

```
skill-creator ──→ Generate skills from descriptions
      ↑                    │
      │                    ▼
      │            skill-improver ──→ Fix from eval failures
      │                    │
      │                    ▼
      └─── trace-harvesting ──→ Capture from agent traces
```

Each meta-skill is a regular skill in `skills/`. They work on any agent
that supports the agentskills.io standard.

---

## skill-creator

**Location:** `skills/skill-creator/SKILL.md`
**Purpose:** Generate a complete skill directory from a textual description.
**Tier:** draft (generated skills always start at draft)

### When to use

```
Input: "A skill that reviews Dockerfiles for security issues"

Output: skills/docker-security-review/
├── SKILL.md              ← frontmatter + workflow
├── evals/trigger.jsonl   ← 3 cases
├── evals/golden.jsonl    ← 2 cases
└── evals/adversarial.jsonl ← 2 cases
```

### Workflow

1. Describe the workflow you want to capture
2. The agent generates the skill directory + eval cases
3. Run verification: `bash scripts/skill-lint.sh` + 3 eval runners
4. Review and adjust if needed
5. Commit to the library

---

## skill-improver

**Location:** `skills/skill-improver/SKILL.md`
**Purpose:** Diagnose eval failures and propose targeted fixes.
**Tier:** draft

### When to use

```
$ bash scripts/eval/run-evals.sh --skill my-skill
→ 2 trigger_positive failures

→ skill-improver reads the current SKILL.md + failing evals
→ Proposes a diff with specific description changes
→ Human reviews and approves before applying
```

### Key rules

- **Never auto-applies changes** — always produces a diff for review
- Classifies failures: trigger, execution, token budget, or coverage gap
- Each failure type has a specific fix pattern

---

## trace-harvesting

**Location:** `skills/skill-creator/references/trace-harvesting.md`
**Purpose:** Convert successful agent execution traces into skills.
**Tier:** guide/reference (not a standalone skill)

### Workflow

1. Agent completes a complex multi-step task successfully
2. Extract the repeatable pattern from the trace
3. Generalize: replace specifics with placeholders
4. Generate SKILL.md using the skill-creator template
5. Human reviews before committing

---

## Integration with the Eval System

Every generated or improved skill goes through the same verification:

```bash
bash scripts/skill-lint.sh
bash scripts/eval/run-evals.sh --skill <name>
bash scripts/eval/run-golden.sh --skill <name>
bash scripts/eval/run-adversarial.sh --skill <name>
```

All must pass before the skill is ready for review.

---

## Best Practices

- **Always start at draft tier** — never action-allowed without review
- **Generate eval cases** — "a skill without a test is a hope"
- **Use skill-improver after evals** — close the loop
- **Harvest traces** — don't let procedural knowledge expire
- **Keep it ≤250 lines** — move detail to references/ if needed
- **Universal frontmatter** — `compatibility: all` for multi-agent support

---

## References

- Whitepaper §6 — Meta-Skills and Self-Improving Skills
- `skills/skill-creator/SKILL.md`
- `skills/skill-improver/SKILL.md`
- `skills/skill-creator/references/trace-harvesting.md`
- `docs/skills.html` — full skill catalog
