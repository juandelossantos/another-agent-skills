# Session State — Phase 8: Remote Enforcement

**Date:** 2026-10-02
**Branch:** `chore/session-status-update` — branched from `origin/main` (Phase 7 released as v6.2.0; Phase 8 P8.1–P8.3 merged), NOT pushed
**Status:** ✅ Phase 7 released as **v6.2.0**; Phase 8 **P8.1–P8.3 done and ACTIVE** (branch protection on `main` requires the `gates` check). Next: **P8.5 / P8.6 / P8.7** → Phase 10 / Phase 11.
**Plan:** `PLAN.md` — single source of truth

## What Was Done (2026-10-02)

1. **Phase 7 released as v6.2.0** (merged to `main` via PR #35) — dual-contract OpenCode plugin (v1 `server()` + v2 `setup()`), multi-agent detection (15 agents) + version gating, per-agent skills/guardrails, **philosophy A** (the agent never runs `git commit`/`push` — no token bypass), global install hardening (`--plugin-only` / `--skills-only` / `--guardrails-only`).
2. **Phase 8 P8.1–P8.3 done and ACTIVE** (PRs #36, #37):
   - `.github/workflows/gates.yml` runs the real gates and is the **required `gates` check**.
   - `scripts/setup-branch-protection.sh` (solo-safe + lockout guard + code-owner guard) applied branch protection to `main` — verified via `gh api`: required check `gates`, 0 approvals, code-owner reviews off (solo), `enforce_admins: false` (no lockout).
   - `CODEOWNERS` protects the gate config (L3).
3. **Test cadence formalized** — `tests/` = behavioral/regression (permanent); `tests/task/` = task tests capped at 20 (`scripts/test-cadence.conf`). Checkpoint = push + full review → archive → reset (`docs/TEST-CADENCE.md`).
4. **This branch** refreshes `PLAN.md`, `PROGRESS_STATUS.md`, `HEALTH-CHECK.md`, and this handoff to the post-v6.2.0 reality. Not committed, not pushed.

## Next Steps (resume here next session)

**Resume:**

```bash
git checkout main && git pull
git checkout -b feat/phase8-remote-ship
```

- **P8.5 — docs honesty.** Fix false "branch protection" claims in `docs/enforcement.html` + i18n (INCIDENT_004 was the local Gate 1, not remote protection); document the L1/L2/L3 model; remove the obsolete `--no-verify` guidance in `scripts/git-hooks/README.md`.
- **P8.6 — ship the remote layer.** `init-agents` / `install` generate `.github/workflows/gates.yml` + copy `setup-branch-protection.sh` for new projects; add the checklist to `docs/AGENT-ADAPTERS.md`.
- **P8.7 — remote E2E.** `tests/test-remote-enforcement.sh`: broken gate blocks merge, direct push rejected, workflow edit blocked, `core.hooksPath` bypass caught by CI.
- **P8.4 — closed by design** (philosophy A: no self-issued token).
- **Then** — Phase 10 (landing/docs refresh; `README.md` "What's New" still says 6.1.0) and Phase 11 (Astro + Starlight docs site). Backlog: B1/B2/B3 + universal test scoping.

**System state (verified 2026-10-02):**

- Branch protection on `main`: required check `gates`, 0 approvals, code-owner reviews off (solo profile), `enforce_admins: false` → no lockout.
- OpenCode `2.0.20`: global plugin `agent-discipline` = dual-contract **deny** (philosophy A), single active instance.
- Skills: canonical `~/.config/opencode/skills`; `~/.claude/skills` and `~/.gemini/skills` symlink to it.
- Hooks (this repo): pre-commit **v11** (15 gates), commit-msg **v6** (TDD).
- Tests: **53 suites passing** (`bash tests/run-all.sh`).

> Below this section: the previous session's handoff (Phase 7 kickoff + Claude Code Parity, 2026-08-26) — historical.

## What Was Done (2026-08-26)

Closed the Claude Code parity gap inside Task 7.1 — not the full task (that also wants an `agents/`/`commands/` mirror), but the two pieces that make Claude Code actually work automatically end to end:

1. **Global skills, real parity with OpenCode.** `bash install.sh` / `bash install.sh --agent claude` now install all 57 skills into `~/.claude/skills/` (Claude Code's own auto-discovery path), tracked via a manifest so re-installs are safe and never touch unrelated skills already in that directory. Mirrored in `install.ps1`. Fixed a stale `templates/CLAUDE.md` reference that pointed at the OpenCode-only skills path.
2. **Enforcement hooks, made to actually work.** The 3 hooks in `.claude-plugin/agent-discipline/hooks/` (`commit-approval.sh`, `pre-flight.sh`, `edit-guard.sh`) were copied into projects but never wired to anything, and even if wired would not have blocked — they used `exit 1`, but Claude Code's `PreToolUse` block contract requires `exit 2`. Rewrote all three to parse Claude Code's real hook JSON (stdin: `tool_input.command` / `tool_input.file_path`), scope themselves to actually-risky commands (mirroring `.opencode/plugins/agent-discipline/src/lib.ts`'s `isRiskyCommand`/`BLOCKED_COMMANDS`, not the broader manual `scripts/pre-flight.sh`), and use the correct exit codes. `install.sh --agent claude` now merges the matching hooks into `.claude/settings.json` via a `jq`-based, idempotent, additive merge (never replaces the file, never touches a user's own hooks/keys) — same for `install.ps1` via native `ConvertFrom-Json -AsHashtable`/`ConvertTo-Json` (no `jq` needed on Windows). Verified against simulated Claude Code stdin payloads in a throwaway repo (block/allow, dirty-tree, line-count-delta, idempotent re-run, pre-existing-settings.json preservation) — this was **not** end-to-end tested inside a real nested Claude Code session (can't nest one), so treat as "verified in isolation," not "observed live."
3. **Website + docs caught up to reality.** `index.html` (compatible-agents callout, FAQ, meta keywords), `docs/agents.html` (What Works Where table + Claude Code setup copy), `docs/getting-started.html`, `docs/AGENT-ADAPTERS.md` (removed the manual-JSON-wiring instructions I'd written earlier the same day — no longer true), all 4 i18n files (`i18n/{en,es}.json`, `docs/i18n/{en,es}.json`) kept at 100% key parity. Also fixed a pre-existing ES/EN content drift in `faq.a10` (unrelated bonus, found while in there).
4. Ran `code-review-and-quality` on the hook/install diff before the first commit — found and fixed two real issues: a leading-whitespace bypass in the risky-command matcher (indented `git commit` would've skipped the gate), and a misleading error message on PowerShell <6 (blamed "invalid JSON" for what's actually a missing `-AsHashtable` parameter).
5. **After that commit landed, ran a second, full `code-review` pass (effort: high) against it — found 2 bugs that would have made the hooks unusable in practice**, both verified live before trusting the report:
   - `pre-flight.sh` gated `git commit` on a clean working tree — but staged changes (the normal precondition for committing) always show as "dirty" in `git status --porcelain`, so it blocked 100% of commits, always. Fixed: `git commit` is now exempt from the dirty-tree check.
   - `commit-approval.sh` checked `.git/COMMIT_APPROVED`, a token scheme this repo's own current workflow replaced with `.git/DECISION_APPROVED` back in commit-msg v4 — nothing writes the old file anymore, so the gate could never pass. Fixed: now reads `.git/DECISION_APPROVED` with the same 10-min freshness check the real pre-commit hook uses.
   - Also fixed (lower severity, same review): `edit-guard.sh` false-positived a ">20% content drop" warning on every newly-created file (no PreToolUse baseline exists for a file that didn't exist yet). Extracted the duplicated risky-command `case` statements from both hooks into a shared `_risky-commands.sh` (the two lists could previously drift apart silently). Scoped `commit-approval.sh` with `"if": "Bash(git *)"` in the generated `.claude/settings.json` so Claude Code skips spawning it on non-git Bash calls.
   - Added 15 tests total (up from the original 14) covering these fixes directly, including the exact stage-then-commit scenario the bug review caught. 24/24 suites passing.
   - **Lesson for next time:** write the "does this actually let a normal commit through" test *before* wiring a blocking hook into `.claude/settings.json` — the original `tests/test-pre-flight-hook.sh` never staged a file before testing `git commit`, so it never exercised the real-world precondition and gave false confidence.
6. **Pushed the branch, opened PR #34, ran a third review pass — this time `code-review high 34 --comment`, posting findings as inline GitHub PR comments.** Found 3 more real, independently-verified issues, plus the PR's own CI run failed for a related reason:
   - `commit-approval.sh` used GNU-only `date -d` for the DECISION_APPROVED freshness check — errors on macOS/BSD, falls back to epoch 0, blocks every commit as "stale." Same bug class as #16 above, reintroduced on a different platform. Fixed with a GNU/BSD `date` fallback.
   - The risky-command matcher had no word boundary (`git commit-tree` misclassified as `git commit`) and didn't look past the first `;`/`&&`/`||`/`|`-separated segment or a leading `env`/`NAME=value` prefix, so `cd x && git push` and similar everyday compound commands bypassed the gate entirely — not just adversarially, but by ordinary accident. Rewrote `_risky-commands.sh`'s matching as segment-splitting regex instead of a single anchored `case` glob. Documented as still best-effort (matches Claude Code's own stated position on hook command filters), not a hard security boundary.
   - `jq` missing at hook-run time failed completely silently. **This is exactly what happened in the PR's own CI run**: the "quality" job's `.claude/settings.json` assertion failed with the real cause hidden, because `tests/test-install.sh` redirected `install.sh`'s output to a fixed `/tmp` path instead of surfacing it on failure. Fixed both: hooks now print a visible warning when `jq` is missing, the test surfaces `install.sh`'s captured output when the assertion fails, and `.github/workflows/ci.yml` gained an explicit "Ensure jq is available" step so this class of failure can't recur silently.
   - One finding (manifest-tracked skill cleanup doesn't retroactively sweep skills from a *pre-this-PR* OpenCode install) was deliberately left as a documented known limitation rather than fixed — reverting to a blanket sweep would reintroduce the exact "might delete a user's unrelated skill" risk the manifest system exists to prevent.
7. **Pushed, then found the PR's own CI run failing.** The fixed jq-warning + the test's own improved log-surfacing (from the previous point) revealed the real root cause myself, not from a review tool: `scripts/audit-project.sh` was a **git-tracked symlink pointing at an absolute, machine-specific path** — valid on the machine that created it, a dangling symlink on any other checkout, including CI. `install.sh`'s `cp scripts/*.sh` failed on it, and under `set -e` the whole script aborted before ever reaching hook-wiring. Fixed the symlink to be relative; added `tests/test-no-absolute-symlinks.sh` as a permanent regression guard against this whole bug class recurring anywhere in the repo, not just this one file.

## Still Open (Task 7.1 remainder + rest of PLAN.md)

- `.claude/agents/*.md` (8 agents) + `.claude/commands/{start,end}.md` mirroring `.opencode/` — the part of Task 7.1 not touched today.
- Tasks 7.2–7.10 (Cursor mirror, Devin/Kiro update, shared memory, Makefile, `init.sh`, commitlint, docs-auditor gate, docs clarity overhaul, SEO infra) — untouched.
- `.claude-plugin/agent-discipline/` is still not a real auto-discoverable Claude Code plugin (`plugin.json` nested one level too deep per the actual plugin spec) — works today only because `install.sh` merges its hooks directly into `.claude/settings.json`, not via plugin auto-discovery. Restructuring it into a real installable plugin is still open, documented as a known limitation in `docs/AGENT-ADAPTERS.md`.
- Cursor/Kiro adapters unchanged — still manual setup per `docs/AGENT-ADAPTERS.md`.
- 2 pre-existing `skill-lint` warnings (unrelated to this session's work, not investigated).

## Next Steps (resume here next session)

**Resume:** `git checkout fix/opencode-v2-plugin-compat` → read `PLAN.md` (Phase 7 + Backlog).

- **P7.4** — test matrix OpenCode `v1-latest` × `v2-latest`: plugin installs, loads, enforcement active.
- **Docs leftovers** — historical old-path refs in `rules/common/context.md` + `RELEASE-NOTES.md` (non-functional).
- **Backlog** — B1 (init-agents vs sync-hooks hook integrity), B2 (v11 override drift), B3 (tdd-gate false-pass with no code files staged).
- **Then** — Phase 8 (remote enforcement), Phase 9 (distribution).

**System state (verified 2026-09-30):**
- OpenCode `2.0.20`: global plugin `agent-discipline` = dual-contract **deny** (philosophy A), single active instance (no duplicate id).
- Claude: guardrail `~/.claude/hooks/agent-discipline/commit-approval.sh` (**deny**) registered in `~/.claude/settings.json`.
- Skills: canonical `~/.config/opencode/skills` (57 custom + official); `~/.claude/skills` and `~/.gemini/skills` symlink to it.
- Hooks (this repo): pre-commit **v11** (15 gates, via `sync-hooks`), commit-msg **v6** (TDD).
- Tests: **34 suites passing**. Branch tip: `f52c57e`.

## Active Tests

- `tests/test-plan-v7.sh` — validates PLAN.md Phase 7 content
- `tests/test-sync-hooks.sh` — hook infrastructure (git hooks only — unrelated to the Claude Code plugin hooks touched today)
- `tests/test-tdd-gate.sh` — TDD gate infrastructure
- `bash tests/run-all.sh` — 27/27 suites passing after today's changes (including both rounds of review-driven fixes + the self-found CI symlink bug)

## Gate Notes

- TDD: every change needs a matching test in `tests/test-*.sh`
- Pre-commit Gate 14 runs `tests/run-all.sh --changed` (scoped)
- Old tests are in `tests/archived/` — excluded from test runner
