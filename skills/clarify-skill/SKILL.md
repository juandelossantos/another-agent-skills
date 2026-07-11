---
name: clarify-skill
description: "Rewrite confusing UX copy so interfaces explain themselves: labels, buttons, errors, empty states, tooltips. Use when users don't understand fields. Do NOT use for marketing copy."
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

**Words are design material, not decoration.** Every word exists to make the interface easier to understand.

- Write from the end user's side: name things by what people control, not how the system is built
- Describe what something does in plain terms: "Save changes" not "Submit"
- Active voice by default: same name through the whole flow
- Errors explain what happened and how to fix it: never apologize, never blame
- Empty states are invitations to act: "Your first message will appear here after you invite a teammate"
- Keep the register conversational but tuned: match tone to audience

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Rewritten UX copy | Text strings | Component source files | Clear, concise, consistent, accessible, audience-tuned, security-safe |

### Security Considerations for Error Messages

Error messages must balance UX clarity with security (OWASP Error Handling Cheat Sheet):

**DO:**
- Tell the user WHAT went wrong in user-friendly terms
- Tell the user HOW to fix it (actionable steps)
- Use consistent error message format across the application

**DON'T:**
- Reveal technical details (stack traces, SQL queries, file paths, server versions)
- Reveal whether a username/email exists (use "Invalid username or password" not "User not found")
- Include database table names, column names, or query syntax
- Expose internal error codes or system architecture

**Examples:**
- ❌ "SQL syntax error at line 42 in query SELECT * FROM users WHERE..."
- ✅ "Invalid input. Please check your entry and try again."
- ❌ "User 'admin' not found in database"
- ✅ "Invalid username or password"
- ❌ "File not found: /var/www/app/config.json"
- ✅ "Something went wrong. Please try again or contact support."

**Log technical details server-side for debugging, but return generic messages to users.**

## When to Use

- Writing feels templated or generic — no deliberate voice
- Users don't understand a field or flow
- Error messages blame the user or don't explain the fix
- Button copy is ambiguous ("Submit", "OK", "Click here")
- Empty states say "No items" with no context
- Tooltips restate the label
- Confirmation dialogs don't name consequences

## When NOT to Use

- Marketing or landing page copy (needs a writer)
- Voice/personality upgrades (use `delight`)
- Content strategy or information architecture

## Process Summary

Read `PRODUCT.md` for audience and tone if available. Otherwise detect audience from context.

| Category | Key rule | See examples |
|---|---|---|
| Labels & Field Hints | Direct, specific, show constraints upfront | → See `guides/EXAMPLES.md` §1 |
| Button Copy | Verb-first, describe outcome, never "Submit" alone | → See `guides/EXAMPLES.md` §2 |
| Error Messages | Explain what + why + fix, never blame | → See `guides/EXAMPLES.md` §3 |
| Empty States | Explain why empty, set expectation, offer action | → See `guides/EXAMPLES.md` §4 |
| Tooltips | Must add info the label can't carry or remove | → See `guides/EXAMPLES.md` §5 |
| Confirmation Dialogs | Name object + consequence, button matches action | → See `guides/EXAMPLES.md` §6 |

## Voice Tuning

→ See `guides/VOICE-TUNING.md` for full audience profiles.

Adjust based on audience: technical (precise), consumer (plain language), rushed (short), anxious (reassuring), regulated (formal).

## Pitfalls

- **Writing cleverer, not clearer** — If copy is already clear, don't change it
- **Skipping audience detection** — Without knowing who reads, rewrites will be generic
- **Running on marketing copy** — Clarify is for functional UX text only

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
- [ ] Error messages don't reveal technical details (OWASP compliance)
- [ ] Error messages don't reveal whether username/email exists
- [ ] Technical details logged server-side, not shown to users
