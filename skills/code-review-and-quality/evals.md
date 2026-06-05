# Evals: code-review-and-quality

Pass/fail checks to verify the skill's output meets quality standards.

## Review Quality Checks

| # | Check | Pass Criteria |
|---|---|---|
| 1 | **Severity labels used** | Every finding has a severity label (blocking/important/nit/suggestion/learning/praise) |
| 2 | **TOOL_GAP check** | If verification tools unavailable, reports "ship status unknown" |
| 3 | **Five axes covered** | Review addresses at least 3 of: correctness, readability, architecture, security, performance |
| 4 | **Actionable feedback** | Each finding has a clear "what to change" statement |
| 5 | **No generic comments** | No "looks good" or "LGTM" without evidence |
| 6 | **Edge cases identified** | At least one edge case or boundary condition mentioned |
| 7 | **Security checked** | Security axis explicitly addressed |
| 8 | **Decision made** | Review ends with approve/request-changes/comment |
| 9 | **Evidence provided** | Findings reference specific lines or patterns |
| 10 | **Positive feedback** | At least one praise or learning item included |

## How to Use

After running code-review-and-quality on a PR, verify:

```bash
# 1. Check severity labels exist
grep -c "blocking\|important\|nit\|suggestion\|learning\|praise" review.md || echo "FAIL: No severity labels"

# 2. Check decision is made
grep -c "approve\|request changes\|comment" review.md || echo "FAIL: No decision"

# 3. Check for positive feedback
grep -c "praise\|good\|well done" review.md || echo "FAIL: No positive feedback"
```

## Scoring

- 8-10 checks pass: Review is thorough and actionable
- 5-7 checks pass: Review needs more detail
- <5 checks pass: Review is insufficient
