# ADR-005: Native JS Plugin for Agent Discipline

> **Status:** Accepted (COMMIT_APPROVED flow superseded by DECISION_APPROVED + OVERRIDE_APPROVED — see `rules/common/enforcement.md`)
> **Date:** 2026-05-29
> **Deciders:** Agent (architectural proposal) + User (approved implementation)
> **Affected:** AGENTS.md Rule 0f, Rule 0g, `.opencode/plugins/agent-discipline/`, scripts/

---

## Context

Three Rule 12 violations (INCIDENT_001, INCIDENT_002, INCIDENT_003) occurred despite existing safeguards:

| Incident | Problem | Fix Applied |
|---|---|---|
| INCIDENT_001 | Agent committed without approval | Rule 0d: Pre-Action Checklist |
| INCIDENT_002 | Second commit skipped approval | Commit Manifest Protocol |
| INCIDENT_003 | 8 commits bypassed approval gate | Hash-bound COMMIT_APPROVED token |

**Root cause identified:** All safeguards are "rules to remember" not "mechanisms to enforce." The pre-commit hook works for commits (mechanical), but edit-guard, design-gate, and pre-flight remain bypassable.

---

## Decision

### We will implement a Native JS Plugin for OpenCode

Create `.opencode/plugins/agent-discipline/` with event-driven hooks:

| Event | Hook | Behavior |
|---|---|---|
| `file.edited` | edit-guard | Verifies structural markers, line count delta < 20% |
| `tool.execute.before` | pre-flight | Blocks risky commands on dirty working tree |
| `tui.command.execute` | commit-approval | Intercepts git mutations, requires COMMIT_APPROVED token |
| `session.compacted` | anti-slop | Re-injects core principles after context eviction |

### We will NOT

- Replace existing shell scripts (remain as fallback for Claude Code, Cursor)
- Make plugin mandatory (opt-in via installation)
- Add speculative abstractions beyond current requirements

---

## Rationale

### Why event-driven beats remembered rules

INCIDENT_003 proved: 8 commits bypassed the approval gate because the agent was in "fix mode" and interpreted context as exempt from rules. Rules depend on memory; events fire automatically.

### Why OpenCode native plugin

- OpenCode-first philosophy: Built for this ecosystem
- 25+ event types: Covers all critical moments
- Auto-firing: No agent recall needed
- TypeScript: Testable, maintainable code

### Why bundle with skills

Plugin and skills are coupled by design:
- Skills = "what to do" (knowledge)
- Plugin = "when to do it" (enforcement)

Separating them creates gaps where enforcement exists without context.

---

## Consequences

### Positive

- **Auto-enforcement:** Hooks fire automatically, no agent memory required
- **OpenCode-first:** Native integration, no external dependencies
- **Incremental:** Can be installed alongside existing workflow
- **Testable:** TypeScript + unit tests for hooks

### Negative

- **OpenCode-only:** Claude Code and Cursor agents still use shell script fallback
- **Plugin overhead:** Requires OpenCode plugin system (v1.0+)

### Neutral

- Shell scripts remain but become fallback documentation

---

## Implementation Notes

### Distribution

Bundled with skillset installation (`install.sh`), not separate plugin.

### Migration Path

1. Plugin scaffold (v1.3.0)
2. One hook at a time (edit-guard → pre-flight → commit-approval → session-compact)
3. Compare outputs with existing shell scripts
4. Deprecate shell scripts once plugin is verified

### Verification

```bash
# Test edit-guard
# Edit any file → hook verifies markers + line count

# Test pre-flight
# git status (dirty) → run git commit → hook blocks

# Test commit-approval
# Run git commit without COMMIT_APPROVED → hook blocks

# Test session-compact
# Context evicted → reminder message appears
```

---

## References

- INCIDENT_001: `development/INCIDENT_001_RULE12_VIOLATION.md`
- INCIDENT_002: `development/INCIDENT_002_RULE12_RECURRENCE.md`
- INCIDENT_003: `development/INCIDENT_003_RULE12_HASH_BYPASS.md`
- Rule 0f: Plugin Architecture (`AGENTS.md`)
- Rule 0g: Mayéutic Challenge (`AGENTS.md`)
- Plugin: `.opencode/plugins/agent-discipline/`
