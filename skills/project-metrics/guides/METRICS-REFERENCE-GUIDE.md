# Metrics Reference Guide

Complete metric schemas for `project-metrics`.

## 1. Build Pass Rate

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

**Purpose:** Track build reliability over time.

## 2. Rework Rate

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

**Types:** `revert`, `fix`, `refactor`, `user_override`

**Purpose:** Identify skills/phases generating most rework.

## 3. Test Coverage Delta

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

**Purpose:** Track coverage improvement per session.

## 4. Discovery Time

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

## 5. Gate Pass Rate

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

**Purpose:** Verify gates effective. 100% pass = too lenient. <80% = too strict or skills not followed.

## 6. User Override Count

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

**Types:** `stack_change`, `design_change`, `scope_change`, `skip_gate`

**Purpose:** Identify skills generating most friction. High overrides = skill misaligned with user.
