# Desktop Discovery Guide

This guide contains the complete Phase 1 Discovery for `frontend-desktop`.

## Desktop-Specific Discovery Checklist

Ask these questions IN ADDITION to `engineering-fundamentals` Phase 1.

### 1. OS Targets

Which operating systems must be supported?

- [ ] **macOS** — Minimum version? (e.g., 12 Monterey, 13 Ventura)
- [ ] **Windows** — Minimum version? (e.g., 10, 11)
- [ ] **Linux** — Distro targets? (e.g., Ubuntu 22.04+, Fedora, Arch)

**Critical:** Supporting all 3 triples build complexity. Start with 1 primary, add others later.

### 2. Window Model

How should the application present its interface?

- **Single window** — Simplest. One resizable window.
- **Multi-window** — Dashboard + detail windows, floating panels.
- **Tabbed interface** — Browser-like tabs within one window.
- **Panel-based** — Sidebar + main area + inspector (IDE pattern).

### 3. Native APIs Required

Which OS-level features does the app need?

| Feature | Tauri v2 | Electron | When Needed |
|---|---|---|---|
| **File system** | `fs` plugin | Node.js `fs` | Save/load user files |
| **Notifications** | `notification` plugin | `Notification` API | Alerts, reminders |
| **System tray** | `tray` icon + menu | `Tray` class | Background app, quick actions |
| **Native menus** | `menu` + `prelude` | `Menu` module | App menu bar, context menus |
| **Global shortcuts** | `globalShortcut` | `globalShortcut` | Hotkeys when app not focused |
| **Clipboard** | `clipboard` plugin | `clipboard` API | Copy/paste rich content |
| **Shell open** | `shell` plugin | `shell` module | Open URLs in browser |
| **OS info** | `os` plugin | `process.platform` | Platform-specific logic |

### 4. Distribution Strategy

How will users install and update the app?

| Method | Best For | Notes |
|---|---|---|
| **Direct download** (.dmg, .exe, .AppImage) | Most apps | Simplest, no store fees |
| **Mac App Store** | macOS consumer apps | Sandboxing restrictions |
| **Microsoft Store** | Windows consumer apps | Auto-updates via store |
| **Homebrew / Chocolatey** | Developer tools | CLI install: `brew install --cask myapp` |
| **Auto-updater** | All non-store apps | Required for direct download |

### 5. Offline Strategy

- **Fully offline** — All data stored locally (SQLite, files). No server needed.
- **Sync when online** — Local SQLite, sync to cloud when connected.
- **Online required** — Thin client, data lives in server (why not web app?).

**Critical challenge:** If user says "online required" → "If the app requires constant internet, consider whether a web app (frontend-web) or PWA (frontend-pwa) is simpler. Desktop shines when native APIs or offline work are needed."

### 6. Code Signing & Notarization

- **macOS**: Apple Developer ID + notarization required for Gatekeeper.
- **Windows**: Code signing certificate (OV/EV) prevents "Unknown publisher" warnings.
- **Linux**: GPG signing for packages (optional but recommended).

### 7. Window Behavior Details

- **Initial size**: Default window dimensions.
- **Minimum size**: Prevent unusable small windows.
- **Maximum size**: Optional (usually not needed).
- **Title bar**: Native (standard) or custom (hidden, draw your own).
- **Resize**: Resizable? Aspect ratio locked?
- **Close behavior**: Quit app, minimize to tray, or hide to tray?
- **Fullscreen**: Supported? Default on launch?

### 8. Multi-Window Coordination

If multi-window:
- How do windows communicate? (Tauri: events; Electron: IPC)
- Should closing one window close all? (macOS: usually no; Windows: usually yes)
- Window state: independent or shared?

---

## Research Topics (Phase 2)

Before decisions, research current best practices:

1. "Tauri v2 vs Electron [current year] performance"
2. "Desktop app code signing [current year]"
3. "Tauri v2 plugins [current year]"
4. "Electron security best practices [current year]"
5. "Auto-updater Tauri vs Electron [current year]"
