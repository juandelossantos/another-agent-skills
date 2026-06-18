---
name: skill-creator
description: >
  Generate new agent skills from a workflow description. Creates the complete
  skill directory structure: SKILL.md with frontmatter + workflow + examples,
  and 7 eval cases (trigger, golden, adversarial). Use when you need to create
  a new skill quickly from a textual description. Do NOT use for modifying
  existing skills (use skill-improver) or for one-off tasks.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: create-generate
---

# Skill Creator

**Generate production-ready skills from descriptions.**

Creates a complete skill directory with SKILL.md, eval cases, and progressive
disclosure structure. The generated skill is always tier **draft** — human
review required before promotion to action-allowed.

## When to Use

- Need a new skill and don't want to write SKILL.md from scratch
- Have a clear description of the workflow the skill should execute
- Want a skill with eval cases included from the start
- Rapid prototyping of new capabilities

## When NOT to Use

- Modifying an existing skill (use `skill-improver`)
- One-off tasks that won't be reused as skills
- Creating skills for trivial workflows (better to write manually)

## Workflow

### Step 1: Collect Description

Ask the user for a description of the workflow. Collect:
- **What the skill does** (one sentence, verb-led)
- **Trigger scenarios** (2-3 concrete examples of when to use)
- **Non-triggers** (1-2 scenarios where it should NOT activate)
- **Workflow steps** (3-5 ordered steps)
- **Audience** (all-engineers, frontend, backend, etc.)
- **Allowed tools** (Read, Bash, Write, Edit)

### Step 2: Generate Skill Name

Derive name from the description:

| Description | Generated Name |
|---|---|
| "Review Docker security configs" | `docker-security-review` |
| "Generate commit messages from diffs" | `commit-message-generator` |
| "Check API responses for schema compliance" | `api-schema-validator` |

Rules: kebab-case, gerund form preferred, no vendor prefixes, no generic names.

### Step 3: Generate SKILL.md

Use the template in `templates/skill-template.md`. Fill in:
1. Frontmatter YAML (name, description, version 1.0.0, license MIT,
   compatibility all, allowed-tools from input, tier draft)
2. Body: When to Use, When NOT to Use, Workflow, Examples, Output Format
3. Keep total ≤250 lines. If content exceeds, move detail to `references/`

### Step 4: Generate Eval Cases

Create 7 eval cases in `evals/`:

| File | Cases | Purpose |
|---|---|---|
| `trigger.jsonl` | 2 positive, 1 negative | Verify correct activation |
| `golden.jsonl` | 2 with rubric | Verify output quality |
| `adversarial.jsonl` | 1 rephrase, 1 boundary | Verify trigger robustness |

All cases must validate against `scripts/eval/schema.json`.

### Step 5: Create Directory Structure

```
skills/<skill-name>/
├── SKILL.md
├── evals/
│   ├── trigger.jsonl
│   ├── golden.jsonl
│   └── adversarial.jsonl
└── references/       (optional — add if SKILL.md > 200 lines)
```

### Step 6: Verify

Run these checks and report results to the user:

```bash
bash scripts/skill-lint.sh
bash scripts/eval/run-evals.sh --skill <name>
bash scripts/eval/run-golden.sh --skill <name>
bash scripts/eval/run-adversarial.sh --skill <name>
```

All must pass before presenting the result.

### Step 7: Present to User

Output summary:
```
✅ Created skill: <name>
   Path: skills/<name>/
   Lines: <N> (≤250 ✅)
   Evals: 3 trigger + 2 golden + 2 adversarial
   Status: DRAFT — review before action-allowed
   → Ready for review. Need changes?
```

## Examples

**Input:** "A skill that reviews Docker Compose files for security issues.
          It should check exposed ports, privileged mode, and env variables."

**Generated structure:**
```
skills/docker-compose-security/
├── SKILL.md
└── evals/
    ├── trigger.jsonl
    ├── golden.jsonl
    └── adversarial.jsonl
```

**trigger.jsonl:**
```jsonl
{"case_id":"trigger_pos_001","type":"trigger_positive","input":"Check this docker-compose.yml for security issues","expected_skill":"docker-compose-security"}
{"case_id":"trigger_pos_002","type":"trigger_positive","input":"Review the Docker Compose security configuration","expected_skill":"docker-compose-security"}
{"case_id":"trigger_neg_001","type":"trigger_negative","input":"Build the Docker image","expected_skill":"docker-compose-security"}
```

## Anti-Patterns

- Generating skills without eval cases → "a skill without a test is a hope"
- Using tier action-allowed by default → always start at draft
- Adding vendor prefixes to skill names (claude-*, gemini-*) → violates Rule 0k
- Creating skills that duplicate existing ones → check skills/ directory first
- Generating SKILL.md > 250 lines → move content to references/

## References

- `templates/skill-template.md` — base template for generated skills
- `scripts/eval/schema.json` — eval case schema for validation
- `scripts/skill-lint.sh` — linter for generated skills
- Existing skills in `skills/` — reference implementations
