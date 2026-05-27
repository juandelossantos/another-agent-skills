# Frontend Desktop — Discovery Guide

Execute every step. Do not skip. Do not assume.

---

## Step 1: Surface Assumptions

List at least 5 assumptions about the project. Present for confirmation **in detected language**:

1. **OS targets**: Windows, macOS, Linux — all or subset?
2. **Framework**: Tauri, Electron, or Flutter Desktop?
3. **Window model**: Single, multi-window, or tabbed?
4. **Distribution method**: App store, direct download, auto-updater?
5. **Native APIs**: File system, notifications, system tray, global shortcuts?

## Step 2: Extended Discovery (Mandatory)

Ask at least 5:

1. **Code signing**: macOS notarization, Windows Authenticode?
2. **Auto-update**: Silent updates or manual download?
3. **Offline mode**: Fully offline or occasional sync?
4. **Title bar**: Native or custom (frameless + draggable)?
5. **System tray**: Minimize to tray, background processes?
6. **Multi-window**: Multiple windows, or single instance?
7. **Keyboard shortcuts**: List expected shortcuts per OS?
8. **Accessibility**: VoiceOver (macOS), NVDA (Windows), Orca (Linux)?
9. **Dark mode**: Respect system theme or app-specific toggle?
10. **Brand**: Existing colors, fonts, or start from scratch?

## Step 3: Confirm

Summarize findings. Ask: "Is this correct? Shall we proceed?" Only after explicit yes.
