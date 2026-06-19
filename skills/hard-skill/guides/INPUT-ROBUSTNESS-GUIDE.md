# Harden Skill — Input Robustness

## Validation Patterns

| Input Type | Validation | Error Message |
|---|---|---|
| Email | Regex + server check | "Enter a valid email (name@domain.com)" |
| Phone | Strip formatting, check length | "Enter 10 digits (including area code)" |
| Number | Min/max bounds | "Enter a value between $min and $max" |
| Date | Past/future constraint | "Date must be in the future" |
| Required | Non-empty after trim | "This field is required" |

## Keyboard Handling

- Enter submits the form
- Escape closes modals/dropdowns
- Tab moves forward, Shift+Tab moves backward
- Arrow keys navigate lists/options
- Space toggles checkboxes, activates buttons

## Error State Requirements

- Error message is associated via `aria-describedby`
- Error is announced to screen readers (`aria-live="assertive"`)
- Focus moves to the first error on submit
- Error persists until the field is valid
- Inline error + visual indicator (icon + border color)
