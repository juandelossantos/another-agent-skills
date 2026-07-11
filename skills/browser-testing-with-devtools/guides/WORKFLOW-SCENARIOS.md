# Workflow Scenarios

Common browser testing scenarios and the steps for each.

## Scenario 1: Debug a Console Error

1. Navigate to the page URL
2. Open console (or capture console messages via API)
3. Reproduce the action that triggers the error
4. Capture error message, stack trace, line number
5. Report findings with reproduction steps

## Scenario 2: Verify Form Submission

1. Navigate to the form page
2. Fill each form field with valid data
3. Capture network requests (watch for POST to correct endpoint)
4. Submit the form
5. Verify success state (redirect, toast, confirmation message)
6. Capture screenshot of result
7. If error: capture response body and status code

## Scenario 3: Check Responsive Behavior

1. Navigate to the page at desktop width (1440px)
2. Capture screenshot
3. Resize to tablet (768px) — check for breakpoint changes
4. Resize to mobile (375px) — check nav collapse, touch targets
5. Note any layout breaks, overflow, or missing elements

## Scenario 4: Inspect Network Performance

1. Navigate to the page
2. Capture all network requests
3. Identify slow requests (>500ms), large responses (>500KB), or failed requests (4xx/5xx)
4. Check caching headers (Cache-Control, ETag)
5. Report findings with request URLs and timing

## Scenario 5: Verify Visual Consistency

1. Navigate to the page
2. Capture full-page screenshot
3. Compare against expected layout (if baseline exists)
4. Flag visual regressions: overlapping elements, wrong colors, missing content
5. Report with before/after screenshots

## Scenario 6: Test Keyboard Navigation

1. Navigate to the page
2. Tab through all interactive elements
3. Capture focus indicator visibility at each step
4. Note if tab order is logical
5. Report any keyboard traps or invisible focus states
