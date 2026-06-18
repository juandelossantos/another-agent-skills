---
name: clarify-skill
description: >
  Rewrite confusing UX copy so interfaces explain themselves. Covers labels,
  button copy, error messages, empty states, tooltips, and confirmation
  dialogs. Use when users don't understand a field, error messages blame the
  user, or button copy is ambiguous.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-designers
  stack: any
  workflow: evaluate-refine
---

# Clarify Skill

**Rewrite UX copy so interfaces explain themselves.**

Functional text only — labels, errors, instructions, confirmations. Not marketing copy.

## Writing Philosophy

**Words are design material, not decoration.** Every word in an interface exists for one reason: to make it easier to understand, and therefore easier to use. Bring the same intentionality to copy that you bring to spacing and color.

- **Write from the end user's side.** Name things by what people control and recognize, never by how the system is built. A person manages "notifications," not "webhook config."
- **Describe what something does in plain terms.** Being specific is always better than being clever. "Save changes" not "Submit."
- **Active voice by default.** A control says exactly what happens when used. The button "Publish" produces a toast that says "Published." Same name through the whole flow.
- **Errors explain what happened and how to fix it.** Never apologize, never blame, never be vague. "This card number needs 16 digits. You entered 14."
- **Empty states are invitations to act.** "No messages yet" is a dead end. "Your first message will appear here after you invite a teammate" sets expectation.
- **Keep the register conversational but tuned:** plain verbs, sentence case, no filler. Match tone to audience — technical users get precise jargon; consumers get plain language; anxious users get reassurance.

Every element does exactly one job. A label labels, an example demonstrates, and nothing quietly does double duty.

## When to Use

- Writing feels templated or generic — no deliberate voice
- Users don't understand a field or flow
- Error messages blame the user or don't explain the fix
- Button copy is ambiguous ("Submit", "OK", "Click here")
- Empty states say "No items" with no context
- Tooltips restate the label
- Confirmation dialogs don't name consequences

Do NOT use for:
- Marketing or landing page copy (needs a writer)
- Voice/personality upgrades (use `delight`)
- Content strategy or information architecture

## Process

Read `PRODUCT.md` for audience and tone if available. Otherwise detect audience from context.

### 1. Labels & Field Hints

| Before | After | Why |
|---|---|---|
| "Billing address" | "Address on your card" | Matches user's mental model |
| "VAT ID" | "VAT ID (optional, for businesses)" | Reduces anxiety for non-business users |
| "Email" | "Work email" | Sets expectation |
| "Password" | "Password (8+ chars, 1 number)" | Tells requirements upfront |

Rules:
- Direct, specific, say what is expected
- Optional? Say so inline. Not in a separate tag.
- If format is constrained, show the constraint, not an error later.

### 2. Button Copy

| Before | After | Why |
|---|---|---|
| "Submit" | "Save changes" | Describes outcome |
| "OK" | "Delete 3 files" | Names the consequence |
| "Continue" | "Continue to payment" | Removes ambiguity |
| "Learn more" | "See pricing" | Specificity increases trust |
| "Get started" | "Create your workspace" | Action + object |

Rules:
- Verb-first. "Save", not "Submission".
- Describe the outcome, not the action. "Subscribe to Pro" not "Click here".
- Never "Submit" or "OK" alone. They are meaningless.
- Destructive actions must name the consequence: "Delete account" not "Confirm".

### 3. Error Messages

| Before | After | Why |
|---|---|---|
| "Invalid input" | "This card number is 15 digits. You entered 14." | Specific + fix |
| "Error saving" | "We couldn't save. Check your connection and try again." | What + fix |
| "Access denied" | "You need admin access to delete users. Ask your workspace owner." | Why + next step |
| "Required field" | "Email is required to send the report." | Context + specific |

Rules:
- Explain what went wrong
- Say whose fault it is (user input? system error? permission?)
- Give the exact next step
- Never blame the user. No "you entered", say "this field needs"
- No technical jargon (no "HTTP 500", no "undefined")

### 4. Empty States

| Before | After | Why |
|---|---|---|
| "No items" | "Your inbox is empty. Messages from your team will show up here." | Orients + sets expectation |
| "No results" | "No invoices match "Q4". Try a different search or browse all." | Actionable |
| — | "Your first charge will appear here after your first order." | Prevents confusion |

Rules:
- Explain WHY the state is empty
- Set expectation for when it will be filled
- Offer a next action if available
- Never leave a blank page with just a header

### 5. Tooltips & Helper Text

| Before | After | Why |
|---|---|---|
| "Click to submit" on Submit button | Remove tooltip | Restates the obvious |
| "Your email address" on email field | (no tooltip, label is enough) | Redundant |
| "Only admins can access this" | "This section is restricted to workspace admins. Contact your admin for access." | Adds info the label can't carry |

Rules:
- Tooltips must add information the label cannot carry
- If the tooltip restates the label, remove it
- Helper text is for format requirements, exceptions, or audience-specific notes

### 6. Confirmation Dialogs

| Before | After | Why |
|---|---|---|
| "Are you sure?" | "Delete "Q4 Report.xlsx"? This cannot be undone." | Names the object + consequence |
| "Confirm" on delete | "Delete 3 files" | Button names the action |
| "Changes will be lost" | "You have unsaved changes. If you leave, they will be discarded." | Clear consequence |

Rules:
- Name the object being acted on
- Name the consequence
- Button text must match the action ("Delete", not "Confirm")
- Cancel is always an option, clearly labeled "Cancel" or "Keep editing"

## Voice Tuning

Adjust based on audience from PRODUCT.md:

| Audience | Example |
|---|---|
| Technical (developers) | "Invalid JSON at line 14. Check trailing comma." |
| Consumer | "This doesn't look like a valid email. Try name@company.com." |
| Rushed (mobile, mid-task) | "Connection lost. Tapping retry." — short, direct |
| Anxious (payment, delete) | "Your card won't be charged until you confirm." — reassurance |
| Regulated (healthcare, finance) | "Session expired for security. Please re-authenticate." — formal |

## Pitfalls

- **Writing cleverer, not clearer** — If the copy is already clear, don't change it. Use `delight` for personality.
- **Skipping audience detection** — Without knowing who reads, rewrites will be generic.
- **Running on marketing copy** — Clarify is for functional UX text only.

## Related Commands

| Need | Skill |
|---|---|
| Personality + microcopy | `delight` |
| First-run experiences | `onboard` |
| Simplify overloaded UI | `distill` |
| Final polish pass | `polish` |

## QA Gates

- [ ] Writing Philosophy respected — active voice, end-user side, plain terms
- [ ] All labels are specific, not generic
- [ ] No button says "Submit" or "OK" alone
- [ ] Error messages explain what, why, and fix
- [ ] Empty states explain why and what next
- [ ] Tooltips add information (don't restate labels)
- [ ] Confirmation dialogs name object + consequence
- [ ] Voice tuned to audience
- [ ] No "you" blaming in error messages
