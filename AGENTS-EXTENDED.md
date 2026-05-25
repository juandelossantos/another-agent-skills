# AGENTS-EXTENDED.md

> **What this is:** Extended reference for rules, tables, and details removed from AGENTS.md for context efficiency.  
> **When to load:** When agent needs full detail on a specific rule, or user asks "what are all the rules?"  
> **How to use:** Reference from AGENTS.md core. Load on-demand only.

---

## Rule 0c: Behavioral Principles (Extended)

### Principle 1: Think Before Coding (Full)

**Don't assume. Don't hide confusion. Surface tradeoffs.**
- State assumptions explicitly. If uncertain, ask rather than guess.
- Present multiple interpretations. Don't pick silently when ambiguity exists.
- Push back when warranted. If a simpler approach exists, say so.
- Stop when confused. Name what's unclear and ask for clarification.
→ Enforced by: `interview-me`, `spec-driven-development`, Rule 0b

### Principle 2: Simplicity First (Full)

**Minimum code that solves the problem. Nothing speculative.**
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If 200 lines could be 50, rewrite it.
**Test:** Would a senior engineer say this is overcomplicated? If yes, simplify.
→ Enforced by: `engineering-fundamentals` Phase 4, `code-simplification`

### Principle 3: Surgical Changes (Full)

**Touch only what you must. Clean up only your own mess.**
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
**Test:** Every changed line should trace directly to the user's request.
→ Enforced by: `git-workflow-and-versioning`, minimal changes rule

### Principle 4: Goal-Driven Execution (Full)

**Define success criteria. Loop until verified.**
Transform imperative tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"
For multi-step tasks, state a brief plan with verification per step.
→ Enforced by: `test-driven-development`, `incremental-implementation`, Rule 9

---

## Rule 1: Skill Hierarchy (Full Table)

| Layer | Skills | Purpose |
|---|---|---|
| **Foundation** | `engineering-fundamentals` | Discovery, contracts, anti-slop, quality gates |
| **Frontend** | `frontend-web`, `frontend-pwa`, `frontend-mobile`, `frontend-desktop` | Web, PWA, native mobile, desktop |
| **Backend** | `backend-api-mastery` | API, DB, auth |
| **DevOps** | `fullstack-shipping` | CI/CD, deploy |
| **Process** | `spec-driven-development`, `architecture-analysis`, `planning-and-task-breakdown` | Planning, analysis |
| **Quality** | `project-health-check`, `code-review-and-quality`, `dev-environment-audit` | Auditing, review |
| **Metrics** | `project-metrics` | Quality logging (background) |
| **Git** | `git-init-and-versioning`, `git-workflow-and-versioning` | Setup, workflow |
| **Debug** | `debugging-and-error-recovery` | Root cause analysis |
| **Ideation** | `idea-refine`, `interview-me` | Brainstorming, requirements |

---

## Rule 3: Project-Type Matrix (Full)

| Project | Required | Optional | Skipped |
|---|---|---|---|
| Landing page | spec, git-init, frontend-web | architecture (light) | backend-api |
| Web app | ALL | — | — |
| Mobile app | spec, git-init, frontend-mobile, backend (if API) | architecture (if complex) | — |
| API only | spec, git-init, architecture, backend, dev-env, shipping | — | frontend-* |
| Existing fix | health-check, spec, debugging | — | architecture, backend |
| Design system | spec, git-init, frontend, dev-env, shipping | architecture | backend-api |
| MVP/prototype | spec (turbo), git-init, frontend | — | architecture, backend (if no API) |
| Database migration | spec, backend, git-init, dev-env | testing | frontend-* |
| CLI tool | spec, git-init, dev-env, shipping | architecture | frontend-* |
| Open source lib | spec, git-init, dev-env, shipping, code-review | — | — |

---

## Rule 6: Lazy Loading (Full Guide List)

**Guides by phase:**
- `DISCOVERY-GUIDE.md` → Phase 1
- `PROTOCOL-GUIDE.md` → Phase 3
- `AUTH-GUIDE.md` → Phase 5
- `ANIMATION-GUIDE.md` → Animation phase
- `TESTING-GUIDE.md` → Testing phase
- `CICD-GUIDE.md` → CI/CD phase
- `DEPLOY-GUIDE.md` → Deploy phase
- `LAUNCH-CHECKLIST-GUIDE.md` → Ship phase
- `EXAMPLES.md` → Troubleshooting
- `BUILD-INTEGRATION-GUIDE.md` → Git workflow

