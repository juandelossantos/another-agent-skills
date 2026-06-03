---
name: project-metrics
description: >
  Track empirical quality metrics across projects and sessions. Logs build pass
  rate, rework, coverage, discovery time, gate pass rate, user overrides.
  Runs automatically — no direct invocation. Data in ~/.config/opencode/quality-metrics.json.
license: MIT
compatibility: opencode
metadata:
  audience: all-engineers
  type: background-service
  frequency: continuous
---

# Project Metrics

**Runs automatically in background. Do NOT invoke directly.**

## When to Use

Automatically in background after every significant action. No direct invocation needed.

Logs empirical quality metrics after every significant action, enabling retrospectives, trend analysis, and continuous improvement.

## Purpose

Without metrics, "quality" is unmeasurable. Answers:
- Builds passing more often over time?
- Time in discovery vs rework?
- Gates catching issues before code?
- User frequently overriding suggestions?

---

## Automatic Logging Triggers

After these actions, skill MUST log:

| Action | Metric Type | Key Fields |
|---|---|---|
| `npm run build` | `build` | result, duration, errors, warnings |
| `git commit` | `commit` | files_changed, pre_commit_passed |
| Pre-commit checklist | `gate` | gate_name, result, checks_passed/failed |
| Test run | `coverage` | before, after, delta, tests_added |
| Discovery phase complete | `discovery` | duration, questions_asked, user_confirms |
| User override | `override` | type, reason, phase, was_agent_correct |

→ **See `METRICS-REFERENCE-GUIDE.md` for complete JSON schemas of all 6 metrics.**

**Manual review:** User says "show metrics" or "quality report" anytime.

---

## Storage

**Location:** `~/.config/opencode/quality-metrics.json`

**Format:**
```json
{
  "version": "1.0",
  "created_at": "2026-05-24",
  "projects": {
    "project-name": {
      "first_session": "2026-05-20",
      "last_session": "2026-05-24",
      "total_sessions": 5,
      "metrics": [
        { "metric": "build", "timestamp": "...", "result": "pass" }
      ]
    }
  },
  "global": {
    "total_builds": 42,
    "build_pass_rate": 0.88,
    "rework_rate": 0.13,
    "avg_discovery_minutes": 9.5,
    "gate_pass_rate": 0.91,
    "user_override_rate": 0.08
  }
}
```

**Rules:**
- Never secrets, API keys, or code snippets.
- Only metadata: timestamps, counts, durations, pass/fail.
- Update global aggregates after every logged metric.
- Keep last 90 days per-project.

---

## Logging Commands

After any action, log with:

```
LOG METRIC: [metric-type]
- project: [project-name]
- [field]: [value]
```

**Examples:**
```
LOG METRIC: build
- project: cafe-del-alba
- result: pass
- duration: 45
- errors: 0
- warnings: 2

LOG METRIC: gate
- project: cafe-del-alba
- gate_name: pre-commit-checklist
- result: pass
- checks_passed: 12
- checks_total: 12

LOG METRIC: override
- project: cafe-del-alba
- type: stack_change
- reason: user_preferred_vue
- phase: architecture_decision
```

---

## Quality Report

→ **See `REPORT-TEMPLATE-GUIDE.md` for presentation format.**

When user requests report, read `quality-metrics.json`, calculate aggregates, present trends.

---

## Anti-Rationalizations

| Excuse | Response |
|---|---|
| "Metrics slow me down." | 3 lines of JSON. Insight prevents hours of rework. |
| "I already know I'm good." | Without data, "good" is a feeling. With data, improvable fact. |
| "User doesn't care about metrics." | User cares about results. Metrics deliver better results. |
| "I'll add metrics later." | Must log in the moment. Retroactive = guesswork. |

---

## Verification

- [ ] `~/.config/opencode/quality-metrics.json` exists and updated after every session.
- [ ] Global aggregates recalculated after each metric.
- [ ] No secrets or code in metrics file.
- [ ] Quality report shows meaningful trends, not just raw numbers.
