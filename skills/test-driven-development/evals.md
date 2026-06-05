# Evals: test-driven-development

Pass/fail checks to verify the skill's output meets quality standards.

## Test Quality Checks

| # | Check | Pass Criteria |
|---|---|---|
| 1 | **Tests exist** | At least one test file created or modified |
| 2 | **Tests are runnable** | `npm test` or equivalent exits 0 |
| 3 | **Tests test behavior** | Tests assert outcomes, not implementation details |
| 4 | **Tests cover edge cases** | At least one test for empty input, error case, or boundary |
| 5 | **Tests are independent** | No shared mutable state between tests |
| 6 | **Tests are named clearly** | Test names describe the scenario and expected outcome |
| 7 | **No empty tests** | No `it('should...')` with empty callback |
| 8 | **RED-GREEN-REFACTOR** | Test was written before implementation (can verify via git log) |
| 9 | **Coverage threshold** | At least 80% line coverage for new code |
| 10 | **No flaky tests** | Tests don't depend on external services or timing |

## How to Use

After implementing code with test-driven-development, run these checks:

```bash
# 1. Verify tests exist
test -f *.test.* || test -f *_test.* || echo "FAIL: No test files found"

# 2. Verify tests pass
npm test || pytest || go test ./... || echo "FAIL: Tests failed"

# 3. Check for empty tests
grep -r "it('.*')" --include="*.test.*" | grep -c "() => {}" || echo "PASS: No empty tests"
```

## Scoring

- 8-10 checks pass: Skill output is high quality
- 5-7 checks pass: Skill output needs improvement
- <5 checks pass: Skill output is insufficient
