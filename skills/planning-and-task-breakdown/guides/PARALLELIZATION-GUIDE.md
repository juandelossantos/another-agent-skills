# Planning — Parallelization & Anti-Patterns

## Parallelization

Mark tasks with `[S]` (sequential) or `[P]` (parallelizable):

| Marker | Meaning | Example |
|---|---|---|
| `[S]` | Sequential — must wait for dependency | `Task 3: Add database schema [S]` |
| `[P]` | Parallelizable — independent of other `[P]` tasks | `Task 5: Build API endpoint [P]` |
| `[Pm]` | Merge point — wait for all parallel branches | `Task 8: Integration test [Pm]` |

### Rules

- Safe to parallelize: Independent feature slices, tests, docs
- Must be sequential: Database migrations, shared state changes, dependency chains
- Needs coordination: Features sharing an API contract (define contract first, then parallelize)

### Example

```
Task 1: Define API contract [S]       ← must be first
  Task 2: Implement API server [P]    ← parallel with Task 3
  Task 3: Build frontend client [P]   ← parallel with Task 2
  Task 4: Integration tests [Pm]      ← waits for both Task 2 + 3
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll figure it out as I go" | That's how you end up with a tangled mess. 10 min planning saves hours. |
| "The tasks are obvious" | Write them down anyway. Explicit tasks surface hidden dependencies. |
| "Planning is overhead" | Planning is the task. Implementation without a plan is just typing. |
| "I can hold it all in my head" | Context windows are finite. Written plans survive session boundaries. |

## Red Flags

- Starting implementation without a written task list
- Tasks that say "implement the feature" without acceptance criteria
- No verification steps in the plan
- All tasks are XL-sized
- No checkpoints between tasks
- Dependency order isn't considered
- All tasks marked `[P]` with no sequential ones (missing dependency chain)
