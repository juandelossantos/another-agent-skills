# Spec: Roadmap to 10/10

## Objective
Reach 10/10 score by completing remaining architectural gaps in the another-agent-skills ecosystem.

## Current State: 9.6/10

**Achieved:**
- ✅ 13 custom skills (foundation + 3 frontend + backend + 6 process/quality)
- ✅ DRY architecture (engineering-fundamentals as foundation)
- ✅ Multi-platform (web, PWA, mobile)
- ✅ Context persistence (Rule 0b)
- ✅ Lazy loading (Rule 6b)
- ✅ Metrics (project-metrics)
- ✅ Token optimization (caveman-inspired, -19% context)
- ✅ Self-review principle (ADR-001)

## Remaining Work (for 10/10)

### 1. Refactor Remaining Large Skills to Lazy Loading ✅ DONE

| Skill | Before | After | Guides Created |
|---|---|---|---|
| `spec-driven-development` | 484 | 329 | `DISCOVERY-GUIDE.md`, `SPEC-TEMPLATE-GUIDE.md` |
| `fullstack-shipping` | 416 | 307 | `CICD-GUIDE.md`, `DEPLOY-GUIDE.md`, `LAUNCH-CHECKLIST-GUIDE.md` |
| `git-init-and-versioning` | 500 | 356 | `REPO-STRUCTURE-GUIDE.md`, `BRANCHING-GUIDE.md`, `BUILD-INTEGRATION-GUIDE.md` |

**Risk:** These skills have complex, sequential logic (e.g., the 3-step Commit Approval Gate). Extracting requires careful verification that no step is lost.

**Mitigation:** Extract one guide at a time. Verify by reading the new SKILL.md + guide and confirming all original rules are present.

### 2. Create frontend-desktop Skill ✅ DONE

**Scope:** Tauri v2 (Rust + Webview) or Electron (Chromium + Node)
**Estimated size:** ~200 lines + 3 guides
**Value:** Completes frontend coverage (web → PWA → mobile → desktop)
**Result:** 220 lines + DISCOVERY-GUIDE, PLATFORM-GUIDE, EXAMPLES

### 3. Update Documentation

- `LAZY_LOADING.md` — Update status table after all skills refactored
- `README.md` — Reflect final skill count (16? 17?)
- `SESSION_CONTEXT.md` — Final score update

## Boundaries

**In scope:**
- Refactoring existing skills to lazy loading pattern
- Creating frontend-desktop skill
- Documentation updates

**Out of scope:**
- IoT/Embedded skill (niche, post-10.0)
- GameDev skill (niche, post-10.0)
- ML/AI pipelines skill (niche, post-10.0)

## Acceptance Criteria

- [ ] All skills < 250 lines
- [ ] All skills have ≥ 2 guides
- [ ] No implementation detail duplicated between SKILL.md and guides
- [ ] engineering-fundamentals not duplicated in any skill
- [ ] Self-review passed for each skill (correctness verified)
- [ ] Build/install script passes (`install.sh` runs without errors)
- [ ] Score updated to 10.0 in SESSION_CONTEXT.md

## Architecture Decisions

**Decision 1:** Skills Separated (Option B) — Confirmed. Each platform has its own skill.
**Decision 2:** Lazy Loading — Confirmed. Skill as index, guides as lazy content.
**Decision 3:** Self-Review Mandatory — Confirmed. ADR-001 active.
**Decision 4:** Caveman Optimization — Confirmed. Applied successfully to AGENTS.md and frontend skills. Will apply carefully to remaining skills.

## Implementation Order

1. **spec-driven-development** — Extract DISCOVERY-GUIDE.md (highest risk, most complex)
2. **fullstack-shipping** — Extract DEPLOY-GUIDE.md + CI-CD-GUIDE.md
3. **git-init-and-versioning** — Extract BRANCHING-GUIDE.md (Commit Approval Gate MUST survive)
4. **frontend-desktop** — Create from template (low risk, new skill)
5. **Documentation sweep** — Update all docs, verify consistency
6. **Final self-review** — Run checklist on entire ecosystem
7. **Score update** → 10.0
