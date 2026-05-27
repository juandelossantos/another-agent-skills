# Frontend Desktop — Native OS Integration Guide

Canonical patterns for Tauri v2 native APIs. Adapt for Electron or Flutter Desktop.

---

## Menus

### Tauri (Rust)

```rust
// src-tauri/src/lib.rs
use tauri::menu::{MenuBuilder, SubmenuBuilder};

pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            let file = SubmenuBuilder::new(app, "File")
                .text("open-file", "Open File")
                .separator()
                .quit()
                .build()?;
            let menu = MenuBuilder::new(app).item(&file).build()?;
            app.set_menu(menu)?;
            Ok(())
        })
        .run(tauri::generate_context!())
}
```

---

## System Tray

### Tauri

```rust
use tauri::tray::{TrayIconBuilder, MouseButton, MouseButtonState, TrayIconEvent};

TrayIconBuilder::new()
    .icon(app.default_window_icon().unwrap().clone())
    .on_tray_icon_event(|tray, event| {
        if let TrayIconEvent::Click { button: MouseButton::Left, button_state: MouseButtonState::Up, .. } = event {
            app.get_webview_window("main").unwrap().show().unwrap();
        }
    })
    .build(app)?;
```

---

## File System Dialogs

### Tauri

```rust
use tauri::api::dialog;

dialog::file::open_file(Some(window), "Select a file", None, None, |path| {
    if let Some(p) = path { /* handle file */ }
});
```

Use **native dialogs only**. Never `<input type="file">` in a desktop app.

---

## Global Shortcuts

### Tauri

```rust
use tauri::api::global_shortcut;

global_shortcut::register(app.handle(), "CmdOrCtrl+K", || {
    // open command palette
})?;
```

---

## Window State Persistence

Use `tauri-plugin-window-state`:

```bash
cargo add tauri-plugin-window-state
```

```rust
tauri::Builder::default()
    .plugin(tauri_plugin_window_state::Builder::default().build())
    .run(tauri::generate_context!())
```
