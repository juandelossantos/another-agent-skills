# Refactoring Decisions

> **Sources:** Martin Fowler's Refactoring Catalog (refactoring.com) — 60+ named refactoring patterns with mechanics and applicability. Kent Beck's 4 Rules of Simple Design — priority-ordering of simplification decisions.

## Decision: Which Refactoring to Apply?

When you identify a complexity problem, consult the Fowler catalog:

| Problem | Primary Refactoring | Also Consider |
|---|---|---|
| Duplicated code | Extract Function | Parameterize Function |
| Long function | Extract Function | Split Phase, Replace Temp with Query |
| Large conditional | Replace Nested Conditional with Guard Clauses | Replace Conditional with Polymorphism |
| Complex conditional logic | Decompose Conditional | Consolidate Conditional Expression |
| Too many parameters | Introduce Parameter Object | Preserve Whole Object |
| Mutating parameters | Separate Query from Modifier | Remove Setting Method |
| Data clump | Introduce Parameter Object | Extract Class |
| Divergent change | Extract Class | Split Phase |
| Shotgun surgery | Move Function | Move Field, Inline Class |
| Feature envy | Move Function | Move Field |
| Primitive obsession | Replace Primitive with Object | Replace Type Code with Subclasses |
| Switch statement | Replace Conditional with Polymorphism | Replace Type Code with Strategy |
| Parallel inheritance | Replace Subclass with Delegate | Replace Superclass with Delegate |
| Lazy class | Inline Class | Collapse Hierarchy |
| Speculative generality | Inline Function | Remove Dead Code, Collapse Hierarchy |
| Temporary field | Extract Class | Introduce Special Case |
| Message chain | Hide Delegate | Extract Function |
| Middle man | Remove Middle Man | Inline Function |
| Inappropriate intimacy | Move Function | Hide Delegate, Change Bidirectional to Unidirectional |
| Refused bequest | Replace Inheritance with Delegation | Replace Subclass with Delegate |

## Decision: Simplify or Leave Alone?

```
Is the code correct? (tests pass)
├── NO → Fix first (Rule 1)
└── YES → Is the code's intention clear?
    ├── YES → Is there duplication?
    │   ├── YES → Unify (Rule 3)
    │   └── NO → Are there unused elements?
    │       ├── YES → Remove (Rule 4)
    │       └── NO → STOP. Leave it alone.
    └── NO → Can you rename/extract to clarify?
        ├── YES → Do it (Rule 2)
        └── NO → Is the complexity in an abstraction boundary?
            ├── YES → Strengthen or remove abstraction
            └── NO → Apply Extract Function (Rule 3)
```

## Decision: Safe Refactoring or Requires Tests?

| Refactoring Type | Safe Without Tests? | Examples |
|---|---|---|
| Renaming (variable, function) | No — need tests to verify | Rename Field, Rename Variable |
| Extraction (function, variable) | Yes — behavior preserved | Extract Function, Extract Variable |
| Inlining | Yes — behavior preserved | Inline Function, Inline Variable |
| Moving (function, field) | No — references may break | Move Function, Move Field |
| Removing code | No — may have callers | Remove Dead Code |
| Changing signature | No — may change behavior | Change Function Declaration |

## Decision: Refactoring Scale

| Scale | Duration | Verification |
|---|---|---|
| Tiny (rename, extract inline) | Minutes | Run project tests |
| Small (move function, extract class) | 30 minutes | Run project tests + review diff |
| Medium (replace conditional with polymorphism) | 1-2 hours | Run tests per change step |
| Large (split phase, extract class hierarchy) | 2+ hours | Commit after each green test run |

Per Fowler: refactor in small steps. After each change, run tests. If tests go red, undo the last step.

## Anti-Patterns in Refactoring Decisions

1. **Big bang refactoring** — Changing everything at once instead of step by step.
2. **Refactoring without tests** — Changing structure without a safety net.
3. **Over-refactoring** — Applying patterns to code that works fine as-is.
4. **Golden hammer** — Always using polymorphism because it worked once.
5. **Refactoring for hypothetical future** — Building flexibility that will never be used (YAGNI).
