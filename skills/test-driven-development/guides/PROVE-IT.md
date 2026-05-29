# Prove-It Pattern

For bug fixes, reproduce the bug with a test before attempting a fix. Tests are proof — "seems right" is not done.

## The Prove-It Flow

```
Bug report arrives
       │
       ▼
  Write a test that demonstrates the bug
       │
       ▼
  Test FAILS (confirming the bug exists)
       │
       ▼
  Implement the fix
       │
       ▼
  Test PASSES (proving the fix works)
       │
       ▼
  Run full test suite (no regressions)
```

## Example

```typescript
// Bug: "Completing a task doesn't update the completedAt timestamp"

// Step 1: Write the reproduction test (it should FAIL)
it('sets completedAt when task is completed', async () => {
  const task = await taskService.createTask({ title: 'Test' });
  const completed = await taskService.completeTask(task.id);

  expect(completed.status).toBe('completed');
  expect(completed.completedAt).toBeInstanceOf(Date);  // This fails → bug confirmed
});

// Step 2: Fix the bug
export async function completeTask(id: string): Promise<Task> {
  return db.tasks.update(id, {
    status: 'completed',
    completedAt: new Date(),  // This was missing
  });
}

// Step 3: Test passes → bug fixed, regression guarded
```

## Why This Works

1. **Confirms the bug exists** — A failing test proves the bug is real, not imagined
2. **Documents expected behavior** — The test becomes a specification
3. **Prevents false positives** — Fixing the wrong thing won't make the test pass
4. **Guards against regression** — The test stays forever

## Anti-Pattern: Debug-Then-Fix

```
Bug report arrives
       │
       ▼
  Try random fixes until "it works"
       │
       ▼
  No test → no proof → might break tomorrow
```

This approach has no proof the bug is fixed and no regression protection.
