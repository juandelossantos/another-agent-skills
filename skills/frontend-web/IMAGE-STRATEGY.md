# Frontend Web — Image & Visual Asset Strategy

Landing pages and portfolios are **visual products**. Text-only pages with fake-screenshot divs are slop.

---

## Priority Order

1. **Image-generation tool first** — If ANY image-gen tool is available (MCP, IDE-integrated, OpenAI), use it to create section-specific assets: hero photography, product shots, texture backgrounds, mood images. Generate at the right aspect ratio.

2. **Real web images second** — When no gen tool is available:
   - `https://picsum.photos/seed/{descriptive-seed}/{w}/{h}` for placeholder photography
   - Unsplash, Pexels (if explicitly allowed)
   - Brand-provided URLs

3. **Placeholder slots last** — If neither is possible, leave `<!-- TODO: hero product photo, 1600x1200 -->` slots and tell the user what's needed.

---

## Hard Bans

- **Div-based fake screenshots** — BANNED. A product preview rendered with `<div>` rectangles, fake task lists, fake dashboards, fake terminal windows is a Tell.
- **Hand-rolled decorative SVGs** — Strongly discouraged as default. Acceptable only for simple geometric marks.
- **Text-only hero with gradient blob** — That's a placeholder, not a hero.

---

## Social Proof (Logo Walls)

- Use **real SVG logos** from `https://cdn.simpleicons.org/{slug}/{color}` or `simple-icons` npm package
- For invented brand names: generate a simple inline `<svg>` monogram
- **Logo-only rule:** logos and nothing else. No industry labels below ("Vercel" + "hosting")
- Render in both light and dark mode

---

## Photography Guidelines

- Even minimalist sites need at least 2-3 real images
- Generate B&W photography if the brief is restrained; don't skip images
- Use `next/image` with `priority` on above-the-fold images
- Descriptive `alt` text on every image
