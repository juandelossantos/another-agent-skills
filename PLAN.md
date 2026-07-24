# Plan — Another Agent Skills

> **Source of truth** for project roadmap, phases, and status.

---

## Current Status

| Metric | Value |
|---|---|
| Version | **6.0.0** (Phase 6: Design Skill Integrity released) |
| Next target | **v7.0.0** (Phase 7: Cross-Platform Harness Parity) |
| Lint | 0 errors, 0 warnings |
| Health | ✅ HEALTHY |
| Skills | 57 with contracts, When to Use, When NOT to Use |
| Guides | 74 across all skills |
| Tests | 15 suites passing (26 archived, 10 infrastructure active) |

---

## Completed Phases

| Phase | Version | Deliverables |
|---|---|---|
| **0-2** | **v4.0.0** | Foundation Repair & Critical Stubs |
| **QS** | **v4.1.0** | Quick Start Guide, Spanish i18n, nav chain fix |
| **3** | **v4.2.0** | Output Contracts: 57/57, 0 warnings, pre-flight gate |
| **4** | **v5.0.0** | Docs Honesty: 42 issues fixed across 6 groups, 86 files changed |
| **6** | **v6.0.0** | Design Skill Integrity: TDD enforcement (no override), 17-section DESIGN.md schema, 3-mode design-gate, token-validate CSS drift, approval-gate prototype→approved, design dir rules, design-upgrade.sh, direction+platform skill DESIGN.md wiring, critique-skill visual dimensions, prompt drift detection. 35+ commits, 80+ files changed. |

---

## Phase 7: Cross-Platform Harness Parity (v7.0.0)

