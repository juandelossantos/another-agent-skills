# Promotion Plan — another-agent-skills

> **Version:** v2.5.0 (June 23, 2026)
> **Author:** @JuanDeLosSans
> **Repository:** github.com/juandelossantos/another-agent-skills
> **Landing:** juandelossantos.github.io/another-agent-skills
> **License:** MIT · Open Source · Free forever

---

## Index

1. [Profile Setup (before publishing)](#1-profile-setup)
2. [Pre-launch (1 day before)](#2-pre-launch)
3. [Launch Day](#3-launch-day)
4. [Week 1 Post-Launch](#4-week-1)
5. [Weeks 2-4](#5-weeks-2-4)
6. [Platform-Specific Strategies](#6-platform-specific-strategies)
7. [Daily Checklist](#7-daily-checklist)
8. [Handling Common Comments](#8-handling-common-comments)
9. [Metrics to Track](#9-metrics-to-track)
10. [After Month 1](#10-after-month-1)

---

## 1. Profile Setup

### 1.1 X (Twitter)

Do this **before** posting anything:

- [x] **Profile photo** — Real photo, clear, neutral background. No illustration or AI avatar.
- [x] **Header/banner** — Use landing page screenshot or `assets/og-image.png` (1200×630px).
- [x] **Bio** (160 chars max):
  ```
  57 skills · 12 gates · 0 shortcuts
  Building reliable AI coding agents
  another-agent-skills ⚡
  Frontend 15+ yrs · Chía, Colombia 🇨🇴
  ```
- [x] **URL:** `https://juandelossantos.github.io/another-agent-skills`
- [x] **Location:** Chía, Colombia
- [x] **Follow 20+ accounts** before publishing (so X shows your profile to relevant audiences):
  - @karpathy, @simonw, @theo, @swyx, @leerob, @amasad
  - @midudev, @MoureDev, @DotCSV, @carlosazaustre, @goncy
  - @opencodeai, @anthropics, @github, @Vercel, @Netlify

### 1.2 LinkedIn

- [x] **Headline:** `Senior Frontend & Full-Stack Developer · AI Agent Engineering · another-agent-skills OSS`
- [x] **Featured section:** Add link to landing page with title "another-agent-skills — Open Source Framework for Reliable AI Agents"
- [x] **About:** Last 2 paragraphs mention: *"I created another-agent-skills, an open-source framework that adds mechanical enforcement to AI coding agents — 57 skills, 12 pre-commit gates, zero shortcuts."*
- [x] **Skills section:** AI Agent Engineering, Model Context Protocol (MCP), Agent Skills Design, Context Engineering, Open Source Development

### 1.3 daily.dev

- [x] **Create account** at daily.dev with GitHub login
- [x] **Set interests:** Open Source, AI/ML, Software Development, DevOps
- [x] **Claim your repo:** daily.dev lets you claim repositories. Claim `juandelossantos/another-agent-skills` so it appears under your profile as a creator.
- [x] **Join squads:** Create a "Build with AI" squad or join existing tech squads to share your posts.

### 1.4 dev.to

- [x] **Create account** at dev.to with GitHub login
- [x] **Set up bio:** Link to landing page and GitHub repo
- [x] **Set tags you write about:** opensource, ai, agents, tooling, devops, productivity
- [x] **Follow relevant tags:** ai, agents, opensource, testing, git

---

## 2. Pre-Launch

**Do 1 day before:**

- [x] Verify OG image renders correctly: paste landing page URL into Twitter/LinkedIn composer → must show image + title + description
- [x] Have all launch posts ready in a notes app
- [x] Verify GitHub repo is clean (README up to date, no stale issues)
- [x] Check landing page loads in 3 devices (mobile + desktop + tablet)
- [x] Check both languages (EN/ES toggle) work on landing page
- [x] Review validation gates pass: `bash scripts/eval/test-e2e.sh`
- [x] Charge devices 🔋

---

## 3. Launch Day

### Morning (9-11am Colombia / 14-16 UTC)

Optimal posting window for dev audience on X: 8-10am ET / 14-16 UTC.

#### Step 1: Publish X Thread (10 min)

Tweet 1 — The problem hook:
```
AI agents write good code.

They also ship broken code — same commit, same confidence.

No tests before push. No review before deploy. No process they can't forget when context fills up.

The gap between "impressive demo" and "production-grade" isn't intelligence.

It's mechanical enforcement.

So I built it. 🧵
```

Tweet 2 — The framework:
```
Introducing another-agent-skills:

57 composable skills + 6 harness components.
One install. Any agent.

Define → Plan → Build → Verify → Review → Ship

Each phase has a skill.
Each skill has a gate.
12 pre-commit gates verify before every commit.

Works with Claude Code, Cursor, OpenCode, Copilot, Gemini CLI.
```

Tweet 3 — The real story (builds credibility):
```
I designed a SHA256 token system for commit approval.

Thought it was bulletproof.

Then my agent bypassed it with --auto in < 30 seconds.

The tokens were theater.

Replaced everything with time-window approval:
→ Agent writes approval after you say "yes commit" in chat
→ Hook verifies: file <5 min old? message matches?
→ No tokens. No bypass. No theater.

4 enforcement levels in production.
```

Tweet 4 — The Harness concept (differentiator):
```
Most "AI agent frameworks" are just prompts.

This is a harness: infrastructure around the model.

Level 1 — Process rules (agent remembers)
Level 2 — Visible manifest (DECISION POINT before mutations)
Level 3 — Time-window approval (hook-enforced, <5 min)
Level 4 — Manifest gate (must write .git/COMMIT_MANIFEST first)

Agent = Model + Harness.
```

Tweet 5 — CTA with stats:
```
MIT. Free. Zero subscriptions.

57 skills · 54 guides · 12 pre-commit gates · E2E verified
Stack-agnostic: Node, Python, Rust, Go, anything with git.

→ juandelossantos.github.io/another-agent-skills

Star if you believe agents need process, not just prompts. ⭐

#OpenSource #AIAgents #ClaudeCode #DeveloperTools
```

**How to publish the thread:**
1. Write Tweet 1 in X
2. Click "+" (bottom right) → write Tweet 2
3. Repeat through Tweet 5
4. Attach OG image to Tweet 1
5. Click "Tweet all"

- [ ] **Pin the thread:** 3 dots → Pin to profile
- [ ] **Reply to comments** every 30 min for first 2 hours

#### Step 2: Publish on LinkedIn (10 min)

```
I spent months watching AI agents produce impressive demos that couldn't survive production.

The root cause wasn't capability. It was process.

AI agents are brilliant at generating code. But they have zero built-in discipline:
→ No tests before commit
→ No review before push  
→ No memory of rules they agreed to follow 5 minutes ago

I built Another Agent Skills to bridge that gap.

An open-source framework that adds a complete development lifecycle to any AI coding agent:

Define → Plan → Build → Verify → Review → Ship

With 12 mechanical pre-commit gates, time-window approval (commit-msg hook enforces <5 min freshness), and 57 composable skills loaded on demand.

Key insight: Rules that depend on memory fail. Rules that depend on visible blocks succeed.

Compatible with Claude Code, Cursor, OpenCode, and any git-based agent.

MIT. Free forever. → juandelossantos.github.io/another-agent-skills

If you're building with AI agents: what patterns have you found for keeping them disciplined in production?
```

- [ ] Attach OG image to post
- [ ] Reply to all comments within first 3 hours

#### Step 3: Publish on dev.to (30 min — can be same day or day after)

Write a technical article rather than an announcement:

**Title option A (story-driven):** "How I built mechanical enforcement for AI coding agents — and why prompts aren't enough"
**Title option B (problem-driven):** "Your AI agent will break in production: here's the fix"

Post structure (800-1200 words):
1. **The problem:** AI agents are capable but undisciplined. The METR study found developers 19% slower with AI while feeling 20% faster.
2. **The insight:** Rules an agent "remembers" are suggestions. Rules enforced by hooks are gates.
3. **The solution:** Harness architecture (Agent = Model + Harness) with 6 components.
4. **The implementation:** 57 skills, 12 pre-commit gates, time-window approval.
5. **Code example:** Show the commit-msg hook (30 lines) that blocks unstamped commits.
6. **CTA:** Link to repo, landing page.

- [ ] Tag with: `#opensource`, `#ai`, `#productivity`, `#tooling`, `#devops`
- [ ] Submit to daily.dev via the daily.dev editor or the daily.dev browser extension

#### Step 4: Submit to daily.dev

daily.dev doesn't support direct "project submissions" but you can:

1. **Write on dev.to first** → daily.dev automatically indexes dev.to articles with sufficient engagement
2. **Use daily.dev Squads** → join or create a squad, share your dev.to article there
3. **Ping @dailydevshots** on X with your article link
4. **Ensure your repo has a description and topics on GitHub** — daily.dev indexes GitHub trending repos daily

---

## 4. Week 1

| Day | X | LinkedIn | dev.to/daily.dev |
|---|---|---|---|
| **Day 2** | Quote-tweet @karpathy or @simonw (if they posted about agents). Add your perspective. DO NOT mention project. | — | — |
| **Day 3** | Post quote: *"Rules that depend on memory fail. Rules that depend on visible blocks succeed."* No links, no CTA. Just the idea. | — | — |
| **Day 4** | — | Native article (500-800 words): *"Why AI agents fail in production — and the fix"* (adapt from launch day post) | Publish on dev.to (if not done on launch day) |
| **Day 5** | Thread in Spanish: *"Los agentes de IA escriben código. Y también código quebrado."* Same structure, translated. End with "Creado desde Colombia 🇨🇴". | — | Share dev.to article in daily.dev squad |
| **Day 6-7** | Reply to threads about AI tooling. DO NOT mention project. Just add value. | Reply to comments on your post | Reply to comments on dev.to |

### Spanish Thread (Day 5)

Tweet 1:
```
Los agentes de IA escriben código bueno.

Y también código quebrado — en el mismo commit, con la misma confianza.

Sin tests antes del push. Sin revisión antes del deploy.

El gap entre "demo impresionante" y "producción" no es inteligencia.

Es enforcement mecánico.

Construí algo para eso. 🧵
```

Tweet 2:
```
57 skills + 6 componentes de harness.
Un solo install. Cualquier agente.

Define → Plan → Build → Verify → Review → Ship

Cada fase tiene una skill.
Cada skill tiene un gate.
12 gates de pre-commit verifican antes de cada commit.

Compatible con Claude Code, OpenCode, Cursor.
```

Tweet 3:
```
Creado desde Colombia 🇨🇴. MIT, gratis, open source, sin suscripciones.

→ juandelossantos.github.io/another-agent-skills

#OpenSource #IA #ClaudeCode #DevTools
```

---

## 5. Weeks 2-4

| Week | X | LinkedIn | dev.to/daily.dev |
|---|---|---|---|
| **2** | Thread: "3 violations in 48 hours — the real story" (the incident-driven narrative: how 3 Rule 12 violations led to the 4-level enforcement system) | Short post: "The 7 principles behind Another Agent Skills" (adapt from SOUL.md) | Tutorial: "How commit-approval.sh works in 30 seconds" (screenshot or terminal video) |
| **3** | Poll: "What's your biggest frustration with AI coding agents?" → use replies for future content | Story: "How I built mechanical enforcement for AI agents — from SHA256 theater to time-window approval" | Video demo: terminal walkthrough (60s, terminal + voice) |
| **4** | Milestone post: GitHub stars, forks, thank yous | Carousel PDF: 6 slides showing the lifecycle + enforcement levels | Article: "12 pre-commit gates that saved my production deploys" |

### Week 2 Thread — "3 violations in 48 hours"

```
In 48 hours, my AI agent violated Rule 12 three times.

Each time: it remembered the rule. Until it didn't.

The problem wasn't the model. It was the harness.

Level 1 — rules (agent remembers until context fills up)
Level 2 — visible manifest (agent presents DECISION POINT)
Level 3 — time-window hook (agent cannot bypass — verified by git hook)

Rules that depend on memory fail.
Rules that depend on visible blocks succeed.

Now the agent writes .git/COMMIT_APPROVED only after you say yes.
The hook verifies freshness (<5 min). No tokens. No bypass.

12 pre-commit gates. 57 skills. E2E verified.

This is another-agent-skills. Open source. MIT.
→ juandelossantos.github.io/another-agent-skills
```

---

## 6. Platform-Specific Strategies

### 6.1 X (Twitter)

| What works | What doesn't |
|---|---|
| Threads (4-6 tweets) with story arc | Single link posts with no context |
| Quote-tweeting relevant figures with your take | Mentioning the project in every reply |
| The "problem → insight → solution" narrative | Feature list without a story |
| Posting in English + Spanish (separate days) | Cross-posting the same content twice |
| Engaging within 30 min of posting | Ignoring comments for hours |
| Using 1-2 relevant hashtags only | Hashtag stuffing |

**Best times:** Mon-Thu, 8-10am ET / 14-16 UTC
**Frequency:** 1 thread + 1-2 reply engagements per day max

### 6.2 LinkedIn

| What works | What doesn't |
|---|---|
| Native posts (not imported from X) 500-800 words | Cross-posting X threads verbatim |
| Story-driven: "I built X because Y happened to me" | Just announcing a new version |
| Asking a question at the end to drive comments | Ending without a CTA |
| Posting Tue-Thu morning (most dev traffic) | Posting weekends |
| Adding an image (screenshot, diagram, or carousel) | Text-only posts |

**Best times:** Tue-Thu, 7-9am ET
**Frequency:** 1-2 posts per week max

### 6.3 dev.to

| What works | What doesn't |
|---|---|
| Tutorial-style: "How I built X" with code blocks | Press releases or "check out my project" |
| 800-1200 words with a clear problem/solution arc | Shorter than 500 words (low algorithmic reach) |
| 3-4 code examples or terminal snippets | No code (dev.to readers want technical depth) |
| Tagging 3-4 relevant tags | Tagging 8+ tags |
| Responding to ALL comments on your post | Posting and disappearing |
| Including a GitHub repo link early in the post | Link at the very bottom only |

**Posting cadence:** 1 article per week for first month, then 1-2 per month.
**Submission to daily.dev:** Articles published on dev.to with >5 upvotes get automatically indexed by daily.dev within 24-48 hours.

### 6.4 daily.dev

| What works | What doesn't |
|---|---|
| Having your articles on dev.to (daily.dev indexes them) | Direct "project promotion" posts |
| Squads: sharing content within relevant squads | Spamming the same link in multiple squads |
| Claiming your GitHub repo on your daily.dev profile | No profile setup |
| Engaging with comments on your indexed posts | Ignoring the conversation |

**Mechanism:** daily.dev curates content algorithmically. To increase visibility:
- Write high-quality dev.to articles (daily.dev ranks by engagement)
- Use the daily.dev browser extension to upvote relevant content
- Build your dev.to following (cross-pollinates with daily.dev)
- Ensure your GitHub repo has proper topics (opensource, ai-agents, developer-tools, claude-code)

### 6.5 Hacker News (Show HN)

Only after month 1, and only if X engagement exceeded 50 likes.

**Title format:** `Show HN: Another Agent Skills – 57 skills, 12 gates, mechanical enforcement for AI agents`

**Best time:** 8-10am ET on a weekday (US East Coast morning catches EU afternoon)

**Be ready for HN comments — the audience is technical and direct. Common criticisms:**
- "Why not just use Claude Code's built-in rules?" → Answer: built-in rules work until context degrades. Hooks are mechanical.
- "Another wrapper?" → Answer: it's a skill library + harness, not a wrapper. No proxy, no middleware.
- "This is just for OpenCode" → Answer: works with any git-based agent. Git hooks are universal.

---

## 7. Daily Checklist (10 min/day)

First 4 weeks, each business day:

- [ ] Open X → check notifications → reply to ALL comments
- [ ] Scroll timeline → find relevant posts about AI agents/tooling → reply with genuine perspective (without mentioning project)
- [ ] Open LinkedIn → check notifications → reply to ALL comments
- [ ] Open dev.to → reply to any comments on your articles
- [ ] Log in a notebook: likes today, new followers, new GitHub stars

---

## 8. Handling Common Comments

| Comment | Suggested response |
|---|---|
| "Why not just use Claude Code's built-in rules?" | "Built-in rules work until context degrades. The hook is mechanical — it enforces even when the agent forgets. That's the difference between a suggestion and a gate." |
| "Another wrapper?" | "Not a wrapper. It's 57 composable skills + 6 harness components. Skills define WHAT to do. Harness enforces THAT it's done. No proxy, no middleware." |
| "Does this work with Cursor?" | "Yes. Git hooks work everywhere. For full skill support, there's an adapter guide. Enforcement (pre-commit, commit-msg, approve flow) works out of the box with any git-based agent." |
| "How is this different from other agent frameworks?" | "Most frameworks give you prompts. This gives you process. 12 mechanical gates that run on every commit — not suggestions the agent can forget." |
| "Is this just for OpenCode?" | "No. The skills load natively on OpenCode. But the git hooks (pre-commit, commit-msg) work with ANY git-based agent — Claude Code, Cursor, Copilot, Gemini CLI." |

---

## 9. Metrics to Track

| Metric | Month 1 target | Where to check |
|---|---|---|
| X followers | 50-100 | X profile |
| LinkedIn followers | 30-50 | LinkedIn profile |
| GitHub Stars | 50-100 | github.com/juandelossantos/another-agent-skills |
| dev.to article views | 500-2000 | dev.to dashboard |
| daily.dev impressions | 1000-5000 | daily.dev analytics (from your dev.to cross-posting) |
| Likes per X post | 10-50 | X notifications |
| Reposts per X thread | 5-20 | X notifications |
| LinkedIn comments | 5-15 | LinkedIn notifications |
| dev.to comments | 3-10 | dev.to dashboard |

**If after 2 weeks you see no traction:** the problem isn't the project — it's the message. Change the narrative hook: more personal story, fewer features.

---

## 10. After Month 1

- [ ] Evaluate which posts had most engagement → create more similar content
- [ ] Request inclusion in awesome lists: awesome-claude-code, awesome-ai-agents, awesome-github-projects
- [ ] Publish on Hacker News (Show HN) — only if X post passed 50 likes
- [ ] Write deeper dev.to article: "How I built mechanical enforcement for AI coding agents — the full story"
- [ ] Evaluate if applying to GitHub Trending (needs ~100 stars in 48h)
- [ ] Create 60s demo video (terminal + voice) and publish on X
- [ ] Reach out to 3-5 dev influencers for a mention (no direct ask — offer value first)

## What NOT to Do

- ❌ Post more than once per day on X
- ❌ Mention the project in replies to others (looks like spam)
- ❌ Buy followers
- ❌ Translate technical terms (MCP, agent skills, enforcement, harness)
- ❌ Post without an image (less reach on all platforms)
- ❌ Ignore comments (reply to ALL within 2h)
- ❌ Cross-post literally from X to LinkedIn (adapt tone — LinkedIn is more professional)
- ❌ Post the same content in English and Spanish on the same day (space them 2 days apart)

---

*Document updated: June 23, 2026 · @JuanDeLosSans · github.com/juandelossantos/another-agent-skills*
*Sources: opensource.guide (GitHub), dev.to writing guide, daily.dev docs, LinkedIn best practices*
