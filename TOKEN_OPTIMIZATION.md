# Token Optimization Guide (caveman-inspired)

**Adapted from [caveman](https://github.com/JuliusBrussee/caveman) by Julius Brussee.**

**Core insight:** Constraining instructions to be brief improves agent precision and reduces context pollution. We apply caveman compression techniques to **internal instructions** (skills, AGENTS.md), NOT to user-facing communication.

**Target:** 40% reduction in instruction tokens without losing correctness.

---

## Rules

### 1. Drop Filler (Eliminate Empty Words)

**Forbidden phrases** (add zero value):
- "This skill ensures that..."
- "It is important to note that..."
- "You should always remember to..."
- "In order to achieve this goal..."
- "The purpose of this phase is to..."
- "This is a critical step because..."

**Before:**
```markdown
This skill ensures that no endpoint is written until the API contract is fully
 designed, justified, and locked into a durable document.
```

**After:**
```markdown
No endpoint without locked API contract.
```

**Before:**
```markdown
You must always use CSS custom properties from DESIGN.md or globals.css tokens.
Never use hardcoded Tailwind generic colors like bg-blue-500 or text-gray-700.
```

**After:**
```markdown
Use CSS vars from DESIGN.md. No hardcoded Tailwind generics.
```

---

### 2. Use Fragments (Drop Complete Sentences)

**Before:**
```markdown
- NEVER use Inter, Roboto, Arial, Space Grotesk, or Geist as display fonts.
- ALWAYS pair a distinctive display font with a refined body font.
- Use `next/font/google` with CSS variables (`--font-display`, `--font-body`).
```

**After:**
```markdown
Fonts: No Inter/Roboto/Geist for display. Pair distinctive display + refined body.
Use `next/font/google` with `--font-display`, `--font-body`.
```

**Before:**
```markdown
The agent MUST NOT generate code before any written requirements exist.
```

**After:**
```markdown
No code before requirements.
```

---

### 3. Tables Over Lists (Already Good, Make Better)

**Before:**
```markdown
| Protocol | Best For | Avoid When |
|---|---|---|
| **REST** | Standard HTTP, caching, simple CRUD, public APIs | Complex nested queries, real-time needs, tight frontend coupling |
```

**After:**
```markdown
| Protocol | Best For | Avoid |
|---|---|---|
| REST | HTTP, caching, CRUD, public APIs | Nested queries, real-time, tight coupling |
```

**Rule:** If a table cell has > 10 words, compress it.

---

### 4. Eliminate Redundancy with Foundations

**If `engineering-fundamentals` says it, the skill doesn't repeat it.**

**Before (in frontend-web):**
```markdown
## Core Process

### Phase 0 — Language Detection
Detect the language of the user's request immediately. All subsequent communication
MUST be in that same language.

**Detection rules:**
- Spanish keywords (*"haz"*, *"diseña"*) → **Spanish**.
- English keywords (*"build"*, *"design"*) → **English**.
- Other languages → Respond in that language, fallback to English.

**Never mix languages.** All questions, specs, and code comments must match.
```

**After (in frontend-web):**
```markdown
### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.
```

**Savings:** 10+ lines per phase that references fundamentals.

---

### 5. Imperative Voice Only

**Before:**
```markdown
The agent should consider using container queries for component-level responsiveness
rather than relying solely on media queries, which are tied to the viewport size.
```

**After:**
```markdown
Prefer container queries over media queries.
```

---

### 6. One Rule Per Line

**Before:**
```markdown
**Color**
- NEVER use Tailwind generic colors (`bg-blue-500`, `text-gray-700`).
- ALWAYS use CSS custom properties from `DESIGN.md` or `globals.css` tokens.
- Commit to a dominant color with sharp accents. Timid palettes are forbidden.
```

**After:**
```markdown
Color: No Tailwind generics. Use CSS vars. Dominant + sharp accents. No timid palettes.
```

---

## Verification: Did We Lose Correctness?

**If any of these are true, the compression went too far:**
- [ ] An agent following only the compressed version would miss a critical rule
- [ ] A rule that was explicit is now ambiguous
- [ ] A gate/checklist item was removed, not compressed
- [ ] Examples were removed (examples are worth 100 words)

**Anti-rationalization:**
| Excuse | Why It's Wrong |
|---|---|
| "Shorter is always better." | No. Correctness first, brevity second. A 50% shorter skill that misses a security rule is worse, not better. |
| "The agent will figure it out." | No. The agent follows instructions literally. If it's not written, it won't happen. |
| "This sentence is obvious." | If it were obvious, the agent wouldn't need the skill. Every rule exists because an agent violated it without the skill. |

---

## Target Sizes (After Optimization)

| File | Before | Target | Max |
|---|---|---|---|
| AGENTS.md | 360 | 150 | 200 |
| engineering-fundamentals | 180 | 120 | 150 |
| Any skill SKILL.md | 250 | 160 | 200 |
| Any guide | 150 | 100 | 150 |

**Session context with caveman-optimized skills:**
- AGENTS.md: 150
- engineering-fundamentals: 120
- 1 skill: 160
- 1 guide: 100
- **Total: ~530 lines** (~40% reduction from ~890 lines)

---

## What We DON'T Compress

| Type | Why |
|---|---|
| Code examples | Precision-critical. A compressed example is a broken example. |
| Commit messages | User-facing. Must be readable by humans. |
| Error messages | User-facing. Must be clear and actionable. |
| QA checklists | Each item is a gate. Removing items = removing quality. |
| Regex patterns | One character wrong = broken. No compression. |
| URLs and file paths | Byte-preserved. Never shorten. |

---

## Inspiration

**From caveman README:**
> "Caveman only affects output tokens — thinking/reasoning tokens untouched. Caveman no make brain smaller. Caveman make mouth smaller."

**Our adaptation:**
> "Optimization only affects instruction tokens — user-facing communication untouched. We don't make the agent dumber. We make the instruction manual thinner."
