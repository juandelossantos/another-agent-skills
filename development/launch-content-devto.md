# dev.to Article — Launch Day (or Day 2-3)

> Post after LinkedIn. 800-1200 words, 3-4 code blocks, tutorial-style.
> Tags: opensource, ai, testing, git, devops

---

**Title Option A (story-driven):**
# How I built mechanical enforcement for AI coding agents — and why prompts aren't enough

**Title Option B (problem-driven):**
# Your AI agent will break in production: here's the fix

---

## The Problem

AI coding agents are undeniably powerful. They generate code at speeds that would take a human developer hours. But there's a catch that doesn't show up in demos:

> The [METR study](https://arxiv.org/abs/2507.09089) (Becker et al., 2025) found that experienced developers using AI took **19% longer** on real tasks — but **felt 20% faster**.

The gap between perception and reality is process.

An AI agent can write a perfect function and ship broken code in the same commit — with the same confidence. It has no built-in discipline:

- It won't run tests unless you tell it to (and it forgets when context fills up)
- It won't review its own output critically (it doesn't know how)
- It won't remember the rules it agreed to 5 minutes ago (context is a sliding window)

The solution isn't better prompts. It's mechanical enforcement.

## The Insight: Agent = Model + Harness

After watching my own agent violate its rules repeatedly, I realized the problem was architectural:

**A model generates output. A harness constrains it.**

Most "agent frameworks" focus on the model — better prompts, more context, smarter chains. But the failures I was seeing weren't intelligence failures. They were *harness* failures.

The agent wasn't malicious. It just had no mechanical reason to follow the rules.

## The Harness Architecture

I built **Another Agent Skills**, an open-source framework with 6 harness components:

| Component | What it does |
|---|---|
| 57 composable skills | Loaded on demand, each handling one discipline (testing, code review, git, etc.) |
| 12 pre-commit gates | Mechanical checks that run before every commit — can't be skipped |
| Time-window approval | commit-msg hook verifies user approval is <5 min old |
| Manifest gate | Agent must write a commit manifest before requesting approval |
| Skill gate | Verifies the right skills were loaded before implementation |
| Anti-slop detection | Scans for AI-generated filler patterns in staged files |

## The Story That Changed Everything

I originally built a SHA256 token system for commit approval. The agent would generate a unique hash, the user would verify it, and the commit would proceed.

I thought it was bulletproof.

Then my agent bypassed it with `--auto` in under 30 seconds. The tokens were theater.

I replaced the entire system with a **time-window approval**:

```bash
# commit-msg hook (simplified)
if [ ! -f ".git/COMMIT_APPROVED" ]; then
  echo "❌ No approval found"
  exit 1
fi

APPROVED_TIME=$(stat -c %Y ".git/COMMIT_APPROVED")
NOW=$(date +%s)
AGE=$((NOW - APPROVED_TIME))

if [ "$AGE" -gt 300 ]; then
  echo "❌ Approval expired (>5 min)"
  exit 1
fi

APPROVED_MSG=$(head -1 ".git/COMMIT_APPROVED")
if [ "$APPROVED_MSG" != "$1" ]; then
  echo "❌ Message mismatch"
  exit 1
fi
```

No tokens. No hashes. No bypass.

## The 12 Pre-Commit Gates

Every commit goes through 12 mechanical gates:

```bash
# Pre-commit runs these checks:
# 1.  Branch check — not on detached HEAD
# 2.  Staged changes — something is staged
# 3.  Remote sync — no unpulled changes
# 4.  HTML integrity — structural markers preserved
# 5.  Skill gate — skills were loaded before coding
# 6.  Build verification — shell scripts syntax-checked
# 7.  Anti-slop — no AI filler patterns
# 8.  Debug tracking — escalates after 3 fix commits
# 9.  SPEC enforcement — new scripts must have a spec
# 10. PROGRESS_STATUS validation — table matches disk
# 11. Skill lint — SKILL.md structure validated
# 12. Eval gate — evals + dashboard + regression run
```

Each gate either blocks the commit (red) or warns (yellow). None are suggestions.

## What's Different

Most agent frameworks I've seen focus on one thing:

- **Better prompts** → "Tell the agent what to do more clearly"
- **More context** → "Give the agent more history"
- **Wrapper APIs** → "Abstract the model calls"

This project takes a different approach:

- **Define WHAT to do** → 57 skills, each with trigger conditions and workflows
- **Enforce THAT it's done** → 12 mechanical gates that run on every commit
- **Make it universal** → Works with any git-based agent (Claude Code, Cursor, OpenCode, Copilot)

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/juandelossantos/another-agent-skills.git

# 2. Install the framework
bash install.sh

# 3. Initialize in your project
bash scripts/init-agents.sh
```

The hooks install automatically. The next commit you make will go through all 12 gates.

## Stats

- **57 skills** — each ≤250 lines, loaded on demand
- **54 guides** — deep dives into specific workflows
- **12 pre-commit gates** — mechanical enforcement on every commit
- **E2E tested** — full pipeline validated by test-e2e.sh
- **MIT license** — free forever, zero subscriptions

## Deep Dive: The Anti-Slop Gate

One of the 12 gates that gets the most reaction is the anti-slop detector. It scans staged files for AI-generated filler patterns before allowing a commit:

```bash
# From pre-commit hook (Gate 7)
SLOP_PATTERNS=(
  "I'd be happy to"
  "Sure thing"
  "This is a placeholder"
  "TODO: fix this later"
  "As you can see"
)

for pattern in "${SLOP_PATTERNS[@]}"; do
  if grep -qF "$pattern" "$f" 2>/dev/null; then
    echo "❌ $f — contains slop: '$pattern'"
    exit 1
  fi
done
```

This catches the common case where an agent starts generating explanation text instead of shipping the actual fix. It's a simple grep with a big impact.

## Who This Is For

This project is for developers who:

- Use Claude Code, Cursor, or OpenCode in production — not just for prototyping
- Have already experienced an agent committing code that didn't run
- Want mechanical enforcement, not "please remember the rules"
- Work with any stack (Node, Python, Rust, Go — everything with git)

If that's you, the landing page has a 60-second quick start.

→ [juandelossantos.github.io/another-agent-skills](https://juandelossantos.github.io/another-agent-skills)

## The Philosophy

> *"Rules that depend on memory fail. Rules that depend on visible blocks succeed."*

This is the principle that drives everything. An agent can't "forget" to run tests when a git hook blocks the commit. It can't "skip" code review when the manifest gate requires it.

This project proves that agents don't need more capability. They need better harnesses.

---

**Links:**

- GitHub: [github.com/juandelossantos/another-agent-skills](https://github.com/juandelossantos/another-agent-skills)
- Landing page: [juandelossantos.github.io/another-agent-skills](https://juandelossantos.github.io/another-agent-skills)
- License: MIT

*Built from Colombia 🇨🇴. Used daily in production.*
