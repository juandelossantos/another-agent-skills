# Examples & Troubleshooting

This guide contains examples and troubleshooting for `frontend-desktop`.

## Example 1: Desktop App Walkthrough (Tauri v2)

User: "Build a notes app for macOS and Windows."

Agent:
1. Phase 0: Spanish detected.
2. Phase 1: Read `DISCOVERY-GUIDE.md`. Ask: OS targets (macOS + Windows), single window, native menus (File: New/Open/Save), system tray (minimize to tray), file system (save .md files), offline fully.
3. Phase 2: SPEC.md with: platform targets (macOS 13+, Windows 11), distribution (direct download + auto-updater), native APIs (file dialogs, tray, menus).
4. Phase 3: Aesthetic direction — Minimalist SaaS (clean, native feel).
5. Phase 4: Stack lock-in — Tauri v2, React 19, Vite 6, TypeScript 5.7.
6. Phase 5: Anti-slop rules — System font stack, native title bar, dark/light mode, keyboard shortcuts (Cmd/Ctrl+S, Cmd/Ctrl+N).
7. Phase 6: Read `PLATFORM-GUIDE.md`. Implement: menu bar (File, Edit), tray icon, open/save dialogs, window state persistence.
8. Phase 7: Build with tokens. Configure `tauri.conf.json`: window 800x600, min 400x300, native title bar. Sidebar for note list, main area for editor. Keyboard shortcuts for new/save.
9. Phase 8: QA gates. Build for macOS and Windows. Test file dialogs, tray, shortcuts. Verify code signing setup.

## Example 2: Adding Native Menu

Context: App has no menu bar. User wants standard File/Edit/View menus.

Agent:
1. Read `PLATFORM-GUIDE.md` → Menus section.
2. Add menu in Rust (Tauri) or main process (Electron).
3. Wire menu items to existing commands (Open → `open_file_dialog`, Save → `save_current_note`).
4. Add accelerators (Cmd/Ctrl+O, Cmd/Ctrl+S).
5. QA: Verify menu appears on macOS menu bar and Windows app menu.

## Example 3: System Tray Setup

Context: User wants app to minimize to tray, not quit.

Agent:
1. Read `PLATFORM-GUIDE.md` → System Tray section.
2. Configure tray icon in `tauri.conf.json` (or Electron main process).
3. On window close event → `event.preventDefault()` + `window.hide()`.
4. Tray left-click → `window.show()`.
5. Tray context menu: Show, Quit.
6. QA: Close window → tray icon remains. Click tray → window shows. Quit from tray → app exits.

---

## Troubleshooting

### macOS Notarization Fails

**Error:** "The software must be uploaded for analysis..."

**Fix:**
1. Apple Developer ID certificate installed.
2. `APPLE_ID`, `APPLE_PASSWORD`, `APPLE_TEAM_ID` env vars set.
3. In `tauri.conf.json`: `bundle.macOS.signingIdentity` configured.
4. Run: `xcrun notarytool submit app.dmg --apple-id ... --wait`

### Windows SmartScreen Blocks App

**Error:** "Windows protected your PC" (Unknown publisher)

**Fix:**
1. Purchase OV/EV code signing certificate.
2. Sign with `signtool.exe` after build.
3. For Electron: configure `win.certificateFile` in electron-builder.
4. Reputation builds over time; EV certificate shows immediate trust.

### Tauri Build Fails on Linux

**Error:** Missing webkit2gtk development headers.

**Fix:**
```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev

# Fedora
sudo dnf install webkit2gtk4.1-devel openssl-devel curl wget file libappindicator-gtk3-devel librsvg2-devel
```

### Drag-and-Drop Not Working

**Tauri:** Use `html` drag events + `fs` plugin to read dropped file paths.
**Electron:** Native `drop` events work, but use `ipcRenderer` to send paths to main process for security.

### Window Flash on Launch (White Screen)

**Cause:** Frontend not ready before window shows.

**Fix:**
- Tauri: Use `with_webview` or show window after `DOMContentLoaded`.
- Electron: Use `ready-to-show` event:
  ```javascript
  win.once('ready-to-show', () => { win.show(); });
  ```

### IPC Command Returns Error

**Error:** "command not found" or permission denied.

**Fix:**
- Tauri: Command registered in `lib.rs` with `#[tauri::command]`. Frontend calls `invoke('command_name', args)`.
- Check capability permissions in `capabilities/` (Tauri v2).
- Electron: IPC channel registered in main process with `ipcMain.on('channel', handler)`.

### Auto-Updater Not Finding Updates

**Tauri:** Check `tauri.conf.json` `plugins.updater` with proper endpoints.
**Electron:** Check `autoUpdater.setFeedURL()` or `publish` config in electron-builder.
Ensure update JSON/server responds with correct version and signature.
