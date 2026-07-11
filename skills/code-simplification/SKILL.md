---
name: code-simplification
description: "Simplify code for clarity without changing behavior. Use when refactoring code that is harder to read or maintain. Do NOT use when behavior must change."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: review-simplify
---

# Code Simplification

**Reduce unnecessary complexity while preserving behavior.**

Complements `code-review-and-quality`. Where code review identifies problems, code simplification fixes them by reducing complexity without changing what the code does.

> **Sources:** Kent Beck's 4 Rules of Simple Design (martinfowler.com/bliki/BeckDesignRules) — passes tests, reveals intention, no duplication, fewest elements in priority order. Martin Fowler's Refactoring Catalog (refactoring.com) — 60+ patterns for improving design. Joel Spolsky's Law of Leaky Abstractions (joelonsoftware.com) — all non-trivial abstractions leak.

## When to Use

- Code is correct but harder to read than necessary
- Abstractions don't earn their complexity
- Functions or components are too large
- Duplicated logic could be unified
- After code review reveals complexity issues

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Simplified source code | Modified source files (any language, any framework) | Existing source tree (in-place) | All tests pass before and after (Rule 1), intention clear from names (Rule 2), no duplicated logic (Rule 3), every element serves a purpose (Rule 4), cyclomatic complexity ≤ 10 per function, cognitive complexity reduced from baseline, structure-only changes (behavior preserved) |

## When NOT to Use

- Behavior must change (use feature implementation skills)
- Only formatting or linting issues (use formatter/linter)
- The code is already as simple as it can be

## Beck's Four Rules of Simple Design

In priority order (Kent Beck, Extreme Programming):

| Priority | Rule | Question to Ask |
|---|---|---|
| 1 | Passes the tests | Does the code work correctly? (If not, stop — fix first) |
| 2 | Reveals intention | Can a reader understand the purpose without comments? |
| 3 | No duplication | Is every concept expressed in exactly one place? |
| 4 | Fewest elements | Does every element (class, method, variable) serve rules 1-3? |

Higher-priority rules override lower ones. A perfectly DRY abstraction that fails tests is worthless.

## Complexity Identification Heuristics

| Heuristic | What to Look For | Likely Fix |
|---|---|---|
| Duplicated logic | Similar code in 3+ places | Extract Function, unify |
| Leaky abstraction | Abstractions that expose internals | Encapsulate, hide delegate |
| Nested conditionals | `if` inside `if` inside `if` | Guard clauses, polymorphism |
| Long function | > 20 lines of visible logic | Extract Function, Split Phase |
| Too many parameters | > 3 parameters | Introduce Parameter Object |
| Dead code | Unused functions, variables | Remove Dead Code |

See `guides/SIMPLIFICATION-HEURISTICS.md` for the full detection catalog.

## Complexity Metrics

Use formal metrics when heuristics are ambiguous or when tracking improvement over time.

### Cyclomatic Complexity (McCabe)

Measures the number of linearly independent paths through a function.

```
M = E - N + 2P
// E = edges (branches), N = nodes (statements), P = connected components
// Each if/else/while/case adds 1 to the count
```

| Score | Risk | Action |
|---|---|---|
| 1-10 | Low | Maintain as-is |
| 11-20 | Moderate | Consider extracting |
| 21-50 | High | Extract or restructure |
| 50+ | Untestable | Must refactor before tests can cover all paths |

### Cognitive Complexity (SonarQube)

Measures how hard code is to *read and understand*, not just path count. Penalizes nesting more than cyclomatic does.

| Factor | Penalty |
|---|---|
| Nesting depth | +1 per level (compounds — a conditional inside a conditional inside a loop is +3) |
| Boolean logic | `&&` and `||` each add +1 |
| Recursion | +1 per recursive call |
| Breakpoints in loops | `break`, `continue`, `catch` each add +1 |

Key difference: cyclomatic counts paths; cognitive counts reading effort. A function with cyclomatic 8 can feel like 30 if it's deeply nested.

### When to Use Each

- **Cyclomatic** — When you need to assess testability or coverage risk
- **Cognitive** — When you need to assess readability or maintenance burden
- **Neither** — For obvious smells (duplicated code, long function), heuristics suffice

## Refactoring Decision Framework

Simplify only when the improvement is measurable:

1. **Is the code correct?** If not, fix tests first (Rule 1).
2. **Is the intention clear?** If not, rename or extract (Rule 2).
3. **Is there duplication?** If yes, unify (Rule 3).
4. **Are there unnecessary elements?** If yes, remove (Rule 4).

See `guides/REFACTORING-PATTERNS.md` for Fowler's catalog mapped to common scenarios.

## Before and After Examples

### Nested Conditionals → Guard Clauses

**Before (cyclomatic: 4, cognitive: 4):**
```python
def process_order(order, user):
    if order is not None:
        if user is not None:
            if order.status == "pending":
                charge_user(user, order.total)
            else:
                raise ValueError("already processed")
        else:
            raise ValueError("user required")
    else:
        raise ValueError("order required")
```

**After (cyclomatic: 3, cognitive: 1):**
```python
def process_order(order, user):
    if order is None: raise ValueError("order required")
    if user is None: raise ValueError("user required")
    if order.status != "pending": raise ValueError("already processed")
    charge_user(user, order.total)
```

See `references/EXAMPLES.md` for full examples (duplicated logic → extract function, flag parameters → separate functions).

## Anti-Patterns

1. **Over-engineering** — Building abstractions for hypothetical future needs (YAGNI).
2. **Premature abstraction** — Extracting a function before there are 3+ uses.
3. **Obfuscation via brevity** — Making code shorter at the cost of clarity (ternary chains, one-letter variables).
4. **Leaky abstractions** — An abstraction that forces users to understand what it hides (Spolsky).
5. **Golden hammer** — Applying a pattern everywhere because it worked once.
6. **Refactoring without tests** — Changing structure without verifying behavior.

## Verification

- [ ] Code passes all tests before and after (Rule 1)
- [ ] Variable and function names reveal intention (Rule 2)
- [ ] No duplicated logic (Rule 3)
- [ ] Every element serves a clear purpose (Rule 4)
- [ ] Refactoring applied from Fowler's catalog, not ad-hoc
- [ ] Abstraction boundaries are clean (no leaky abstractions)
- [ ] Changes limited to structure, not behavior
