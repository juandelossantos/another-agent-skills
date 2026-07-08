---
name: frontend-desktop
description: "Build production-grade desktop applications with native OS integration. Default: Tauri v2 (Rust + Webview). Adaptable: Electron, Flutter Desktop."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: frontend-developers
  stack: tauri-rust-webview
  workflow: native-desktop-build
  foundation: engineering-fundamentals
---

# Frontend Desktop

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
desktop-specific implementation.

## When to Use

Build any **desktop application** with native OS integration.

Do NOT use for:
- Web-only apps (use `frontend-web`)
- Mobile apps (use `frontend-mobile`)
- CLI tools (use terminal workflow)

### Context Persistence Check

Before starting work:
1. Check `design/DESIGN-LOCK.md`:
   - Exists and < 7 days → Read it. Extract direction, palette, typography, key decisions.
   - > 7 days → Read it, ask: "Still valid?"
   - Missing → Proceed with Phase 1.
2. Check `SPEC.md`:
   - Exists → Read it. Respect locked stack and boundaries.
   - Missing → If non-trivial, invoke `spec-driven-development`.
3. If context exists → Resume from detected phase. Do NOT re-run discovery unless user requests changes.

### Stack Detection

Check for `STACK_CONFIG.md`:
- **Exists** → Adapt examples to chosen stack.
- **Missing** → Default to **Tauri v2** (Rust 1.78+, Webview2/webkit2gtk/WKWebView).

**Adaptation examples:**
- Tauri → Electron: Node.js context, `ipcRenderer` instead of Tauri commands
- Tauri → Flutter Desktop: Dart widgets, platform channels for native APIs

---

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

---

### Phase 1 — Discovery Gate
→ See `engineering-fundamentals` Phase 1 for universal discovery.

**Desktop-specific questions:**
1. **OS targets**: Windows, macOS, Linux — all or subset?
2. **Window model**: Single window, multi-window, tabbed interface?
3. **Native APIs**: File system, notifications, system tray, menus, global shortcuts?
4. **Distribution**: App store, direct download, auto-updater required?
5. **Offline**: Fully offline or occasional sync?

Read `guides/DISCOVERY-GUIDE.md` for complete desktop checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**Desktop-specific additions:**
- SPEC.md must include: Platform targets (OS + versions), Distribution method, Native API requirements, Code signing strategy.

---

### Phase 3 — Three Dials System

→ See `engineering-fundamentals/guides/DESIGN-CORE.md` for the universal Three Dials System (VARIANCE, MOTION, DENSITY), vibe→dial inference, color principles, and dark mode protocol.

**Desktop constraint:** Must feel native to each OS while maintaining brand consistency. Apply dials with OS-specific materials — Mica on Windows, Vibrancy on macOS, GTK/Qt on Linux.

---

### Phase 4 — Stack Lock-in

**Default: Tauri v2**

| Tool | Minimum | Notes |
|---|---|---|
| Rust | 1.78+ | Tauri core |
| Tauri CLI | 2.0+ | `tauri dev`, `tauri build` |
| Node.js | 20.9+ | Frontend build tooling |
| Vite | 6+ | Bundler (Tauri default) |
| React | 19.2+ | UI framework (adaptable) |
| TypeScript | 5.7+ | |

**Alternative: Electron**

| Tool | Minimum | Notes |
|---|---|---|
| Electron | 33+ | Chromium + Node.js |
| Node.js | 20.9+ | |
| Vite | 6+ | Recommended over webpack |

---

### Phase 5 — Anti-Slop Rules (Desktop)

→ See `engineering-fundamentals/guides/ANTI-SLOP-CORE.md` for universal AI tells, content density, copy protocol, and UI state requirements.

**Desktop-specific rules:**

**Native Feel**
- No generic browser chrome. Use native title bars, shadows, and window controls.
- macOS: Vibrancy, unified title bar, native menu bar.
- Windows: Mica/Acrylic material, system menu integration.
- Linux: Respect GTK/Qt theme integration.

**Typography**
- Use system font stack per OS (San Francisco macOS, Segoe UI Windows, Ubuntu Linux).
- Display font can be distinctive; body must feel native.

