# Native OS Integration Guide

This guide contains Phase 6 implementation details for `frontend-desktop` native features.

## Menus

### Tauri v2

```rust
// src-tauri/src/lib.rs
use tauri::menu::{Menu, MenuItem, PredefinedMenuItem};

fn setup_menu(app: &mut tauri::App) {
    let menu = Menu::new(app).unwrap();
    
    // File menu
    let file_menu = Menu::new(app).unwrap();
    file_menu.append(&MenuItem::new(app, "Open", true, None::<&str>).unwrap()).unwrap();
    file_menu.append(&PredefinedMenuItem::separator(app).unwrap()).unwrap();
    file_menu.append(&PredefinedMenuItem::quit(app, None).unwrap()).unwrap();
    
    menu.append(&file_menu).unwrap();
    app.set_menu(menu).unwrap();
}
```

### Electron

```javascript
// main.js
const { Menu } = require('electron');

const template = [
  {
    label: 'File',
    submenu: [
      { label: 'Open', accelerator: 'CmdOrCtrl+O', click: () => { ... } },
      { type: 'separator' },
      { role: 'quit' }
    ]
  }
];

const menu = Menu.buildFromTemplate(template);
Menu.setApplicationMenu(menu);
```

## System Tray

### Tauri v2

```rust
use tauri::tray::{MouseButton, TrayIconBuilder};

TrayIconBuilder::new()
    .icon(app.default_window_icon().unwrap().clone())
    .on_tray_icon_event(|tray, event| {
        if let tauri::tray::TrayIconEvent::Click { button: MouseButton::Left, .. } = event {
            // Show/hide window
        }
    })
    .build(app)
    .unwrap();
```

### Electron

```javascript
const { Tray } = require('electron');
let tray = new Tray('icon.png');
tray.setContextMenu(contextMenu);
tray.on('click', () => { window.show(); });
```

## File System Dialogs

### Tauri v2

```typescript
import { open, save } from '@tauri-apps/plugin-dialog';

// Open file
const filePath = await open({
  multiple: false,
  filters: [{ name: 'Images', extensions: ['png', 'jpg'] }]
});

// Save file
const savePath = await save({
  defaultPath: 'document.txt',
  filters: [{ name: 'Text', extensions: ['txt'] }]
});
```

### Electron

```javascript
const { dialog } = require('electron');

const result = await dialog.showOpenDialog({
  properties: ['openFile'],
  filters: [{ name: 'Images', extensions: ['png', 'jpg'] }]
});
```

## Native Notifications

### Tauri v2

```typescript
import { isPermissionGranted, requestPermission, sendNotification } from '@tauri-apps/plugin-notification';

let permission = await isPermissionGranted();
if (!permission) {
  permission = await requestPermission();
}
if (permission) {
  sendNotification({ title: 'My App', body: 'Task completed!' });
}
```

### Electron

```javascript
const { Notification } = require('electron');

new Notification({ title: 'My App', body: 'Task completed!' }).show();
```

## Global Shortcuts

### Tauri v2

```rust
use tauri::plugin::Builder;
use tauri::GlobalShortcutManager;

app.global_shortcut_manager()
    .register("CmdOrCtrl+Shift+N", || {
        // Open new window
    })
    .unwrap();
```

### Electron

```javascript
const { globalShortcut } = require('electron');

globalShortcut.register('CommandOrControl+Shift+N', () => {
  // Open new window
});
```

## Window State Persistence

Save window position/size on close, restore on launch.

### Tauri v2 (with plugin)

```rust
// tauri-plugin-window-state handles automatically
.use_plugin(tauri_plugin_window_state::init())
```

### Manual (both platforms)

Store in app config directory:
- Tauri: `tauri::api::path::app_config_dir()`
- Electron: `app.getPath('userData')`

## OS Theme Detection

### Tauri v2

```typescript
import { appWindow } from '@tauri-apps/api/window';

const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
// Also listen for changes
```

### Electron

```javascript
const { nativeTheme } = require('electron');

nativeTheme.on('updated', () => {
  win.webContents.send('theme-changed', nativeTheme.shouldUseDarkColors);
});
```

## Multi-Window Communication

### Tauri v2

```rust
// Emit event to all windows
app.emit("event-name", payload);

// Listen in frontend
import { listen } from '@tauri-apps/api/event';
listen("event-name", (event) => { ... });
```

### Electron

```javascript
// Main to renderer
win.webContents.send('channel', data);

// Renderer to main
ipcRenderer.send('channel', data);
```
