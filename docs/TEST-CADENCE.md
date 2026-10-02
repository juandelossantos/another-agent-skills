# Test Cadence

> How this repo keeps its test suite honest without an ever-rising ceiling.

## The problem

A single absolute test-count ceiling ("max N test files") fails in two ways:

1. **It ratchets forever.** Every real feature needs tests, so the ceiling gets
   raised again and again. The number stops meaning anything.
2. **It treats all tests as equal.** A behavioral/regression test that protects
   shipped code is fundamentally different from a content assertion that checks
   a doc snapshot for the current phase.

Content assertions written per-file for a doc ("does README still say X?") are
**throwaway tests**: once the phase ships, the assertion is obsolete and only
adds maintenance drag.

## Two classes of tests

| Class | Location | Lifecycle | Counted? |
|---|---|---|---|
| **Behavioral / regression** | `tests/test-*.sh` | Persist — they protect code behavior | **No** |
| **Task (phase/doc/content)** | `tests/task/test-*.sh` | Working set — obsolete per phase | **Yes** |

Both classes are executed by `bash tests/run-all.sh` (and by the pre-commit
Test Runner gate, which calls it with `--changed`). Moving a test into
`tests/task/` therefore never loses coverage — it only changes which budget the
test is charged to.

## The cap (single source of truth)

The ceiling for the TASK working set lives in exactly one place:

```
scripts/test-cadence.conf   →   MAX_TASK_TESTS=20
```

The pre-commit hook (`scripts/git-hooks/pre-commit`) reads that file at run
time. The installed hook is kept in sync with:

```bash
bash scripts/init-agents.sh sync-hooks
```

When the number of `tests/task/*.sh` reaches the cap, the hook prints a
checkpoint warning (it is intentionally a warning, not a hard block — blocking
a commit on test count would make the repo un-committable).

## The cadence

```
hit MAX_TASK_TESTS (20)
        │
        ▼
push + full review          # checkpoint: the batch is reviewed as a unit
        │
        ▼
git mv tests/task/<batch> tests/archived/<phase>/
        │
        ▼
reset the working set       # tests/task/ is empty again; cadence restarts
```

Archived tests are retired: they stay in git history but are **not** discovered
by `tests/run-all.sh`. That is the point — the content they asserted has already
been reviewed and shipped.

## Adding tests

- Protects **code behavior** → put it in `tests/test-<name>.sh` (behavioral,
  persists, not counted).
- Asserts **doc/phase content** → put it in `tests/task/test-<name>.sh` (task,
  counted against `MAX_TASK_TESTS`).

When unsure, prefer **behavioral**: a regression test that outlives its phase is
worth more than a content snapshot, and behavioral tests are never charged to
the cadence budget.

## Reference

- Config: `scripts/test-cadence.conf`
- Hook: `scripts/git-hooks/pre-commit` (Test Count Gate section)
- Runner: `tests/run-all.sh`
- Archive: `tests/archived/`