**Color**
- Respect OS dark/light mode via `prefers-color-scheme` AND native theme APIs.
- No hardcoded light-mode-only UIs.

**Window Behavior**
- Proper min/max/default window sizes.
- Remember window position and size between sessions.
- Handle fullscreen, minimize to tray, and close-to-tray gracefully.

**Input**
- Full keyboard shortcut support (Cmd/Ctrl+K, Cmd/Ctrl+W, etc.).
- Right-click context menus where expected.
- Drag-and-drop for files and content.

---

### Phase 6 — Native OS Integration

Read `guides/PLATFORM-GUIDE.md`.

**Summary:**
- **Menus:** Native menu bar (macOS), system menu (Windows/Linux).
- **System Tray:** Icon, context menu, left/right click behavior.
- **Notifications:** Native OS notifications, not in-app toasts.
- **File System:** Native dialogs (open, save, pick folder), NOT `<input type="file">`.
- **Global Shortcuts:** Register/unregister on focus/blur.
- **Window Management:** Multi-window, window state persistence.

---

### Phase 7 — Build with Tokens

**BEFORE WRITING CODE:**

1. **Read `design/DESIGN-LOCK.md`** — Verify approved direction.
2. **Check `design/approved/`** — Screenshots, previews.
3. **Cross-check with `DESIGN.md`** — Tokens must match locked system.

**Then build:**

4. Apply tokens from `DESIGN.md` to frontend CSS + native window chrome config.
5. Configure `tauri.conf.json` / `electron-builder.yml`:
   - Window defaults (size, min/max, resizable, fullscreen)
   - Title bar style (hidden for custom, native for standard)
   - System tray config
   - Menu definitions
6. Build sections with canonical desktop patterns:
   - Sidebar navigation (resizable, collapsible)
   - Main content area with native scrollbars
   - Status bar / bottom bar
   - Contextual panels (properties, inspector)
7. Implement native IPC commands (Tauri: Rust commands; Electron: IPC main↔renderer).
8. Ensure keyboard shortcuts work on all target platforms.
9. Handle OS theme changes dynamically.

---

### Phase 8 — QA Gates

→ See `engineering-fundamentals` Phase 5 for universal gates. Read `engineering-fundamentals/guides/PRE-FLIGHT-CORE.md` for universal checks first.

**After QA gates, log metrics:**
```
LOG METRIC: gate
- project: [detect from git remote or directory]
- gate_name: frontend-desktop-qa
- result: pass/fail
- checks_passed: [N]/12
```

**Desktop-specific checks:**

1. **TypeScript** — `npm run typecheck` passes.
2. **Build** — `npm run tauri build` (or `electron-builder`) succeeds for target OS.
3. **Native API tests** — File dialogs, notifications, tray, menus tested.
4. **OS theme** — Respects dark/light mode on all platforms.
5. **Keyboard shortcuts** — All shortcuts work with correct modifiers (Cmd macOS, Ctrl Windows/Linux).
6. **Window state** — Position and size persist between launches.
7. **No web-only patterns** — No `<input type="file">`, no `alert()`, no browser-specific APIs.
8. **Accessibility** — Native OS accessibility (VoiceOver macOS, NVDA Windows, Orca Linux).
9. **Code signing** — macOS notarized, Windows signed, Linux AppImage/flatpak.
10. **Auto-updater** — Updates download and install silently (if applicable).
11. **Offline** — App works without internet (if specified).
12. **Distribution** — Installer/.app/.dmg/.exe/.AppImage generated.

---

## Examples & Troubleshooting

Read `guides/EXAMPLES.md`:
- Desktop app walkthrough (Tauri v2)
- Native menu setup
- System tray configuration
- File system integration
- Troubleshooting (build, signing, notarization, permissions)

---

## Red Flags (Desktop-Specific)

Web app in desktop window, no OS theme, no native file dialogs, no keyboard shortcuts, no signing, no window persistence, browser APIs as primary UX, "works on my machine."

---

## Verification

Config file (tauri/electron) set. Native menus. guides/PLATFORM-GUIDE.md read. Code signing configured. Build passes for target OSes. No browser-only APIs. Window state persistence.