**Verification:**
- [ ] Every skill < 250 lines
- [ ] Every skill references ≥ 2 guides
- [ ] Guides exist as separate files
- [ ] No detail duplicated between SKILL.md and guides
- [ ] `engineering-fundamentals` not duplicated in platform skills

---

## Rule 12: Mutation Approval Gate (Extended)

### What Requires Approval (Full Table)

| Operation | Why It Requires Approval |
|---|---|
| `git commit` | Creates history you cannot erase without force |
| `git push` | Sends local state to remote, affects collaborators |
| `git merge` | Combines branches, can introduce conflicts |
| `git rebase` | Rewrites history, dangerous if pushed already |
| `git reset` | Destroys commits, can lose work permanently |
| `git cherry-pick` | Copies commits, can duplicate or conflict |
| `git revert` | Creates new commit undoing changes |
| `git branch -d` / `-D` | Deletes branch, may lose unmerged work |
| `git tag` | Marks releases, should be deliberate |
| `git stash pop` | Applies stashed changes, can cause conflicts |
| `git clean -fd` | Destroys untracked files, irreversible |
| `git push --force` | Overwrites remote history, **EXTREMELY DANGEROUS** |

### What Does NOT Require Approval

**Safe, read-only operations:**
- `git status`, `git log`, `git diff`, `git show`
- `git branch` (list), `git stash list`
- `git remote -v`, `git config --list`

### User Override (Full)

User can disable this gate by saying:
- "Enable auto commit mode"
- "Don't ask me for commits"
- "Auto-push after commit"
- "I trust you with commits"
- "Allow all git operations"

**If user overrides:**
- Log metric: `LOG METRIC: override` — type: `mutation_approval_gate`
- Document in user profile: `workflow.mutation_approval = "auto_present"` or `"full_auto"`
- Still present mutations, but accept "ok" and "mmhm" as approval
- User can re-enable with: "Require approval again" or "Strict mode"

### Why Absolute by Default

| Without Gate | With Gate |
|---|---|
| "I assumed you wanted to commit" | "You explicitly approved every change" |
| 5 broken commits in a session | 1 clean commit with your knowledge |
| "Why is this in my repo?" | "You saw it before it was committed" |
| Force-pushed lost history | History protected, every mutation approved |

**Anti-rationalization:** "The user seems impatient" → The user will be MORE impatient debugging changes they never approved.

---

## Anti-Rationalization (Full Table)

| Wrong Thought | Why It's Wrong |
|---|---|
| "This is too small for a skill." | Skills exist for structured thinking. |
| "I can just quickly implement this." | Check skills first. |
| "I'll gather context first." | Invoke the skill. It tells you what context to gather. |
| "The user didn't ask for a spec." | The skill decides what the project needs. |
| "I understand what they want." | You have 1% confidence. The skill forces 95%. |
| "Turbo mode means skip everything." | No. Skip OPTIONAL phases, not mandatory ones. |
| "The user chose a different stack, I can't help." | Principles are universal. Examples are specific. |
| "I'll add [quality] later." | Quality is a gate, not an afterthought. Add it now. |
| "The user is impatient, I'll skip [phase]." | The user will be more impatient when the result doesn't match expectations. |
| "I remember the design, I don't need to read files again." | Agent context drifts. Files are ground truth. |
| "I should just pick one interpretation and go." | Silent assumptions cause costly rewrites. State them. |
| "More code = more value." | No. More code = more maintenance, more bugs, more confusion. |
| "I'll improve this adjacent code while I'm here." | Scope creep in diffs. Touch only what the user asked. |
| "Make it work is enough." | Make it work, make it right, make it fast — in that order. |
| "The user already said yes before." | Every commit is a separate decision. Approval does not transfer. |

---

## Rule 9: Verification (Full Checklist)

Before marking any task complete:
- [ ] Applicable skill was invoked
- [ ] Skill workflow followed completely
- [ ] Required artifacts (specs, plans, tests) exist
- [ ] User confirmed at each gate (or Turbo Mode activated)
- [ ] `.gitignore` covers project's stack
- [ ] No `.env` or secrets committed
- [ ] Build passes (`npm run build` or equivalent)
- [ ] No hardcoded tokens outside design system
