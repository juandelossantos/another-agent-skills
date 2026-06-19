# Clarify Skill — Examples

Detailed before/after examples for each copy category. See `SKILL.md` for process and philosophy.

## 1. Labels & Field Hints

| Before | After | Why |
|---|---|---|
| "Billing address" | "Address on your card" | Matches user's mental model |
| "VAT ID" | "VAT ID (optional, for businesses)" | Reduces anxiety for non-business users |
| "Email" | "Work email" | Sets expectation |
| "Password" | "Password (8+ chars, 1 number)" | Tells requirements upfront |

- Direct, specific, say what is expected
- Optional? Say so inline, not in a separate tag
- If format is constrained, show the constraint, not an error later

## 2. Button Copy

| Before | After | Why |
|---|---|---|
| "Submit" | "Save changes" | Describes outcome |
| "OK" | "Delete 3 files" | Names the consequence |
| "Continue" | "Continue to payment" | Removes ambiguity |
| "Learn more" | "See pricing" | Specificity increases trust |
| "Get started" | "Create your workspace" | Action + object |

- Verb-first: "Save", not "Submission"
- Describe the outcome, not the action: "Subscribe to Pro" not "Click here"
- Never "Submit" or "OK" alone. They are meaningless
- Destructive actions must name the consequence: "Delete account" not "Confirm"

## 3. Error Messages

| Before | After | Why |
|---|---|---|
| "Invalid input" | "This card number is 15 digits. You entered 14." | Specific + fix |
| "Error saving" | "We couldn't save. Check your connection and try again." | What + fix |
| "Access denied" | "You need admin access to delete users. Ask your workspace owner." | Why + next step |
| "Required field" | "Email is required to send the report." | Context + specific |

- Explain what went wrong
- Say whose fault it is (user input? system error? permission?)
- Give the exact next step
- Never blame the user: "this field needs" not "you entered"
- No technical jargon: no "HTTP 500", no "undefined"

## 4. Empty States

| Before | After | Why |
|---|---|---|
| "No items" | "Your inbox is empty. Messages from your team will show up here." | Orients + sets expectation |
| "No results" | "No invoices match "Q4". Try a different search or browse all." | Actionable |
| — | "Your first charge will appear here after your first order." | Prevents confusion |

- Explain WHY the state is empty
- Set expectation for when it will be filled
- Offer a next action if available
- Never leave a blank page with just a header

## 5. Tooltips & Helper Text

| Before | After | Why |
|---|---|---|
| "Click to submit" on Submit button | Remove tooltip | Restates the obvious |
| "Your email address" on email field | (no tooltip, label is enough) | Redundant |
| "Only admins can access this" | "This section is restricted to workspace admins. Contact your admin for access." | Adds info the label can't carry |

- Tooltips must add information the label cannot carry
- If the tooltip restates the label, remove it
- Helper text is for format requirements, exceptions, or audience-specific notes

## 6. Confirmation Dialogs

| Before | After | Why |
|---|---|---|
| "Are you sure?" | "Delete "Q4 Report.xlsx"? This cannot be undone." | Names object + consequence |
| "Confirm" on delete | "Delete 3 files" | Button names the action |
| "Changes will be lost" | "You have unsaved changes. If you leave, they will be discarded." | Clear consequence |

- Name the object being acted on
- Name the consequence
- Button text must match the action ("Delete", not "Confirm")
- Cancel is always an option, clearly labeled "Cancel" or "Keep editing"