**Derived from:** deep analysis of [javierpa95/harness](https://github.com/javierpa95/harness)
**Focus fronts:** (A) Easy Dev Docs — clear, practical, discoverable docs
**Focus fronts:** (B) SEO — landing page + docs site optimization

### Task 7.1 — Claude Code `.claude/` Mirror

| Aspect | Scope |
|--------|-------|
| **What** | Create `.claude/` directory with agents/, commands/, skills/, settings.json mirroring `.opencode/` |
| **Files** | New: `.claude/agents/*.md` (8 agents), `.claude/commands/start.md`, `.claude/commands/end.md`, `.claude/settings.json`, `.claude/skills/handoff/SKILL.md` |
| **Docs (A)** | Update `docs/AGENT-ADAPTERS.md` — add `.claude/` path in tables. Update `README.md` agent matrix: Claude Code → ✅ auto. Update `docs/agents.html` |
| **Docs (B)** | Add `CLAUDE.md` to landing page FAQ. Add structured data for Claude Code integration |
| **SEO** | New keywords: "Claude Code", "Anthropic agent", "Claude Code skills" — update meta keywords in all HTML. Add OG tags to `docs/agents.html` |
| **Gate** | pre-commit validates `.claude/` mirrors `.opencode/agents/` |
| **Tests** | adapter test: both `.claude/` and `.opencode/` agent counts match |

### Task 7.2 — Cursor `.cursor/` Mirror

| Aspect | Scope |
|--------|-------|
| **What** | Create `.cursor/rules/` (4 rules), `.cursor/instructions.md`. Update `.cursor-plugin/` to use `.cursor/` instead of symlinks |
| **Files** | New: `.cursor/rules/*.md`, `.cursor/instructions.md`. Updated: `.cursor-plugin/agent-discipline/` |
| **Docs (A)** | Update `docs/AGENT-ADAPTERS.md` Cursor section. Update `docs/getting-started.html` Cursor tab. Update `QUICKSTART.md` |
| **Docs (B)** | Add "Cursor AI", "Cursor agent rules" keywords. Add `.cursor/rules/` path to `docs/agents.html` |
| **SEO** | New FAQ entry: "Does this work with Cursor?" — yes, with `.cursor/rules/`. Link from FAQ → `docs/agents.html#cursor` |
| **Gate** | pre-commit validates `.cursor/rules/` mirrors `.opencode/rules/` |
| **Tests** | adapter test: both directories parse correctly |

### Task 7.3 — Devin/Kiro Config Update

| Aspect | Scope |
|--------|-------|
| **What** | Update `.kiro/hooks/` to match current script paths. Add `.devin/config.md` |
| **Files** | `.kiro/hooks/agent-discipline.json`, new: `.devin/config.md` |
| **Docs (A)** | Update `docs/AGENT-ADAPTERS.md` Devin+Kiro. Add Devin setup to `docs/getting-started.html` |
| **Docs (B)** | New section in `docs/agents.html` for Devin Desktop workflow |
| **SEO** | Keywords: "Devin AI", "Devin Desktop", "Kiro agent" — meta keywords |
| **Gate** | verify `.kiro/hooks/agent-discipline.json` parses as valid JSON |
| **Tests** | install with `bash install.sh --agent kiro`, verify hooks load |

### Task 7.4 — Shared Memory System

| Aspect | Scope |
|--------|-------|
| **What** | Create `agent-memory/` (git-tracked) with per-agent MEMORY.md files |
| **Files** | New: `agent-memory/README.md`, `agent-memory/spec-writer/MEMORY.md`, `agent-memory/code-reviewer/MEMORY.md`, `agent-memory/docs-auditor/MEMORY.md` |
| **Docs (A)** | New `docs/memory.html` — how per-agent memory works. Update `docs/customization.html`, `docs/getting-started.html` |
| **Docs (B)** | "agent memory", "persistent context" keywords in meta. Link from landing page "How It Works" → `docs/memory.html` |
| **SEO** | Dedicated memory page with structured data. Value prop: "<1% of agent frameworks have persistent memory" |
| **Gate** | `agent-memory/README.md` exists and references all agent dirs |
| **Tests** | memory test: create entry, verify agent can read it |

### Task 7.5 — Shared Makefile Control Panel

| Aspect | Scope |
|--------|-------|
| **What** | Create `Makefile` with targets: `make help`, `make skills`, `make gates`, `make check`, `make memory`, `make hooks`, `make health`, `make docs` |
| **Files** | New: `Makefile`. Update: `README.md` commands table |
| **Docs (A)** | Add `make` commands table to `README.md`. "Quick Reference" card on `docs/index.html`. Update `docs/getting-started.html` |
| **Docs (B)** | Landing page "Quick Start": `make help` as first command. Terminal code blocks in `docs/quickstart-guide.html` |
| **SEO** | Low direct. Medium UX (lower bounce rate). `make` code blocks for rich snippets |
| **Gate** | `make help` exits 0 |
| **Tests** | run all targets, verify exit codes |

### Task 7.6 — Interactive `init.sh` Setup

| Aspect | Scope |
|--------|-------|
| **What** | Interactive script: asks project name, type, stack, design system → generates STACK_CONFIG.md, selects skills, installs hooks |
| **Files** | New: `init.sh`, `init.ps1`. Update: `install.sh` (optional delegation) |
| **Docs (A)** | Update `docs/getting-started.html` flow: Install → init.sh → init-agents. Walkthrough in `docs/quickstart-guide.html`. Update `QUICKSTART.md` |
| **Docs (B)** | Hero command: `bash init.sh` (more approachable). "Guided setup" as hero feature |
| **SEO** | "interactive setup", "project scaffolding" keywords. Step-by-step CLI output rich results |
| **Gate** | `bash init.sh --dry-run` exits 0 |
| **Tests** | pipe answers to init.sh, verify generated files exist |

### Task 7.7 — commitlint + Conventional Commits

| Aspect | Scope |
|--------|-------|
| **What** | Add `commitlint` + Husky for THIS repo. Custom `security` commit type. Update `commit-msg` hook to validate conventional commits + TDD |
| **Files** | New: `commitlint.config.js`. Update: `package.json`, `scripts/git-hooks/commit-msg` |
| **Docs (A)** | Update `docs/getting-started.html` commit section. Add conventional commits to `docs/quickstart-guide.html`. Update `CONTRIBUTING.md` |
| **Docs (B)** | Add commit format to `docs/rules.html`. Document `security` type in `docs/enforcement.html` |
| **SEO** | "conventional commits for AI agents" long-tail content depth |
| **Gate** | `npx commitlint --from HEAD~1 --to HEAD` passes |
| **Tests** | good message passes, bad message fails |

### Task 7.8 — Docs-Auditor Pre-Commit Gate

| Aspect | Scope |
|--------|-------|
| **What** | Pre-commit Gate 15: if source files changed, verify corresponding docs updated. Warn-only |
| **Files** | Update: `scripts/git-hooks/pre-commit` (add Gate 15). New: `scripts/verify-docs.sh` |
| **Docs (A)** | Update `docs/enforcement.html` gate list (15→16). Update `i18n/en.json` + `i18n/es.json`. Update `docs/quickstart-guide.html` |
| **Docs (B)** | Landing page hero: "15 gates" → "16 gates". Update `docs/index.html` "What's New". All gate count refs across landing, docs, i18n |
| **SEO** | Gate count increment = content refresh across all pages (recrawl signal). Update SoftwareApplication schema |
| **Gate** | pre-commit runs `scripts/verify-docs.sh`, warns on stale docs |
| **Tests** | update source without updating docs → warning fires |

### Task 7.9 — Dev Docs Clarity Overhaul

| Aspect | Scope |
|--------|-------|
| **What** | Full-text search on `docs/` via client-side JS indexing. 5 concept pages (Guardian Pattern, TDD Gate, Design Gate, Skill Gate, Context Engineering). JSON-LD structured data on ALL docs pages |
| **Files** | Update: `docs/js/docs.js`, `docs/index.html` (search). New: `docs/concepts/guardian-pattern.html`, `tdd-gate.html`, `design-gate.html`, `skill-gate.html`, `context-engineering.html`. ALL `docs/*.html` (structured data) |
| **Docs (A)** | Consistent H1 + meta desc on all pages. Concept pages link to skills, guides, rules. "Related" sections on major pages |
| **Docs (B)** | JSON-LD SearchAction for Sitelinks Search Box. Concept pages target distinct long-tail keywords. Bidirectional link graph: concept → skill → rule → enforcement |
| **SEO** | HIGH — 5 topic-cluster pages interlinking with 57 skill pages. TechArticle/HowTo/FAQ schemas for rich results. Topical authority for "AI agent enforcement" |
| **Gate** | Google Rich Results Test passes for every page. Each concept page has ≥3 internal links |
| **Tests** | batch validate all HTML with structured data linter. 5 search queries return expected results |

### Task 7.10 — SEO Infrastructure

| Aspect | Scope |
|--------|-------|
| **What** | Auto-generated sitemap with hreflang (EN/ES). Core Web Vitals (Lighthouse 90+ all pages). Internal link audit (zero broken links) |
| **Files** | Update: `sitemap.xml`, `robots.txt`, `css/style.css` (inline critical), all HTML (preload, lazy-load). New: `scripts/generate-sitemap.sh` |
| **Docs (A)** | Add hreflang `<link>` tags to all pages. "Related Skills" sections for discoverability |
| **Docs (B)** | Hreflang for bilingual SEO. CWV ranking signals. Hub pages (enforcement.html, lifecycle.html) link to all 57 skills for authority flow |
| **SEO** | HIGH — hreflang for bilingual indexation, CWV as ranking signal, dense internal link graph for topical authority. 70+ pages with zero broken links |
| **Gate** | Lighthouse 90+ all page types. Zero broken internal links. `scripts/generate-sitemap.sh` exits 0 |
| **Tests** | Lighthouse CI batch audit (fail if <85). Broken link auditor on all HTML. Sitemap validates against schema |

---

## Summary

| Metric | Current | Target v7.0.0 |
|---|---|---|
| Platforms | 1 (OpenCode full) | 4 (OpenCode + Claude + Cursor + Devin) |
| Attribution | In README only | Dedicated ATTRIBUTION.md + docs page |
| Memory | Session-only | Per-agent persistent MEMORY.md |
| Makefile | None | Full control panel (10+ targets) |
| Interactive setup | None | `init.sh` guided CLI |
| Docs search | None | Client-side full-text search |
| Concept pages | 0 | 5 standalone concept pages |
| Structured data | 1 page (landing) | All 14+ docs pages |
| Pre-commit gates | 15 | 16 (+ Docs-Auditor) |
| Lighthouse | ~85-95 | 90+ all pages |
| Internal links | Manual | Auto-audited, zero broken |
| Hreflang | None | All pages EN ↔ ES |
| Sitemap | Static | Auto-generated from git |

---

## Release Checklist v7.0.0

- [ ] All 4 platform adapters created and tested (7.1-7.3)
- [ ] Shared agent-memory/ with per-agent MEMORY.md (7.4)
- [ ] Makefile with 10+ targets passing (7.5)
- [ ] init.sh/init.ps1 interactive setup flow tested (7.6)
- [ ] commitlint + conventional commits for this repo (7.7)
- [ ] Docs-Auditor Gate 15 added to pre-commit (7.8)
- [ ] 5 concept pages created with bidirectional link graph (7.9)
- [ ] Structured data on ALL docs pages (7.9)
- [ ] Full-text search on docs/ (7.9)
- [ ] Sitemap auto-generated, hreflang added (7.10)
- [ ] Lighthouse 90+ on all page types (7.10)
- [ ] Zero broken internal links (7.10)
- [ ] i18n EN/ES updated across all new pages
- [ ] Version bumped to 7.0.0
- [ ] Release notes written

---

## Backlog

- Troubleshooting guide
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts
- Polish 31 `## When NOT to Use` sections
- **Configurable test scoping** — `tests/run-all.sh` runs all suites regardless of changed files. On non-Node projects (Arduino, Python, etc.) the TDD gate should detect available test runners, scope to changed files, and skip gracefully if nothing is compatible. Currently hardcoded to this project's structure — Rule 0k violation (not universal).
