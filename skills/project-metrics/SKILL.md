---
name: project-metrics
description: >
  Track empirical quality metrics across all projects and sessions. Logs build pass
  rate, rework rate, test coverage, discovery time, gate pass rate, and user
  override frequency. Use for retrospectives, identifying skill gaps, and
  continuous improvement. Runs automatically in the background — no direct invocation
  needed. Data stored in ~/.config/opencode/quality-metrics.json.
license: MIT
compatibility: opencode
metadata:
  audience: all-engineers
  type: background-service
  frequency: continuous
---

# Project Metrics

**This skill runs automatically in the background. You do NOT invoke it directly.**

It logs empirical quality metrics after every significant action, enabling
retrospectives, trend analysis, and continuous improvement of the agent's
performance.

## Purpose

Without metrics, we claim "quality" but cannot measure it. This skill answers:
- Are our builds passing more often over time?
- How much time do we spend in discovery vs. rework?
- Are our gates catching issues before they reach code?
- Is the user frequently overriding our suggestions?

## When to Log

**Automatic logging triggers:**
- After `npm run build` or equivalent → log Build Result
- After `git commit` → log Commit Quality
- After pre-commit checklist → log Gate Pass/Fail
- After test run → log Test Coverage
- After discovery phase completes → log Discovery Time
- After user override → log Override Reason

**Manual review:** User can say "show metrics" or "quality report" at any time.

---

## Metrics Logged

### 1. Build Pass Rate

```json
{
  "metric": "build",
  "timestamp": "2026-05-24T14:30:00Z",
  "project": "cafe-del-alba",
  "skill_used": "frontend-web",
  "result": "pass",
  "duration_seconds": 45,
  "errors": 0,
  "warnings": 2
}
```

**Purpose:** Track reliability of builds over time.

### 2. Rework Rate

```json
{
  "metric": "rework",
  "timestamp": "2026-05-24T15:00:00Z",
  "project": "cafe-del-alba",
  "skill_used": "frontend-web",
  "type": "revert",
  "reason": "user_changed_requirements",
  "files_affected": 3,
  "time_lost_minutes": 20
}
```

**Types:**
- `revert` — git revert or hard reset
- `fix` — fix commit after initial implementation
- `refactor` — significant refactor within 24h of initial commit
- `user_override` — user said "no, do it differently"

**Purpose:** Identify which skills/phases generate most rework.

### 3. Test Coverage Delta

```json
{
  "metric": "coverage",
  "timestamp": "2026-05-24T16:00:00Z",
  "project": "cafe-del-alba",
  "skill_used": "backend-api-mastery",
  "before": 45.2,
  "after": 62.8,
  "delta": 17.6,
  "tests_added": 8,
  "tests_failed": 0
}
```

**Purpose:** Track if test coverage improves per session.

### 4. Discovery Time

```json
{
  "metric": "discovery",
  "timestamp": "2026-05-24T10:00:00Z",
  "project": "cafe-del-alba",
  "skill_used": "spec-driven-development",
  "duration_minutes": 12,
  "questions_asked": 8,
  "user_confirms": 3,
  "research_queries": 4
}
```

**Purpose:** Optimize discovery efficiency. Too short = missed assumptions. Too long = diminishing returns.

### 5. Gate Pass Rate

```json
{
  "metric": "gate",
  "timestamp": "2026-05-24T17:00:00Z",
  "project": "cafe-del-alba",
  "skill_used": "frontend-web",
  "gate_name": "pre-commit-checklist",
  "result": "pass",
  "checks_total": 12,
  "checks_passed": 12,
  "checks_failed": 0
}
```

**Purpose:** Verify that quality gates are effective. 100% pass = gates too lenient. < 80% = gates too strict or skills not followed.

### 6. User Override Count

```json
{
  "metric": "override",
  "timestamp": "2026-05-24T11:00:00Z",
  "project": "cafe-del-alba",
  "skill_used": "architecture-analysis",
  "override_type": "stack_change",
  "reason": "user_preferred_vue",
  "phase": "architecture_decision",
  "was_agent_correct": true
}
```

