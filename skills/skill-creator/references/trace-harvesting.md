# Trace Harvesting Guide

> **Crystallize successful agent traces into reusable skills.**
> Part of `skill-creator` — complementary to `skill-improver`.

## What Is Trace Harvesting?

Trace harvesting is the practice of watching a successful agent execution,
then converting that trajectory into a SKILL.md so the agent can repeat the
workflow reliably next time — without having to rediscover the steps.

From the whitepaper §6:

> *"Instead of asking a human to describe a workflow, watch the agent do
> it successfully a few times, then turn that trace into a skill."*

**Key insight:** The agent just solved a hard problem. That solution is
procedural knowledge. Without harvesting, it's lost after the session ends.

## The Harvesting Workflow

```
Agent completes task successfully
    │
    ▼
1. CAPTURE — Save the trace (key steps, tools, decisions)
    │
    ▼
2. EXTRACT — Isolate the repeatable pattern from context-specific details
    │
    ▼
3. GENERALIZE — Remove specifics (names, paths, dates), keep the logic
    │
    ▼
4. DRAFT — Generate SKILL.md using skill-creator template
    │
    ▼
5. REVIEW — Human reviews and adjusts
    │
    ▼
6. ADD — Commit to skills/ library (tier: draft)

7. IMPROVE — Run evals, use skill-improver on failures
    │
    ▼
8. PROMOTE — After eval stability, consider action-allowed
```

## Step-by-Step

### Step 1: CAPTURE — Identify a Harvestable Trace

A trace is harvestable when:
- The agent completed a **non-trivial, multi-step task**
- The workflow is **repeatable** (same kind of task will come again)
- The solution was **successful** (not a dead end or experiment)

Good candidates:
- Debugging a specific class of error (CORS, 500s, auth failures)
- Setting up a new tool or integration
- Performing a migration or upgrade
- Generating a specific kind of document or report

Bad candidates:
- One-off queries ("what's the capital of France?")
- Creative work unlikely to repeat
- Failed attempts or experiments

### Step 2: EXTRACT — What to Capture

Review the session history and extract:

```
TRACE EXTRACTION:
  Trigger:  What did the user ask that started this?
  Steps:    What did the agent do step by step?
  Tools:    Which tools were used (Read, Bash, Write, browser, etc.)?
  Decisions: What choices were made and why?
  Output:   What was the final result?
  Guards:   Any error recovery or edge case handling?
```

### Step 3: GENERALIZE — Remove Context, Keep Pattern

Replace specifics with generics. Example:

| Specific (from trace) | Generalized (for skill) |
|---|---|
| `api.example.com` | `[your-domain]` |
| `config.json` line 42 | `[config-file]` |
| "The user said their API was returning 503" | "User reports server errors" |
| `docker-compose.yml` | `[docker-compose-file]` |

### Step 4: DRAFT — Generate SKILL.md

Use the template from `skill-creator/templates/skill-template.md`.
Follow the skill-creator workflow to generate a valid SKILL.md + evals.

If the trace is very specific, start with a minimal skill (2-3 steps)
and expand as more traces accumulate.

### Step 5: REVIEW — Human Check

The human must confirm:
- Does the skill capture the correct workflow?
- Are the triggers accurate?
- Is the generalized version still actionable?
- Does it avoid overfitting to one specific case?

### Step 6: ADD — Commit to Library

```bash
git add skills/<new-skill>/
git commit -m "feat: harvest <skill-name> from trace"
```

Always start at tier `draft`. After eval stability, consider promotion.

### Step 7-8: IMPROVE → PROMOTE

Use `skill-improver` to diagnose and fix eval failures.
After consistent eval passes, human can promote to action-allowed.

## Complete Example

### Original Trace

The user says: "My website is loading but the API calls are failing.
I get 'No 'Access-Control-Allow-Origin' header' in the console."

The agent:
1. Opens browser DevTools → checks Network tab
2. Identifies the failing OPTIONS preflight request
3. Reads the backend CORS configuration
4. Identifies missing `Access-Control-Allow-Origin` header
5. Adds the correct origin to the CORS config
6. Verifies the fix by reloading the page

### Harvested Skill: cors-debugger

```yaml
---
name: cors-debugger
description: Debug CORS errors in browser API requests. Use when users report
  "No 'Access-Control-Allow-Origin' header", preflight failures, or cross-origin
  issues. Do NOT use for server-side errors without CORS involvement.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: debug-fix
---
```

**Workflow:**
1. Open browser DevTools → Network tab → filter by XHR/Fetch
2. Look for failing OPTIONS (preflight) or CORS-blocked requests
3. Check the response headers for `Access-Control-Allow-Origin`
4. Read the server's CORS configuration
5. Add the missing origin, method, or header to the CORS config
6. Verify: hard refresh and check that the request succeeds

**Eval cases** (generated via skill-creator):
```jsonl
{"case_id":"trigger_pos_001","type":"trigger_positive","input":"I get a CORS error in the browser when calling my API","expected_skill":"cors-debugger"}
{"case_id":"trigger_neg_001","type":"trigger_negative","input":"The server is returning 500 errors","expected_skill":"cors-debugger"}
```

### The Transformation

```
Trace → skill-creator template → SKILL.md + evals → review → commit → done
```

## Anti-Patterns

- **Overfitting:** Creating a skill that only works for one specific domain
  → Mitigation: generalize step names, use `[placeholders]` for specifics
- **Premature harvesting:** Creating a skill after one success
  → Wait for 2-3 similar traces before generalizing
- **Missing context:** Skill works but doesn't explain WHY each step
  → Add rationale comments ("why this step matters")
- **Ignoring edge cases:** The trace didn't hit errors, but the skill should
  → Add anti-patterns and "When NOT to Use" from experience
- **Skipping the review:** Auto-committing a harvested skill
  → Humans catch overfitting and missing edge cases

## Relationship to Other Meta-Skills

```
skill-creator ──→ Generates skills from descriptions
      ↑
      └── trace-harvesting ──→ Generates skills from traces
                                    │
                                    ▼
                              skill-improver ──→ Fixes skill issues
                                    │
                                    ▼
                            skill-creator (new version with lessons learned)
```

Cycle complete: create → evaluate → improve → harvest → create better.

## References

- Whitepaper §6 — Meta-Skills and Self-Improving Skills
- Voyager (Wang et al., 2023) — Minecraft skill library via autonomous discovery
- Anthropic skill-creator — Trace-based harvesting workflow
- `skills/skill-creator/SKILL.md` — Template and generation workflow
- `skills/skill-improver/SKILL.md` — Improvement after evals
