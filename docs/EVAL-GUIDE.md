# Evaluation Guide

> **Part of Another Agent Skills** — Skill evaluation system based on Evaluation-Driven Development (EDD), following the 4 failure modes from Singhal et al. (2026).

## Table of Contents

1. [What Is the Eval System?](#1-what-is-the-eval-system)
2. [Eval Format](#2-eval-format)
3. [Skill Tiers](#3-skill-tiers)
4. [Adding Evals to a Skill](#4-adding-evals-to-a-skill)
5. [Running Evals](#5-running-evals)
6. [Trigger Accuracy](#6-trigger-accuracy)
7. [CI / Pre-Commit Integration](#7-ci--pre-commit-integration)
8. [Coverage Checklist](#8-coverage-checklist)
9. [Examples](#9-examples)

---

## 1. What Is the Eval System?

The eval system verifies that skills behave correctly across four failure modes defined by the Agent Skills whitepaper:

| Failure Mode | What It Tests | Eval Type |
|---|---|---|
| **Trigger** | Does the skill fire when it should (and stay silent when it shouldn't)? | `trigger_positive`, `trigger_negative` |
| **Execution** | Does the skill produce correct output? | `execution` (or golden dataset) |
| **Token Budget** | Does the skill stay within 5,000 tokens? | `token_budget` (automated) |
| **Regression** | Do co-loaded skills interfere with each other? | `regression` |

Each eval is a JSON line (`.jsonl`) stored alongside the skill in `skills/<name>/evals/`.

Note: `token_budget` validation is automated (SKILL.md line/word count checks by `skill-lint.sh`) and does not use a `.jsonl` file.

---

## 2. Eval Format

### Schema

Every eval case must follow the schema defined in [`scripts/eval/schema.json`](../scripts/eval/schema.json):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["case_id", "input", "type"],
  "properties": {
    "case_id":    { "type": "string", "pattern": "^[a-z0-9_]+$" },
    "description": { "type": "string" },
    "input":      { "type": "string" },
    "type":       { "enum": ["trigger_positive", "trigger_negative", "execution", "regression"] },
    "expected_skill": { "type": "string" },
    "expected_tool_calls": { "type": "array" },
    "expected_output_format": { "type": "string" },
    "rubric":     { "type": "array", "items": { "type": "string" }, "minItems": 1 },
    "tags":       { "type": "array", "items": { "type": "string" } }
  }
}
```

### Case Types

| Type | When to Use | Required Fields |
|---|---|---|
| `trigger_positive` | Input that SHOULD activate this skill | `case_id`, `input`, `type`, `expected_skill` |
| `trigger_negative` | Input that should NOT activate this skill (close but wrong domain) | `case_id`, `input`, `type`, `expected_skill` |
| `execution` | Tests output quality against a rubric | `case_id`, `input`, `type`, `rubric` |
| `regression` | Tests that co-loaded skills don't degrade each other | `case_id`, `input`, `type` |

### File Naming

Place eval files in `skills/<name>/evals/`:

| File | Purpose |
|---|---|
| `trigger.jsonl` | Trigger positive + negative cases |
| `golden.jsonl` | Golden dataset: known-good inputs with expected output + rubric |
| `adversarial.jsonl` | Red-team cases: rephrasing, negative boundary, edge case |

---

## 3. Skill Tiers

Every skill has a `tier` field in its frontmatter that determines what the skill is allowed to do:

| Tier | Behavior | Examples |
|---|---|---|
| `read-only` | Analyzes, reviews, audits. Never modifies files. | `code-review-and-quality`, `audit-skill`, `critique-skill` |
| `draft` | In development. May produce output but not trusted for production. | Newly created skills, `skill-creator` output |
| `action-allowed` | Can read, write, and execute. Full capability. | `backend-api-mastery`, `git-init-and-versioning`, `hard-skill` |

The tier is checked before execution. A `read-only` skill that tries to write files should fail its evals.

---

## 4. Adding Evals to a Skill

### Step 1: Create the evals directory

```bash
mkdir -p skills/<name>/evals
```

### Step 2: Write trigger tests

Create `trigger.jsonl` with at least 2 positive cases and 1 negative case:

```jsonl
{"case_id":"trigger_pos_xxx_001","type":"trigger_positive","input":"...","expected_skill":"<name>"}
{"case_id":"trigger_pos_xxx_002","type":"trigger_positive","input":"...","expected_skill":"<name>"}
{"case_id":"trigger_neg_xxx_001","type":"trigger_negative","input":"...","expected_skill":"<name>"}
```

### Step 3: Write golden cases

Create `golden.jsonl` with known-good inputs and rubrics:

```jsonl
{"case_id":"golden_xxx_001","type":"execution","input":"...","expected_output":"...","rubric":["criterion 1","criterion 2"]}
```

Note: Golden cases use `expected_output` (checked by `run-golden.sh`). The schema's `expected_output_format` field is optional metadata.

### Step 4: Write adversarial cases

Create `adversarial.jsonl` with rephrasing and boundary cases:

```jsonl
{"case_id":"adv_xxx_001","type":"rephrasing","input":"..."}
{"case_id":"adv_xxx_002","type":"negative_boundary","input":"..."}
{"case_id":"adv_xxx_003","type":"edge_case","input":"..."}
```

### Step 5: Validate

```bash
bash scripts/eval/run-evals.sh --skill <name>
bash scripts/eval/run-golden.sh --skill <name>
bash scripts/eval/run-adversarial.sh --skill <name>
```

---

## 5. Running Evals

### Structural Validation

Validates JSON structure against schema:

```bash
# Run all skills
bash scripts/eval/run-evals.sh --all

# Run one skill
bash scripts/eval/run-evals.sh --skill <name>

# List skills with eval directories
bash scripts/eval/run-evals.sh --list
```

### Golden Dataset

Validates output format against expected rubric:

```bash
bash scripts/eval/run-golden.sh --all
bash scripts/eval/run-golden.sh --skill <name>
```

### Adversarial / Red-Team

Tests trigger robustness with rephrasing, negative boundaries, and edge cases:

```bash
bash scripts/eval/run-adversarial.sh --all
bash scripts/eval/run-adversarial.sh --skill <name>
```

### Coverage Report

Shows which skills have trigger, golden, and adversarial coverage:

```bash
bash scripts/eval/check-coverage.sh
```

Sample output:

```
  Skill                                        Trigger    Golden     Adversarial
  ----                                         -------    ------     -----------
  engineering-fundamentals                     ✓          ✓          ✓
  optimize-skill                               ✓          ✓          ✓
  frontend-web                                 ✓          ✓          ✓
  ...
  24 full coverage · 0 partial · 0 none · 57 total
```

---

## 6. Trigger Accuracy

The target trigger accuracy for every skill is **≥90%**.

Accuracy is calculated as:

```
accuracy = (true positives + true negatives) / (total cases)
```

Where:
- **True positive**: Trigger fires when it should (rephrasing cases)
- **True negative**: Trigger stays silent when it should (negative boundary cases)
- **False positive**: Trigger fires when it shouldn't
- **False negative**: Trigger stays silent when it should fire

A future `trigger-dashboard.sh` (Phase 9) will track accuracy over time and flag skills below 90%.

---

## 7. CI / Pre-Commit Integration

The eval system is designed for pre-commit integration (planned for Pre-Commit v9):

| Gate | What It Checks |
|---|---|
| **Eval Gate** | All changed skills have passing evals |
| **Trigger Accuracy** | Trigger accuracy ≥90% for all skills |
| **Coverage Gate** | All skills have minimum eval coverage |
| **Regression Gate** | No eval regression from previous run |

Currently, eval runs are manual. Pre-commit v9 will enforce these gates automatically.

---

## 8. Coverage Checklist

Every skill should aim for:

- [ ] `trigger.jsonl` — ≥2 positive cases, ≥1 negative case
- [ ] `golden.jsonl` — ≥1 case with rubric (3+ criteria)
- [ ] `adversarial.jsonl` — ≥1 rephrasing, ≥1 negative boundary, ≥1 edge case
- [ ] Tier field is set correctly in frontmatter
- [ ] Trigger accuracy ≥90% (manual check until dashboard is built)

---

## 9. Examples

### Trigger — Positive

```jsonl
{"case_id":"trigger_pos_slow_001","type":"trigger_positive","input":"The page loads too slowly, the images are huge and unoptimized","expected_skill":"optimize-skill"}
```

### Trigger — Negative

```jsonl
{"case_id":"trigger_neg_rewrite_001","type":"trigger_negative","input":"Rewrite the checkout flow to use React","expected_skill":"optimize-skill"}
```

### Golden Dataset

```jsonl
{"case_id":"golden_perf_001","input":"Landing page takes 8 seconds on 4G. Hero image is 5MB.","expected_output":"performance_optimization","rubric":["identifies largest bottlenecks","suggests image optimization","recommends code splitting","estimates LCP improvement"]}
```

### Adversarial — Rephrasing

```jsonl
{"case_id":"adv_perf_001","type":"rephrasing","input":"My app is slow, can you help me speed it up?"}
```

### Adversarial — Negative Boundary

```jsonl
{"case_id":"adv_perf_002","type":"negative_boundary","input":"Add a loading spinner to the button"}
```

### Adversarial — Edge Case

```jsonl
{"case_id":"adv_perf_003","type":"edge_case","input":""}
```

---

## 10. Advanced Evaluation

Three additional tools provide quantitative analysis of the eval system itself.

### Trigger Accuracy Dashboard

[`scripts/eval/trigger-dashboard.sh`](../scripts/eval/trigger-dashboard.sh) measures trigger coverage across all skills:

```bash
bash scripts/eval/trigger-dashboard.sh --all
```

Reports per-skill trigger counts (positive/negative), accuracy percentage, and flags skills below the 90% threshold. Tracks history in `.trigger-stats.json` for trend comparison. Exit code 1 if any skill is below threshold.

### Regression Test Suite

[`scripts/eval/run-regression.sh`](../scripts/eval/run-regression.sh) runs ALL eval cases for ALL skills and detects regressions:

```bash
bash scripts/eval/run-regression.sh          # Run and compare
bash scripts/eval/run-regression.sh --reset  # Reset baseline
```

Records results in `.regression-results.json`. On subsequent runs, compares against the baseline. Exit code 1 if any skill regressed (went from PASS to FAIL).

### LLM-as-Judge Pattern

[`scripts/eval/run-llm-judge.sh`](../scripts/eval/run-llm-judge.sh) evaluates output quality against a rubric using a peer model:

```bash
bash scripts/eval/run-llm-judge.sh --skill <name> --case <case_id>
```

Generates two judge prompts with reversed rubric order (per whitepaper §4 position swapping to eliminate ordering bias). Pipe each prompt to your LLM, then average the scores.

**Integration:** These tools are invoked by `skill-improver` during diagnosis and by `engineering-fundamentals` quality gates. They are also available for manual use by maintainers.

### E2E Integration Test

[`scripts/eval/test-e2e.sh`](../scripts/eval/test-e2e.sh) validates the entire eval system end-to-end:

```bash
bash scripts/eval/test-e2e.sh
```

Creates a temporary test skill with known eval cases, then runs the full pipeline:

1. **skill-lint** → verifies the temp skill passes structural checks
2. **run-evals** → verifies trigger evals pass
3. **trigger-dashboard** → verifies all existing skills remain ≥90% accuracy
4. **run-regression** → verifies no regressions across all skills

Cleans up the temp skill on both success and failure. Exit code 0 indicates all pipeline steps pass. Use this as a smoke test before releasing or after making changes to the eval infrastructure.
