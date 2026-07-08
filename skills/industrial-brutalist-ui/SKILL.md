---
name: industrial-brutalist-ui
description: "Design raw mechanical interfaces with Swiss typographic print and military terminal aesthetics: rigid grids, extreme type scale, utilitarian color. Do NOT use for soft UIs."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-shadcn
  style: brutalist
---

# Industrial Brutalism & Tactical Telemetry UI

## When to Use

Use when: user chooses brutalist / military / industrial / tactical design direction.

Architect web interfaces synthesizing mid-century Swiss design, industrial manuals, and retro-futuristic aerospace terminals.

## Visual Archetype (Pick ONE per project)

### Swiss Industrial Print (Light)
- Background: `#F4F4F0` (matte documentation paper)
- Foreground: `#050505` (carbon ink)
- Accent: `#E61919` (hazard red — the ONLY accent)
- Heavy sans-serif, visible dividing lines, massive negative space

### Tactical Telemetry / CRT Terminal (Dark)
- Background: `#0A0A0A` (deactivated CRT)
- Foreground: `#EAEAEA` (white phosphor)
- Accent: `#E61919` (aviation red)
- Optional: `#4AF626` (terminal green, ONE element only)
- Monospace dominant, framed data points, scanlines

## Typography

### Macro (Structural Headers)
- Neue Haas Grotesk, Inter Extra Bold, Archivo Black, Monument Extended
- Fluid scale: `clamp(4rem, 10vw, 15rem)`
- Negative tracking: `-0.03em` to `-0.06em`
- Compressed leading: `0.85` to `0.95`
- Exclusively UPPERCASE

### Micro (Data & Telemetry)
- JetBrains Mono, IBM Plex Mono, Space Mono
- Fixed small: `10px` to `14px`
- Generous tracking: `0.05em` to `0.1em`
- Exclusively UPPERCASE

## Layout

- CSS Grid with `gap: 1px` and contrasting parent/child backgrounds for razor-thin dividing lines
- **Zero border-radius.** All corners 90 degrees.
- Visible compartmentalization with solid `1-2px` borders
- ASCII framing: `[ DELIVERY SYSTEMS ]`, `>>>`, `///`, `\\\`
- Industrial markers: `®`, `©`, `™` as structural geometric elements

## Textural Effects

- Halftone / 1-bit dithering on images (CSS `mix-blend-mode: multiply` + SVG dot pattern)
- CRT scanlines: `repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,0,0,0.1) 2px)`
- Mechanical noise: global low-opacity SVG static filter on DOM root

## Pre-Output Checklist

- [ ] Single visual archetype selected (not mixed)
- [ ] No border-radius anywhere
- [ ] Macro-typography uses clamp() for fluid scale
- [ ] ASCII decorative elements present
- [ ] Layout uses grid with gap-1px technique
- [ ] Analog degradation effects applied (halftone, scanlines, or noise)
- [ ] Semantic tags used (`<data>`, `<samp>`, `<kbd>`, `<output>`)
