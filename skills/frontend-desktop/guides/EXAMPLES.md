# Frontend Desktop — Examples & Troubleshooting

---

## Tauri v2 App Walkthrough

1. `npm create tauri-app@latest`
2. Configure `tauri.conf.json` (window size, title, min/max)
3. Set up Rust commands in `src-tauri/src/lib.rs`
4. Build frontend with chosen framework (React, Vue, Svelte)
5. Add tray, menus, shortcuts via Rust
6. `npm run tauri build` → `.dmg` / `.msi` / `.AppImage`

---

## Common Issues

### FOUC (Flash of Unstyled Content)
- Webview loads HTML before CSS. Use `critical` CSS inline in `<head>`.

### Permissions on macOS
- Sandboxed apps need entitlements for file system, network, etc.

### Code Signing
- macOS: `codesign --deep --force --verify-verbose --sign "Developer ID" dist/`
- Windows: `signtool sign /fd SHA256 /a /f cert.pfx dist/installer.exe`

### Notarization (macOS)
```bash
xcrun notarytool submit dist/app.dmg --apple-id user@example.com --team-id TEAMID --password @keychain:AC_PASSWORD --wait
```

### Auto-Update
- Tauri: `tauri-plugin-updater` with `tauri.conf.json > plugins > updater`
- Electron: `electron-updater` with GitHub releases or S3
