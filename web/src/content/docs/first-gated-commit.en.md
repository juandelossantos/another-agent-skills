---
title: "Your first gated commit"
description: "A five-minute walkthrough: install Another Agent Skills, run init-agents, watch the local gate block a code change with no matching test, then add the test and commit."
lang: "en"
order: 3
section: "tutorials"
tldr: "Install once per machine, run init-agents in the project, then commit a code change with no test: the commit-msg gate prints BLOCKED. Add the matching test and the same commit passes."
---

## What you will do

Install the framework once on your machine, activate it in a project, and watch the local gate stop a commit that changes code without a matching test. Then you add the test and commit again. The whole loop takes about five minutes.

**You will end with:** a project where `init-agents` has wired the hooks, one blocked commit you saw with your own eyes, and one green commit.

## Before you start

- **Git** on `PATH`.
- **Bash** (Linux, macOS, or Git Bash on Windows).
- An agent that reads `AGENTS.md` (OpenCode is the default; Claude Code, Cursor, Codex, and Gemini CLI also work).

## 1. Install once per machine

The installer places the skills globally. Any project can use them without duplicating the files.

```bash
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
bash install.sh
```

The pinned release bootstrap is the one-line path and verifies a checksum before extracting:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

> The npm wrapper and Homebrew formula are **coming soon**. Use `git clone` or the pinned `curl` bootstrap today.

## 2. Activate it in a project

```bash
mkdir my-project && cd my-project
git init
init-agents
```

`init-agents` merges `AGENTS.md` (never overwriting your rules), writes `STACK_CONFIG.md`, and installs the local hook shims because `.git` now exists.

## 3. Stage a code change with no test

Create a source file and stage it:

```bash
mkdir -p src
printf 'export function checkout() { return true; }\n' > src/checkout.js
git add src/checkout.js
git commit -m "feat: add checkout"
```

## What you should see

The commit is blocked before it exists:

```text
$ git commit -m "feat: add checkout"
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: none
✗ BLOCKED: every code change needs a matching test.
```

The file is still staged. Nothing was committed.

## 4. Add the matching test

```bash
printf 'import { test } from "node:test";\nimport assert from "node:assert/strict";\nimport { checkout } from "../src/checkout.js";\ntest("checkout", () => assert.equal(checkout(), true));\n' > src/checkout.test.js
git add src/checkout.test.js
git commit -m "feat: add checkout"
```

## What you should see now

```text
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: src/checkout.test.js
✓ TDD gate passed
```

The commit is created. This is the core rule of the framework: a code change with no matching test is blocked, locally and remotely.

## If it does not work

| Symptom | Fix |
|---|---|
| `init-agents: command not found` | Reload your shell (`source ~/.zshrc` or `source ~/.bashrc`). |
| The hook does not fire | Re-run `bash scripts/init-agents.sh` inside the project. |
| `matching test: none` after you added one | The test must be staged in the **same** commit and paired by name (`checkout.js` ↔ `checkout.test.js`). |

## Next

- [Wire the remote enforcement](wire-remote-enforcement/) so the same rule applies in CI, not just on your machine.
- [Enforcement (L1/L2/L3)](../enforcement/) explains why local hooks are feedback and the remote `gates` check is the authority.
