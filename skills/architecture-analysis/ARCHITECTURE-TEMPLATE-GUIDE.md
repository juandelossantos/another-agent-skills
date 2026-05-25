# Architecture Template Guide

Phase 6 documentation templates for `architecture-analysis`.

## SPEC.md Architecture Section

```markdown
## Architecture Decisions

- **Chosen:** [Option X] — [Name]
- **Date:** YYYY-MM-DD
- **Rationale:** [2-3 sentences referencing user answers]
- **Rejected:**
  - [Option Y] — [why worse for this context]
  - [Option Z] — [why worse for this context]
- **Trade-offs accepted:** [What we knowingly sacrificed]
- **Confidence:** HIGH/MEDIUM/LOW
- **Review trigger:** Revisit when [team size >X, users >Y, etc.]
```

## architecture/ARCHITECTURE.md

```markdown
# Architecture Overview

## Executive Summary
[One paragraph: what we're building, why this architecture fits]

## Stack & Versions
- Frontend: [...]
- Backend: [...]
- Database: [...]
- Auth: [...]
- Hosting: [...]
- Testing: [...]

## Architectural Pattern
[MVC / Hexagonal / Serverless / etc.]
[Brief explanation of how it applies]

## High-Level Structure
```
[Directory tree or component diagram]
```

## Key Decisions
| Decision | Rationale | Date |
|---|---|---|
| [Decision 1] | [Why] | YYYY-MM-DD |

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Risk 1] | High/Med/Low | High/Med/Low | [Action] |

## Migration Path
[If architecture changes later, what does that look like?]
```
