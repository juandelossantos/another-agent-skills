# Design Directory

Directory roles for the design workflow. See `DESIGN.md` for the visual contract.

| Directory | Role | Git | Gate |
|---|---|---|---|
| `prototype/` | Throwaway exploration, never committed | Ignored | `approval-gate.sh --approve` to promote to approved |
| `approved/` | Locked, human-approved artifacts | Tracked | Must be referenced in DESIGN.md Section 12 |
| `archive/` | Superseded approved designs (never deleted) | Tracked | Moved from approved/ when superseded |

**Contracts:**
- `DESIGN.md` — 17-section design system contract (validated by `design-gate.sh`)
- `DESIGN-LOCK.md` — Frozen snapshot of approved decisions

**Workflow:**
1. Explore freely in `prototype/` (gitignored, safe)
2. User says "APPROVED" → `approval-gate.sh` promotes to `approved/`
3. DESIGN.md Section 12 updated to reference approved artifact
4. Contract is locked in DESIGN-LOCK.md
5. Build from the locked contract
