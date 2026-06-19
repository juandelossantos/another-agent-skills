# Doubt-Driven Development — Cross-Model Escalation

## Overview

A single-model reviewer shares blind spots with the original author. A different-architecture model catches them. Doubt-driven is opt-in for non-trivial decisions; within that scope, offering cross-model is value, not friction.

## Interactive Sessions: Always Offer

After single-model review (Step 3) but before RECONCILE, ask:

> *"Single-model review complete. Want a cross-model second opinion? Options: use a different CLI tool (e.g., codex, gemini, another agent), paste it into another tool manually, or skip."*

This is mandatory in every interactive doubt cycle. The user decides whether the cost is worth it.

## If the User Picks a CLI

1. Confirm which tool they want to use
2. Check it's available on PATH and test it works
3. Confirm the exact invocation with the user — flags, auth, env vars vary by tool
4. Pass ARTIFACT + CONTRACT + the adversarial prompt only. No session context, no CLAIM
5. Use stdin or a temp file to pass the prompt (avoid shell escaping issues with backticks, quotes, `$()`)
6. Take the output into Step 4 (RECONCILE)

**Never interpolate the artifact into a shell-quoted argument.** Write the prompt to a file and pipe via stdin.

## If the CLI Is Unavailable or Fails

Surface the failure explicitly. Offer: run it manually, try a different tool, or skip. Do not silently fall back to single-model — the user should know cross-model didn't happen.

## If the User Skips

Acknowledge the skip in the output and continue to RECONCILE. Skipping is fine; silent skipping is not.

## Non-Interactive Contexts

CI, `/loop`, autonomous-loop, scheduled runs:
- Cross-model is **skipped**, and the skip must be **announced** in the output
- **Never invoke an external CLI without explicit user authorization** — load-bearing safety property

Cross-model adds cost, latency, and tool fragility. The agent surfaces the choice every cycle; the user decides whether this artifact warrants it.
