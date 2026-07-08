# Clarify — Rewrite Workshop

**6 real scenarios with the thinking process behind each rewrite.**

## Scenario 1: Payment Form

**Before:**

| Field | Label | Error |
|---|---|---|
| Card number | "Card number" | "Invalid input" |
| Expiry | "Expiry" | "Required field" |
| CVC | "CVC" | "Required field" |
| Submit | "Submit" | — |

**Problems:**
- Error messages don't explain what's wrong or how to fix
- "Submit" is meaningless — submit what?
- CVC label is jargon (not all users know "CVC")

**After:**

| Field | Label | Error |
|---|---|---|
| Card number | "Card number" | "This card number is 16 digits. You entered 14." |
| Expiry | "Expiry (MM/YY)" | "Enter a future date, like 12/28." |
| CVC | "Security code (3 digits on back)" | "Check the 3 digits on the back of your card." |
| Submit | "Pay $49.99" | — |

**Thinking:** The user is already anxious about payment. Every error should tell them exactly what to fix, not just that something is wrong. Button text names the monetary consequence, building trust.

## Scenario 2: Delete Confirmation

**Before:**

```
Are you sure? This cannot be undone.

[Cancel] [Confirm]
```

**After:**

```
Delete "Q4 Report.xlsx"?

This will permanently remove the file and its version history. You can't undo this.

[Cancel] [Delete file]
```

**Thinking:** "Are you sure?" is meaningless — the user clicked delete, they're clearly sure. The dialog should name:
1. The object being deleted ("Q4 Report.xlsx")
2. The consequence (permanent, version history lost)
3. The button matches the action ("Delete file", not "Confirm")

## Scenario 3: Search Empty State

**Before:**

```
No results
```

**After:**

```
No invoices match "Q4 revenue"

Try a different search term or browse all invoices.
[Browse all invoices]
```

**Thinking:** "No results" is true but useless. Tell the user:
- What they searched for
- Why there might be nothing
- What they can do next (with a direct action)

## Scenario 4: Permission Denied

**Before:**

```
Access denied
```

**After:**

```
You need admin access to delete team members.

Ask your workspace owner to upgrade your role, or contact support for help.
[Contact support]
```

**Thinking:** "Access denied" blames the user without explanation. Better: explain WHY (need admin), tell them HOW to solve it (ask owner), and give an OUT (contact support).

## Scenario 5: Onboarding Tooltip

**Before:**

```
Click here to get started
```

**After:**

```
Create your first workspace

Invite your team, set billing, and start tracking work in under 2 minutes.
[Create workspace] [Not now]
```

**Thinking:** "Click here" is the weakest call-to-action. "Get started" is vague. Name the action + the object + the time commitment.

## Scenario 6: Multi-Step Form

**Before:**

```
Step 2 of 5

First name: ____
Last name: ____
Email: ____

[Back] [Continue]
```

**After:**

```
Your profile (Step 2 of 5)

First name: ____
Last name: ____
Work email: ____
   ↑ We'll send your invite here

[Back] [Continue to team setup]
```

**Thinking:** "Step 2 of 5" only tells position, not purpose. Add a section title. "Work email" sets expectation (not personal). The helper text reduces hesitation. "Continue" is vague — "Continue to team setup" tells them what's next.
