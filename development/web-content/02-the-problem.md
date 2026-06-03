# 02 — The Problem Section

> Why AI agents fail. Must create urgency before presenting the solution.
> Award-winning sites use contrast: "Here's the broken reality" → "Here's what we built instead."

---

## Purpose

Establish the problem that Another Agent Skills solves:
- Agents commit without tests
- Agents push without review
- Agents produce generic output
- The gap is process, not intelligence

## Structure

```
┌─────────────────────────────────────────────────────┐
│  01 / the problem                                   │
│                                                     │
│  AI agents are capable                             │
│  but undisciplined.                                 │
│                                                     │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐            │
│  │ No tests │  │ No review│  │ Generic │            │
│  │ before   │  │ before   │  │ output  │            │
│  │ commit   │  │ push     │  │ only    │            │
│  └─────────┘  └─────────┘  └─────────┘            │
│                                                     │
│  When developers used AI, they took 19% longer.     │
│  Developers estimated AI saved 20% of the time.    │
│  Experts predicted 38% faster.                     │
│  — Becker et al., METR, July 2025                 │
│                                                     │
│  The gap between "capable" and "reliable"          │
│  is not intelligence. It's process.                │
└─────────────────────────────────────────────────────┘
```

## Content — English

| Element | Content |
|---|---|
| Section label | `01 / the problem` |
| Title | `AI agents are capable but undisciplined.` |
| Problem 1 title | `No tests before commit` |
| Problem 1 desc | `They ship code that looks correct but breaks in production.` |
| Problem 2 title | `No review before push` |
| Problem 2 desc | `They overwrite each other's work without noticing.` |
| Problem 3 title | `Generic output only` |
| Problem 3 desc | `They produce the same patterns regardless of context.` |
| METR quote | `When developers used AI, they took 19% longer. Developers estimated AI saved them 20% of the time. Experts predicted 38% faster.` |
| Conclusion | `The gap between "capable" and "reliable" is not intelligence. It's process.` |

## Content — Español

| Element | Contenido |
|---|---|
| Section label | `01 / el problema` |
| Title | `Los agentes de IA son capaces pero indisciplinados.` |
| Problem 1 title | `Sin tests antes del commit` |
| Problem 1 desc | `Entregan código que parece correcto pero falla en producción.` |
| Problem 2 title | `Sin review antes del push` |
| Problem 2 desc | `Sobreescriben el trabajo de otros sin darse cuenta.` |
| Problem 3 title | `Solo output genérico` |
| Problem 3 desc | `Producen los mismos patrones sin importar el contexto.` |
| METR quote | `Cuando los desarrolladores usaron IA, tardaron 19% más. Los desarrolladores estimaron que la IA les ahorró 20% del tiempo. Los expertos predijeron 38% más rápido.` |
| Conclusion | `La diferencia entre "capaz" y "confiable" no es inteligencia. Es proceso.` |

## Design Tokens

| Token | Value | Usage |
|---|---|---|
| `--font-serif` | Newsreader | Title |
| `--font-sans` | System UI | Problem descriptions, METR quote |
| `--font-mono` | JetBrains Mono | Section label |
| `--accent` | `#DC5C20` (dark) / `#B8450E` (light) | Accent on problem cards |
| `--text` | `#E8E6E3` (dark) / `#2A2826` (light) | Title |
| `--text-secondary` | `#A09E9A` (dark) / `#545250` (light) | Problem descriptions |
| `--bg-card` | `#222220` (dark) / `#F8F7F5` (light) | Problem card backgrounds |
| `--border` | `#2C2A28` (dark) / `#D8D6D2` (light) | Card borders |

## Layout Rules

- Section label: `0.75rem`, mono, muted, uppercase, letter-spacing 0.1em
- Title: `2.5rem`, serif, weight 700
- Problem cards: 3-column grid on desktop, single column on mobile
- Each card: border-left `3px solid var(--accent)`, padding `24px`
- METR quote: italic serif, centered, max-width `700px`
- Conclusion: bold, centered, `1.25rem`
- Section padding: `py-24`

## Anti-Pattern Bans

- ❌ No three equal-sized cards in a row (use border-left accent instead)
- ❌ No gradient backgrounds on cards
- ❌ No icons (use typography only)
- ❌ No "Did you know?" or "Fun fact" preambles

## Animation

- Title: fade-in on scroll (whileInView)
- Problem cards: stagger reveal (100ms delay between each)
- METR quote: fade-in after cards
- Conclusion: fade-in last

## Accessibility

- `<h2>` for title
- Problem cards use `<div>` with `role="listitem"` pattern
- METR quote uses `<blockquote>` with `<cite>`
- Sufficient contrast on all text (verified in DESIGN-LOCK.md)

## i18n Keys

```json
{
  "problem": {
    "label": "01 / the problem",
    "title": "AI agents are capable but undisciplined.",
    "card1Title": "No tests before commit",
    "card1Desc": "They ship code that looks correct but breaks in production.",
    "card2Title": "No review before push",
    "card2Desc": "They overwrite each other's work without noticing.",
    "card3Title": "Generic output only",
    "card3Desc": "They produce the same patterns regardless of context.",
    "metr": "When developers used AI, they took 19% longer. Developers estimated AI saved them 20% of the time. Experts predicted 38% faster.",
    "metrSource": "— Becker et al., METR, July 2025",
    "conclusion": "The gap between \"capable\" and \"reliable\" is not intelligence. It's process."
  }
}
```

```json
{
  "problem": {
    "label": "01 / el problema",
    "title": "Los agentes de IA son capaces pero indisciplinados.",
    "card1Title": "Sin tests antes del commit",
    "card1Desc": "Entregan código que parece correcto pero falla en producción.",
    "card2Title": "Sin review antes del push",
    "card2Desc": "Sobreescriben el trabajo de otros sin darse cuenta.",
    "card3Title": "Solo output genérico",
    "card3Desc": "Producen los mismos patrones sin importar el contexto.",
    "metr": "Cuando los desarrolladores usaron IA, tardaron 19% más. Los desarrolladores estimaron que la IA les ahorró 20% del tiempo. Los expertos predijeron 38% más rápido.",
    "metrSource": "— Becker et al., METR, julio 2025",
    "conclusion": "La diferencia entre \"capaz\" y \"confiable\" no es inteligencia. Es proceso."
  }
}
```

## Verification Checklist

- [ ] Title visible at 375px without wrapping
- [ ] Problem cards stack on mobile
- [ ] METR quote readable at all sizes
- [ ] Contrast ratio ≥ 4.5:1 on all text
- [ ] No banned patterns
- [ ] `prefers-reduced-motion` skips animations
