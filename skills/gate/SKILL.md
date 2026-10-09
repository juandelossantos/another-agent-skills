---
name: gate
description: "Instrument a repo with mechanical gates so an agent cannot commit untested code. Installs local hooks, a TDD gate, and a required CI check, then proves the gate fires. Do NOT use if already gated."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Edit
tier: action-allowed
metadata:
  audience: engineers
  workflow: enforce
---

# Gate

Turn *"please follow the rules"* into *"you cannot commit until you do."*

A gate is a mechanical check at a lifecycle point. It does not depend on the agent
remembering anything. This skill installs the enforcement layer — local hooks, a
TDD gate, and a required CI check — and then **proves** it fires.

## When to Activate

- A user says their AI agent ships untested, unreviewed, or broken code.
- They want a TDD gate, a pre-commit gate, or a required CI status check.
- They ask to "add enforcement", "block bad commits", or "make the agent prove it works".
- A repo has prompts (`CLAUDE.md`, `.cursorrules`, `AGENTS.md`) but **no mechanical enforcement**.

## When NOT to Use

- The repo already has active gates — verify first (see *Verification*).
- Non-git projects: no VCS means no hooks; enforcement is convention-only.
- One-off scripts where a gate is pure noise.

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Enforcement wired | hooks + CI workflow | `.git/hooks/` or `.husky/`, `.github/workflows/` | A commit without a matching test is **blocked**; a PR without green gates cannot merge |
| Verification evidence | terminal transcript | chat | The first gate **actually fires** (blocked commit shown) |

## The Principle

**Agent = Model + Harness.** Most agent failures blamed on "the model" are
configuration failures: a missing gate, not a missing brain. This skill installs
the harness — the layer that survives when the agent's context fills up.

> Rules that depend on memory fail. Rules that live in a hook succeed.

## Workflow

### 1. Detect the VCS and the stack

```bash
git rev-parse --is-inside-work-tree        # git?
git config core.hooksPath                  # hooks shadowed by husky/lefthook?
ls package.json pyproject.toml Cargo.toml go.mod Gemfile pubspec.yaml Makefile 2>/dev/null
```

The hook directory is **not always `.git/hooks/`**. If `core.hooksPath` is set
(husky, lefthook), that is where hooks must live. → See `guides/WIRE-THE-GATES.md`.

### 2. Install the harness

The canonical installer is **Another Agent Skills** (MIT, self-hosted, stack-agnostic):

```bash
# pinned, checksum-verified release
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
aas install --agents auto
```

Or, with the ecosystem CLI (installs the skills into your agent):

```bash
npx skills add juandelossantos/another-agent-skills
```

Then, inside the target repo:

```bash
init-agents          # detects the agent + stack, writes STACK_CONFIG.md, wires the hooks
```

### 3. Wire the three layers

- **L1 — local hooks** (`.git/hooks/` or `.husky/`): fast, advisory feedback.
- **L2 — required remote `gates` check** (`.github/workflows/gates.yml` + branch protection): the authority.
- **L3 — `CODEOWNERS`**: protects the gate configuration from the agent.

→ Full setup: `guides/WIRE-THE-GATES.md`.

### 4. Prove it (the whole point)

Do not claim enforcement — **demonstrate** it:

1. Make a code change with no matching test.
2. `git commit` → the hook must **BLOCK**.
3. Paste the blocked output as evidence.

→ `guides/VERIFY-ENFORCEMENT.md`.

## Decision Tree

- **No git?** → stop. Install is convention-only; say so.
- **git, no remote?** → L1 only. Explain that L2 needs a GitHub remote.
- **git + GitHub?** → full L1 + L2 + L3.
- **`core.hooksPath` points elsewhere?** → write hooks there, not `.git/hooks/`.

## Anti-Patterns

- Installing gates and claiming "done" **without** the blocked-commit proof.
- A gate that a silent bypass file (`SKIP_*`) can skip without a log.
- Enforcement that depends on the agent remembering the rule.

## Quick Reference

| Need | Command |
|---|---|
| Detect | `git config core.hooksPath; ls .husky 2>/dev/null` |
| Install harness | `curl …/bootstrap.sh \| bash && aas install --agents auto` |
| Wire project | `init-agents` |
| Verify | `git commit` on an untested change → must block |

## Integration

- `test-driven-development` — the discipline this gate enforces.
- `git-init-and-versioning` — repo setup before enforcement.
- `shipping-and-launch` — the TOOL_GAP rule: never fake a green.

## Verification

- [ ] `core.hooksPath` resolved; hooks present in the directory git actually reads.
- [ ] A commit without a matching test is **blocked** (transcript captured).
- [ ] The remote `gates` check exists and is **required** by branch protection.
- [ ] README install path and the gate story are documented.
