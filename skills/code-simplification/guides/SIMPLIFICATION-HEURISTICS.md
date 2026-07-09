# Simplification Heuristics

> **Sources:** Kent Beck's 4 Rules of Simple Design (martinfowler.com) — the priority-ordered rules that define simplicity. Joel Spolsky's Law of Leaky Abstractions (joelonsoftware.com) — how abstractions hide complexity. Martin Fowler's Refactoring Catalog (refactoring.com) — named patterns for fixing complexity.

## Duplicated Logic Detection

Duplication is the most common and most fixable form of complexity.

| Pattern | Detection | Fix |
|---|---|---|
| Exact copy | Same code in 3+ places | Extract Function, call from each place |
| Parallel hierarchies | Two class hierarchies change together | Combine or merge via delegation |
| Similar logic | Same algorithm, different types | Parameterize Function |
| Conditional duplication | Same condition checked in multiple places | Consolidate Conditional Expression |

## Leaky Abstraction Detection

Per Spolsky's Law: if users of an abstraction need to understand what it hides, the abstraction is leaky.

| Symptom | What It Means |
|---|---|
| Users read the implementation to understand behavior | Abstraction is not fit for purpose |
| Performance varies wildly based on usage pattern | Abstraction hides important constraints |
| Common operations require workarounds | Abstraction leaks implementation details |
| Debugging requires stepping through internals | Abstraction boundary is wrong |

Fix by either strengthening the abstraction or removing it.

## Nested Complexity Detection

| Pattern | Smell | Simplification |
|---|---|---|
| Arrow code | `if { if { if { } } }` | Guard clauses, early returns |
| Long conditional chain | `if-else if-else if-else` | Replace with polymorphism or map |
| Flag arguments | `process(true, false)` | Separate functions for each mode |
| Switch on type | `switch (type) { case A: case B: }` | Replace Conditional with Polymorphism |

## Variable and State Complexity

| Smell | Fix |
|---|---|
| Mutable state that could be constant | Replace with constant or readonly |
| Variable set once then read | Replace Temp with Query |
| Variable used for two different purposes | Split Variable |
| Derived value stored alongside source | Replace Derived Variable with Query |
| Function modifies parameter | Separate Query from Modifier |

## Function Complexity

| Smell | Threshold | Fix |
|---|---|---|
| Too many parameters | > 3 | Introduce Parameter Object |
| Too many lines | > 20 | Extract Function |
| Too many responsibilities | > 1 obvious purpose | Split Phase, Extract Class |
| Side effects | Modifies something outside scope | Separate Query from Modifier |
| Error codes returned | Return value mixed with error | Replace Error Code with Exception |

## Class Complexity

| Smell | Threshold | Fix |
|---|---|---|
| Too many fields | > 5 that change together | Extract Class |
| Too many methods | > 10 public methods | Likely has multiple responsibilities |
| Large conditional in one method | Switch on type | Replace Conditional with Polymorphism |
| Inheritance depth | > 3 levels | Replace with delegation |
| Overly defensive | Null checks everywhere | Introduce Special Case (Null Object) |
