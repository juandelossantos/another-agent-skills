# Session State — v6.3.2 release (B14/B15/B21) · next: T2 + backlog

**Date:** 2026-10-08 (updated)
**Branch:** `release/v6.3.2` (this handoff — the B14/B15/B21 fixes shipped via PR #69).
**Status:** ✅ **PR #69 MERGED (B14/B15/B21, 139/139, CI green).** Gate 11 / `STEERING-GUIDE.md` remediation is now executable in a real project; `generate-health-check.sh` works without AAS headers; `install.sh`'s global dir is complete; `scripts/check-gate-remedies.sh` guards the class. **Releasing v6.3.2** (npm via the release workflow). Prior: Phase 14 SHIPPED (PRs #66/#67/#68), Phase 13 (PR #61).
**Plan:** `PLAN.md` — single source of truth

## Next Session (resume here)

1. **T2** — web + docs update (live): verify the live SEO/`llms.txt`/OG; revisit the **security-headers gap**.
2. **Backlog** — **B13** (`skill-lint` single quotes) · **B15** (Gate 11 remedy) · **B16** (legacy `skills/`) · **B19** (Phase 13 nits) · **B20** (S4 shim risk for a consumer's `scripts/*`).
3. **E1** — essay review/edit → decide.

## Historical handoff — Phase 10 SHIPPED (v6.3.0 web LIVE) + essay drafted
**Pending commit (STAGED, not committed):** the **sequence-rule follow-up** — `PLAN.md` (a new *Regla de secuencia (2026-10-06)* for the B12–B17 lote + Phase 13) and `development/SESSION_STATE.md`, with the updated `tests/task/test-session_state.sh`. Staged on branch **`docs/plan-followup-sequence`** (from `main` @ `30c2e80`). The maintainer runs the commit (Rule 12).

## What Was Done (2026-10-06) — B4–B11 shipped + TDD gate fix (PRs #56–#58)

The courtside-scoreboard P0 backlog (B4–B9) **shipped**, plus B10/B11 and the TDD-gate adoption blocker:

| PR | What | Commit |
|---|---|---|
| **#56** | Plan coherence (Phase 12) + **B4** (`--repair` no data loss) · **B5** (hooks in the effective dir) · **B6** (guardrail v2 `bash`→`shell`) · **B9** (skills discovery) · **B7** (Rule 12 footer) · **B8** (`gh pr merge` blocked) | `3de9e74` |
| **#57** | **B10** (footer upgrade in place — one `init-agents` run brings an existing project up to date) · **B11** (dry-run effective hooks dir) | `695a72f` |
| **#58** | TDD gate: **exempt AAS-managed artifacts in consumers**, keep the framework rigorous (`is_framework_repo` + content-based shim detection); fixed the pre-existing `*.o` over-match (`a.go`/`logo` were ungated) | `2afa8e4` |
| **#59** | **B17 → Phase 13** (type-aware verification gate) + sync the prioritization table; **B12 = NEXT**; extended `SPEC-TDD-GATE.md` (documented the SPEC-vs-code drift) | `30c2e80` |

All merged to `main`; `gates`/`quality`/`CI`/`deploy-web` green. **B6 confirmed live** (the guardrail blocked the agent's `git commit`/`git push`).

**New backlog lote (B12–B17)** — rollout findings, prioritized in `PLAN.md`:

- **B12** 🔴 P0 — Gate 14 runs **lint, not tests** (`grep -A1 '^| Test' | tail -1`) → **false PASS**.
- **B14** 🟠 P1 — `generate-health-check.sh` dies silently (no boundary header) → Gate 11 with no fix path.
- **B17** 🔴 P0 → **Phase 13** (PR #59) — the TDD gate verifies by **name, not type**; redesign to **type-aware verification** (code→test · docs→honesty · config→schema · shim→integration). Spec: `development/SPEC-TDD-GATE.md`.
- **B13** 🟠 P1 — `skill-lint` only strips double quotes (real bug; **scoped** to the linted dir).
- **B15** 🟡 P2 — Gate 11 points to `scripts/generate-health-check.sh`, not installed in the project.
- **B16** 🟡 P2 — `--repair` leaves the legacy `skills/` duplicated with `.claude/skills/`.

## What Was Done (2026-10-05) — Plan coherence + courtside backlog (B4–B9)

After the real-world exercise of updating the skills in **`courtside-scoreboard`**, `PLAN.md` was reorganized for coherence and the findings captured as a prioritized backlog.

1. **Fixed the duplicate "Phase 7":** the planned `v7.0.0` harness phase is now **`## Phase 12: Cross-Platform Harness Parity (v7.0.0) — PLANNED`** (moved after Phase 11; tasks renumbered `12.1–12.10`). One `## Phase 7` remains — the released OpenCode v1/v2 one.
2. **Prioritized the backlog:** added B5–B9 to `Priorización de Pendientes` + a sequence rule (**mechanical first**): **B6 → B5 → B4 → B9 → B7 → B8**.
3. **Corrected B6.3 root cause (verified live):** the OpenCode v2 guardrail plugin **loads** (`active` in `/api/plugin`) but its `execute.before` hook **never evaluates** — it filters by `bash` and **v2 renamed the shell tool to `shell`** (migration doc: *"`bash` is now `shell`"*). Fix: accept both. The contract `{ id, setup }` and `ctx.tool.hook("execute.before", …)` **are** correct in 2.0.23.
4. **New B9:** skills — discovery vs **forced execution**. `skills/` is not an OpenCode discovery path; the startup Protocol references a non-existent `skills/using-agent-skills/SKILL.md` and a `scripts/skill-gate.sh` that `--repair` deletes.
5. **Backlog index** (B1–B9) + coherence notes (B4↔B5↔B9; B7/B8 are **soft** fixes).
6. **New test** `tests/task/test-plan-backlog-coherence.sh` (22 assertions). All `PLAN.md`/`SESSION_STATE.md` content tests green; full core suite **108/109** (the 1 failure, `test-init-agents-source-shim`, is pre-existing and unrelated — `scripts/init-agents.sh` untouched).

### The `courtside-scoreboard` exercise — the P0 findings

| ID | Finding | Priority |
|---|---|---|
| **B6** | Guardrail plugin inert: v2's shell tool is `shell`, the plugin filters by `bash` | 🔴 P0 |
| **B5** | Local hooks inert: `core.hooksPath=.husky/_` with no `.husky/pre-commit` → nothing runs | 🔴 P0 |
| **B4** | `init-agents --repair` deletes `rules/common`, `SOUL.md`, `AGENTS-EXTENDED.md`, `VERSION` + 8 `scripts/*.sh` without recreating them | 🔴 P0 |
| **B9** | Skills: project `skills/` not discoverable; Protocol references broken paths | 🟠 P1 |
| **B7** | Rule 12 not auto-injected into the agent context | 🟠 P1 |
| **B8** | PR review gate has no mechanical trigger | 🟡 P2 |

**Recommended order:** **B6** (1-line fix) → **B5** → **B4** → **B9/B7** → **B8**. Full detail: `PLAN.md` → **Backlog** (B4–B9) + **Priorización de Pendientes**.

## What Was Done (2026-10-03) — Phase 10 shipped + essay drafted

1. **Phase 10 merged + deployed (PR #55 → `main` `1258306`, merged 2026-10-03T23:20:20Z).** GitHub Pages was switched from `legacy` (old root site) to `build_type: workflow`; the merge triggered `deploy-web` → build → deploy → verify (all ✅). The Astro web (landing + docs, EN/ES) is now live.
2. **Deploy workflow** (`.github/workflows/deploy-web.yml`): on push to `main` (or dispatch), builds `web/` (`npm ci` + `npm run build`) and deploys `web/dist` via the official `configure-pages` / `upload-pages-artifact` / `deploy-pages` trio; least-privilege permissions + a `pages` concurrency group; a **post-deploy verify** job curls the live landing (`/`, `/es/`), `/docs/`, a tutorial and `sitemap-index.xml` and **fails loudly** if the site does not serve. Tests: `tests/test-deploy-web-workflow.sh` + `tests/test-distribution-deploy.sh` + `web/tests/deploy-workflow.test.mjs`.
3. **Web LIVE (verified):** `/`, `/es/`, `/docs/`, `/es/docs/`, `/docs/skills/`, `/docs/first-gated-commit/`, `/sitemap-index.xml`, `/robots.txt`, `/llms.txt`, `/og.png` all return **200**; live content confirms the new hero, **151 guides**, **v6.3.0**, **15 agents detected**.
4. **Branch cleaned:** `feat/phase10-landing` deleted locally + remotely; **only `main`** remains.
5. **Essay drafted** (new, awaiting the maintainer's review/edit) — see **E1** and the files in `development/launch/`.

## Exact state (verified 2026-10-03)

- **Branch:** `main` — clean; tip `1258306`; only `main` locally + remotely.
- **Web:** LIVE at https://juandelossantos.github.io/another-agent-skills/ (Pages `build_type: workflow`, status `built`); last `deploy-web` run = **success**.
- **Tests:** core **108 suites passing** (`bash tests/run-all.sh`); web **83 node + 85 e2e** (axe 0).
- **Quality:** Lighthouse **100/100/100/100** (desktop); axe **0** violations.
- **Version:** `VERSION` = **6.3.0**; `npm/package.json` = 6.3.0; **no `v6.3.0` tag yet**.
- Remote enforcement still live: branch protection on `main` requires the `gates` check.
- OpenCode `2.0.20`: global plugin `agent-discipline` = dual-contract **deny** (philosophy A), single active instance.
- Hooks (this repo): pre-commit **v11** (15 gates), commit-msg **v6** (TDD).

## Next tasks (resume here next session)

**⚠️ FIRST (next session) — the B12–B17 lote + the courtside rollout.** The B4–B11 backlog is **done** (PRs #56–#58). Next:

1. **Fix B12** (🔴 P0 — Gate 14 false PASS: parse the exact `| Test |` cell, strip backticks, single-source the parser with `gates.yml`).
2. Then **B14/B17** (adoption) → **B13/B15/B16** (robustness/cleanup). See `PLAN.md` → **Backlog** (B12–B17) + **Priorización**.
3. **Courtside rollout:** branch `chore/aas-portable-refs` (rollout already applied + verified) → commit + push + PR; restart OpenCode and confirm the guardrail blocks `git commit`/`git push`/`gh pr merge`.

**E1 — Essay: review → edit → decide.** Four files in `development/launch/` (the directory is **git-ignored** → local only):
- `essay-human-in-command.en.md` — the article (EN).
- `essay-human-in-command.es.md` — the article (ES, neutral Spanish).
- `essay-hero-image-prompts.md` — 4 hero-image prompt variants (EN + ES) + palette.
- `essay-references-verified.md` — APA-7 reference verification record (18 DOIs checked via Crossref, 2 arXiv, 2 other links).

The maintainer is reviewing/editing these. When done, the open decision is: **(A)** publish on the web as a bilingual essay/blog page, **(B)** track them in git (`git add -f`), **(C)** adapt to LinkedIn / dev.to, or **(D)** leave as-is and move on. Thesis: *AI as assistant; the human as author, critic, and conscience* — grounded in Mitchell, Ghosh & Passi (2026), *AI Agents Push Humans Out of the Loop*.

**T1 — npm activation (DONE) · Homebrew (not planned).** Reference: `docs/DISTRIBUTION.md`.

```bash
npm login
npm profile enable-2fa auth-and-writes     # TOTP (the passkey is browser-only)
cd npm && npm publish --access public      # first publish (done: 6.3.0)
# Trusted Publisher on npmjs.com:
#   GitHub Actions → juandelossantos / another-agent-skills / release.yml / npm-release
#   ("Allow npm publish" UNCHECKED = staged; the publish is chained via workflow_call)
```

The `v6.3.1` CI publish (staged + approved) validated the Trusted Publisher. **Homebrew is not planned** — dropped: a separate repo + PAT secret for a channel npm/curl already cover.

**T2 — Web + docs update (the web is now LIVE).** Point the README + docs at the live URL, drop the "not yet deployed" wording, verify the live SEO/`llms.txt`/OG, and revisit the **security-headers gap** (GitHub Pages ignores `_headers`; decide a meta-CSP or a CDN proxy).

**T3 — Tag `v6.3.0` (DONE).** Shipped: `v6.3.0` + `v6.3.1` tagged; `release.yml` builds/attests assets; the npm publish is chained (staged) and `6.3.1` is live.

## Gated steps (require explicit approval — do NOT run unprompted)

```bash
# tag a release (main is already merged + deployed)
git tag vX.Y.Z && git push origin vX.Y.Z   # release.yml builds/attests; chains the npm stage publish
```

## System state (verified 2026-10-03)

- Phase 10 (public web) **SHIPPED + LIVE**; **`VERSION` is 6.3.2** (covers Phase 8 + 8.1 + 9 + 10 + the 6.3.1 pipeline fixes + the 6.3.2 B14/B15/B21 remediation fixes). The `v6.3.2` tag, the npm publish (**via the release workflow**), and the post-live docs update remain/remained. Homebrew is **not planned**.
- Remote enforcement still live: branch protection on `main` requires the `gates` check.
- OpenCode `2.0.20`: global plugin `agent-discipline` = dual-contract **deny** (philosophy A), single active instance.
- Skills: canonical `~/.config/opencode/skills`; `~/.claude/skills` and `~/.gemini/skills` symlink to it.
- Hooks (this repo): pre-commit **v11** (15 gates), commit-msg **v6** (TDD).
- Tests: **108 suites passing** (`bash tests/run-all.sh`) + web **83 node + 85 e2e** (axe 0).

## What Was Done (2026-10-02) — Phase 9 (previous)

1. **P9.1 — pinned, attested releases** (PR #50): `scripts/build-release.sh` builds `another-agent-skills-vX.Y.Z.tar.gz` + `checksums.txt`; `.github/workflows/release.yml` attests build provenance (`actions/attest-build-provenance`) and publishes the GitHub Release assets.
2. **P9.2 — `bootstrap.sh`** (PR #49): one-line, pinned, checksum-verified install (never a mutable branch); `--version`/`--dry-run`/`--uninstall`; extracts to `$AAS_HOME/<version>` and links `~/.local/bin/aas`.
3. **P9.3 — `bin/aas` CLI**: `install`/`upgrade`/`doctor`/`uninstall`; resolves its own real path through a symlink.
4. **P9.4 — agent selection**: `--agents auto|all|<list>`; prompts only on a TTY, never blocks CI.
5. **P9.7 / P9.7b — portable projects** (PRs #47/#48): no absolute symlinks; `.aas/config` pins the version; `scripts/aas-resolve.sh` resolves the framework cross-platform (`ANOTHER_AGENT_SKILLS_DIR` + per-OS install dirs); hooks are self-resolving shims.
6. **P9.8 — detection/guidance/legacy repair**: `init-agents --dry-run` (mutates nothing), `--repair` (migrate absolute/broken symlinks without losing `AGENTS.md`/team docs), `--force` (explicit for custom hooks); backup hygiene (`.aas/backups/`, gitignored); non-blocking drift notice in `pre-commit`/`doctor`.
7. **P9.5 — npm wrapper** (PR #51): `npm/` ships no payload; `cli.js` downloads + verifies the release and delegates to `bootstrap.sh`. `.github/workflows/npm-publish.yml` publishes via OIDC Trusted Publishing, syncs the version from `VERSION`, and skips if already published (idempotent).
8. **P9.6 — Homebrew** (PR #52): `scripts/build-brew-formula.sh` + an optional tap-update step in `release.yml`, gated on `HOMEBREW_TAP_TOKEN`. **Dropped in 6.3.1** (not planned).
9. **This branch** refreshes `PLAN.md`, `PROGRESS_STATUS.md`, `HEALTH-CHECK.md`, adds `docs/DISTRIBUTION.md`, links it from `README.md`, and adds/updates tests. Not committed, not pushed.

> Below this section: the previous sessions' handoffs (Phase 9 distribution, 2026-10-02, superseded above; Phase 8 closure, 2026-10-02; and Claude Code Parity, 2026-08-26) — historical.

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
