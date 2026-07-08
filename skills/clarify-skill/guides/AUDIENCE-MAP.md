# Clarify — Audience Map

**How to detect audience and tune voice before rewriting.**

## Step 1: Detect Audience

Read these signals in order:

| Signal | Where to find | What it tells you |
|---|---|---|
| `PRODUCT.md` or `README.md` | Project root | Explicit audience: "for developers", "for small business owners" |
| Error messages in codebase | `src/`, error constants | Current voice level: technical ("HTTP 500") vs friendly ("Something went wrong") |
| Page title / meta | `layout.tsx`, `index.html` | Industry: "Dashboard" → B2B, "Shop" → consumer |
| Package dependencies | `package.json` | Technical depth: `prismjs` + `react-syntax-highlighter` → developer audience |
| Design tokens | CSS variables, theme file | Sophistication: muted palette → professional, bright colors → consumer |

## Step 2: Map to Voice

| Detected audience | Tone | Sentence length | Technical terms |
|---|---|---|---|
| **Technical** (developers, IT admins) | Direct, precise | Short-medium | Yes, with explanation |
| **Consumer** (general public) | Friendly, warm | Short | No — "password" not "credential" |
| **Rushed** (mobile, mid-task) | Minimal, imperative | Very short | Only if essential |
| **Anxious** (payment, delete, healthcare) | Reassuring, slow | Longer | Explain everything |
| **Regulated** (finance, healthcare, legal) | Formal, precise | Medium-long | Yes, with disclaimers |

## Step 3: Apply Voice — Examples

### Technical audience

| Before | After |
|---|---|
| "Invalid input" | "Invalid JSON at line 14. Check for trailing comma." |
| "Email" | "Company email (SSO domain required)" |
| "Confirm" | "Delete API key" |

### Consumer audience

| Before | After |
|---|---|
| "Invalid input" | "This doesn't look like a valid email. Try name@company.com." |
| "Email" | "Your email address" |
| "Confirm" | "Delete photo" |

### Rushed audience (mobile, mid-task)

| Before | After |
|---|---|
| "Connection lost. Check your network and try again." | "No connection. Tap to retry." |
| "Upload complete" | "Done ✓" |
| "Are you sure you want to discard?" | "Discard draft?" |

### Anxious audience (payment, healthcare)

| Before | After |
|---|---|
| "Error saving" | "We couldn't save your progress. Your existing data is safe." |
| "Billing address" | "Address on your card (for verification)" |
| "Submit" | "Pay $49.99 — you won't be charged until approval" |

### Regulated audience (healthcare, finance)

| Before | After |
|---|---|
| "Error" | "Session expired for security. Please re-authenticate." |
| "Delete" | "Request record deletion (subject to retention policy)" |
| "Email" | "Official email on file (used for compliance notifications)" |

## Anti-Patterns Per Audience

| Audience | Most common mistake |
|---|---|
| Technical | Using jargon without explanation ("mutate the store") |
| Consumer | Using technical terms ("credential", "authenticate", "payload") |
| Rushed | Full sentences when fragments suffice |
| Anxious | Casual tone that undermines trust ("oops!") |
| Regulated | Friendly tone that suggests no consequences |
