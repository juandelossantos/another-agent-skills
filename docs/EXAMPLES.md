# Examples: Skills in Action

> **What this is:** Concrete before/after demonstrations of our behavioral principles (AGENTS.md Rule 0c) and workflow rules in action.
>
> **How to use:** When in doubt, copy the "After" pattern. These are the reference implementations.

---

## Example 1: Think Before Coding

### Scenario
User asks: `"Build an e-commerce site."`

### ❌ Before (assumption-driven — violates Principle 1)

Agent immediately starts scaffolding:
- Next.js 14 + React + TypeScript + PostgreSQL + Stripe + Tailwind
- 45 files generated before asking a single question
- Assumes B2C, physical products, US market, mobile-first

**Result:** 3 hours later, user says *"Actually I need a B2B wholesale platform for digital downloads in Spanish."*

---

### ✅ After (explicit reasoning — follows Principle 1)

```
ASSUMPTIONS:
1. Primary user: B2C consumers
2. Core problem: Sell physical products online
3. Scale: MVP (10 products, 100 users/day)
4. Platform: Web-first, mobile-responsive
→ Correct me now or I proceed with these.

DISCOVERY QUESTIONS:
- Products: Physical, digital, or both?
- Payments: Stripe, PayPal, bank transfer?
- Inventory: Real-time tracking or simple counts?
- Shipping: Who handles fulfillment?
- Market: Single country or international?
- Language: English only or multilingual?
- Users: B2C, B2B, or both?
```

**Result:** 5 minutes of questions save 3 hours of rework.

**Skill:** `interview-me`, `spec-driven-development`

---

## Example 2: Simplicity First

### Scenario
User asks: `"Add a button that submits a form."`

### ❌ Before (overengineering — violates Principle 2)

```typescript
// 80+ lines of abstraction for a single button
interface ButtonFactoryProps {
  variant: 'primary' | 'secondary' | 'ghost';
  size: 'sm' | 'md' | 'lg';
  state: 'idle' | 'loading' | 'success' | 'error';
}

class ButtonFactory {
  private config: ButtonFactoryProps;
  constructor(config: ButtonFactoryProps) {
    this.config = config;
  }
  // ... 60 more lines
}

const SubmitButton: React.FC<{ factory: ButtonFactory }> = ({ factory }) => {
  // ... 15 more lines
};
```

**Why it's wrong:** The user asked for a button. Not a design system.

---

### ✅ After (minimal — follows Principle 2)

```html
<button type="submit" class="btn-primary">
  Submit
</button>
```

**Why it's right:** Solves exactly what was asked. No speculative abstractions.

**The test:** Would a senior engineer say *"this is overcomplicated"*? If yes, simplify.

**Skill:** `engineering-fundamentals` Phase 4, `code-simplification`

---

## Example 3: Surgical Changes

### Scenario
User asks: `"Fix the typo in the header."`

### ❌ Before (scope creep — violates Principle 3)

```diff
- <h1>Welcone to our site</h1>
+ <h1>Welcome to our site</h1>

- import { useState } from 'react';
+ import { useState, useCallback } from 'react';

- const Header = () => {
+ const Header: React.FC<HeaderProps> = ({ title, subtitle }) => {

- // TODO: clean this up
+ /**
+  * Header component renders the main navigation
+  * @param title - The main heading
+  * @param subtitle - Optional subheading
+  */

- const navItems = ['Home', 'About'];
+ const navItems = ['Home', 'About', 'Contact', 'Blog'];
```

**Why it's wrong:** 1 line requested. 20+ lines changed. Refactored component, added imports, changed nav, added JSDoc.

---

### ✅ After (surgical — follows Principle 3)

```diff
- <h1>Welcone to our site</h1>
+ <h1>Welcome to our site</h1>
```

**Why it's right:** Exactly 1 line changed. The typo.

**The test:** Every changed line traces directly to the user's request.

**Skill:** `git-workflow-and-versioning`, minimal changes rule

---

## Example 4: Goal-Driven Execution

### Scenario
User asks: `"Add user authentication."`

### ❌ Before (vague — violates Principle 4)

Agent starts coding immediately:
- Creates `auth/` directory
- Installs dependencies
- Writes login form
- No tests, no acceptance criteria
- 2 hours later: *"Does this work?"*

**Result:** Unclear if done. Likely missing edge cases.

---

### ✅ After (verifiable goals — follows Principle 4)

```markdown
## Plan: Add User Authentication

1. **Write test** — invalid credentials → reject
   → verify: test fails (expected)

2. **Implement** — validation logic
   → verify: test passes

3. **Write test** — valid credentials → token issued
   → verify: test fails (expected)

4. **Implement** — token generation
   → verify: test passes

5. **Write test** — token expiration after 24h
   → verify: test fails (expected)

6. **Implement** — expiration logic
   → verify: test passes

7. **Wire to UI** — login form calls auth endpoint
   → verify: E2E test passes

8. **Manual check** — test with real credentials
   → verify: works in browser
```

