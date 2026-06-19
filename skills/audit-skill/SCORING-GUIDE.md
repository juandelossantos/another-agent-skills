# Audit Skill — Severity Scoring

## Severity Levels

| Level | Label | Definition | Action |
|---|---|---|---|
| P0 | Critical | Blocking user flow, data loss, security vulnerability | Fix before ship. No exceptions. |
| P1 | High | Severe usability issue, major performance regression, accessibility barrier | Fix before next release. |
| P2 | Medium | Visual inconsistency, minor UX friction, suboptimal performance | Fix when in area. Add to backlog. |
| P3 | Low | Polish, nice-to-have, style preference | Document and deprioritize. |

## Decision Matrix

| Factor | P0 | P1 | P2 | P3 |
|---|---|---|---|---|
| Users affected | All | Most | Some | Few |
| Workaround exists | No | No | Yes | Yes |
| Data integrity | Lost | Risk | No risk | No risk |
| Screen reader | Blocked | Degraded | Minor | None |
| Performance | <45fps | <30fps paint | <60fps frame | Over budget |
| Visual | Broken | Extremely off | Off-spec | Preference |