**Types:**
- `stack_change` — user rejected proposed stack
- `design_change` — user rejected proposed design
- `scope_change` — user changed scope mid-build
- `skip_gate` — user said "skip the checklist"

**Purpose:** Identify which skills generate most friction. High overrides = skill not aligned with user preferences.

---

## Storage

**Location:** `~/.config/opencode/quality-metrics.json`

**Format:**
```json
{
  "version": "1.0",
  "created_at": "2026-05-24",
  "projects": {
    "cafe-del-alba": {
      "first_session": "2026-05-20",
      "last_session": "2026-05-24",
      "total_sessions": 5,
      "metrics": [
        { "metric": "build", "timestamp": "...", "result": "pass" },
        { "metric": "discovery", "timestamp": "...", "duration_minutes": 12 },
        ...
      ]
    }
  },
  "global": {
    "total_builds": 42,
    "build_pass_rate": 0.88,
    "total_commits": 38,
    "rework_rate": 0.13,
    "average_discovery_minutes": 9.5,
    "gate_pass_rate": 0.91,
    "user_override_rate": 0.08,
    "average_coverage_delta": 14.2
  }
}
```

**Rules:**
- Never include secrets, API keys, or code snippets.
- Only metadata: timestamps, counts, durations, pass/fail.
- Update global aggregates after every logged metric.
- Keep last 90 days of per-project metrics.

---

## How Skills Log Metrics

After any of these actions, the skill MUST call the logging function:

### After Build
```
LOG METRIC: build
- project: [project-name]
- result: pass/fail
- duration: [seconds]
- errors: [count]
```

### After Commit
```
LOG METRIC: commit
- project: [project-name]
- files_changed: [count]
- pre_commit_passed: true/false
```

### After Discovery
```
LOG METRIC: discovery
- project: [project-name]
- duration_minutes: [N]
- questions_asked: [N]
```

### After Gate
```
LOG METRIC: gate
- project: [project-name]
- gate_name: [name]
- result: pass/fail
```

### After User Override
```
LOG METRIC: override
- project: [project-name]
- type: [stack_change/design_change/scope_change/skip_gate]
- reason: [description]
```

---

## Quality Report

When user says "show metrics" or "quality report":

```
📊 QUALITY REPORT — Last 30 Days

Global Metrics:
- Build Pass Rate: 88% (37/42 builds)
- Rework Rate: 13% (5 reverts out of 38 commits)
- Gate Pass Rate: 91% (33/36 gates)
- Avg Discovery Time: 9.5 minutes
- User Override Rate: 8% (3 overrides out of 38 decisions)
- Avg Coverage Delta: +14.2% per session

By Skill:
| Skill | Build Pass | Rework | Overrides |
|---|---|---|---|
| frontend-web | 92% | 10% | 5% |
| backend-api | 85% | 18% | 12% |
| spec-driven | N/A | 5% | 3% |

Trends (Last 7 Days vs Previous 7):
- Build Pass Rate: ↑ 6% (82% → 88%)
- Rework Rate: ↓ 4% (17% → 13%)
- Discovery Time: ↓ 2.3 min (11.8 → 9.5)

→ Your quality is improving. Keep following the gates.
```

---

## Anti-Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "Metrics slow me down." | Metrics are 3 lines of JSON. The insight they provide prevents hours of rework. |
| "I already know I'm good." | Without data, "good" is a feeling. With data, it's a fact you can improve. |
| "The user doesn't care about metrics." | The user cares about results. Metrics help us deliver better results over time. |
| "I'll add metrics later." | Metrics must be logged in the moment. Retroactive logging is guesswork. |

---

## Verification

Evidence that metrics are working:
- `~/.config/opencode/quality-metrics.json` exists and is updated after every session.
- Global aggregates are recalculated after each logged metric.
- No secrets or code in the metrics file.
- Quality report shows meaningful trends (not just raw numbers).