**Result:** Clear definition of done. Every step verifiable.

**Skill:** `test-driven-development`, `incremental-implementation`, Rule 9

---

## Example 5: Skill-Driven Execution (Rule 1)

### Scenario
User asks: `"Build a landing page."`

### ❌ Before (skips skills — violates Rule 1)

Agent starts coding immediately:
- No spec
- No design tokens
- No stack lock-in
- Generic Tailwind template
- *"Here's your landing page"* — looks like every AI-generated site

**Result:** Unusable output. No differentiation.

---

### ✅ After (skills first — follows Rule 1)

```
Agent: "This matches frontend-web skill. Loading..."

[frontend-web SKILL.md loaded]

1. **Discovery** — "¿Para qué audiencia? ¿B2B o B2C?"
2. **Design** — "Elegí dirección SM (Swiss Minimal). ¿Confirmas?"
3. **Spec** — Generated SPEC.md with stack lock-in
4. **Tokens** — Generated DESIGN.md with colors, typography
5. **Build** — Implemented with locked design tokens

Result: Unique, intentional landing page. Not generic.
```

**Why it's right:** Used the skill. Followed the lifecycle. Locked decisions.

**Skill:** `frontend-web`, `spec-driven-development`

---

## Example 6: Context Persistence (Rule 0b)

### Scenario
User returns after 3 days: `"Continuamos con el proyecto."`

### ❌ Before (starts from zero — violates Rule 0b)

```
User: "Continuamos con el proyecto."
Agent: "¿Qué proyecto?"
User: "El e-commerce que estábamos haciendo."
Agent: "No recuerdo. ¿Me das más detalles?"
```

**Result:** User frustration. Wasted time re-explaining.

---

### ✅ After (auto-recovers — follows Rule 0b)

```
User: "Continuamos con el proyecto."

Agent: [reads design/DESIGN-LOCK.md, SPEC.md]
Agent:
📋 Contexto detectado:
Proyecto: E-commerce B2B
Estado: Phase BUILD (implementando checkout)
Stack: Next.js 14 + PostgreSQL + Stripe
Última actualización: 2026-05-22
→ ¿Continuamos donde lo dejamos?

User: "Sí."
Agent: [reads DESIGN-LOCK.md] → Resume BUILD phase
```

**Result:** Seamless continuation. User feels heard.

**Skill:** AGENTS.md Rule 0b

---

## Example 7: Mutation Approval Gate (Rule 12)

### Scenario
Agent finishes work and wants to commit.

### ❌ Before (assumes approval — violates Rule 12)

```
Agent: "He terminado. Commitando y pusheando..."
[git push origin main]

User: "¿CÓMO? ¡No revisé los cambios!"
```

**Result:** Unwanted changes in production.

---

### ✅ After (explicit approval — follows Rule 12)

```
Agent:
═══════════════════════════════════════════
📝 COMMIT READY FOR REVIEW
═══════════════════════════════════════════

📁 File: src/components/Header.tsx
📊 Changes:
  - Fix typo: "Welcone" → "Welcome"

📝 Commit message:
  fix(header): correct welcome typo

→ Approve? Reply "yes" or "sí" to proceed.
→ Changes needed? Reply "edit" or describe fix.

═══════════════════════════════════════════

User: "sí"
Agent: [commits and pushes]
```

**Result:** User sees every change. No surprises.

**Skill:** `git-init-and-versioning`, Rule 12

---

## How to Use These Examples

### As a User
When the agent violates a principle, reference the example:
> *"This feels like Example 3 — surgical changes. You're touching files I didn't ask about."*

### As an Agent
When confused about which principle applies, reference the scenario:
> *"This is Example 4 — Goal-Driven Execution. I should define tests before implementing."*

### As a Contributor
Adding a new example:
1. Pick a principle or rule
2. Show ❌ Before (the mistake)
3. Show ✅ After (the correct approach)
4. Explain **Why** and reference the enforcing skill

---

## Quick Reference

| Principle | Test Question |
|---|---|
| Think Before Coding | *"Did I state my assumptions explicitly?"* |
| Simplicity First | *"Would a senior say this is overcomplicated?"* |
| Surgical Changes | *"Does every changed line trace to the request?"* |
| Goal-Driven Execution | *"Can I verify this is done without manual testing?"* |

| Rule | Test Question |
|---|---|
| Rule 1 (Skills First) | *"Did I load the relevant skill before implementing?"* |
| Rule 0b (Context) | *"Did I check for existing context files first?"* |
| Rule 12 (Approval) | *"Did I present the commit before executing?"* |

---

**License:** MIT — Part of [another-agent-skills](https://github.com/juandelossantos/another-agent-skills)
