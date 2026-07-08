# Harden — ARIA Reference

**Patterns for common components. Use these as templates — adapt, don't copy blindly.**

## Button

```html
<!-- Good: implicit button with aria-label when icon-only -->
<button aria-label="Close dialog">
  <svg><!-- X icon --></svg>
</button>

<!-- Good: loading state communicates to screen reader -->
<button aria-busy="true" aria-label="Saving...">
  <span class="spinner"></span>
  Save
</button>
```

## Combobox / Autocomplete

```html
<div role="combobox" aria-expanded="false" aria-controls="listbox-1">
  <input aria-autocomplete="list" aria-activedescendant="" aria-labelledby="label-1" />
  <ul role="listbox" id="listbox-1">
    <li role="option" id="opt-1" aria-selected="false">Option 1</li>
  </ul>
</div>
```

**Rules:** `aria-expanded` must toggle on open/close. `aria-activedescendant` must update on keyboard navigation. `aria-selected` only on the selected option.

## Dialog / Modal

```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title" aria-describedby="dialog-desc">
  <h2 id="dialog-title">Confirm delete</h2>
  <p id="dialog-desc">This will permanently remove "file.pdf".</p>
  <button>Cancel</button>
  <button>Delete</button>
</div>
```

**Focus trap:** Tab cycles within dialog. First tab stop = close button or first input. Last tab stop = primary action. Escape closes dialog.

## Tab Panel

```html
<div role="tablist" aria-label="Settings sections">
  <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1">General</button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2">Security</button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1"><!-- content --></div>
<div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden><!-- content --></div>
```

## Alert / Toast

```html
<!-- For important, time-sensitive messages -->
<div role="alert" aria-live="assertive">
  Your session will expire in 2 minutes.
</div>

<!-- For non-urgent updates (background save, etc.) -->
<div aria-live="polite">
  Document saved.
</div>
```

## Progress Indicator

```html
<!-- Determinate -->
<div role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100">
  60% complete
</div>

<!-- Indeterminate -->
<div role="progressbar" aria-label="Uploading...">
  <span class="spinner"></span>
</div>
```

## i18n Considerations

| Issue | Fix |
|---|---|
| Text overflow in other languages | Set `min-width` on containers, `overflow-wrap: break-word` |
| RTL layouts | Add `dir="auto"` on user-generated content, use logical properties (`margin-inline-start` not `margin-left`) |
| Date formats | Never hardcode "MM/DD/YYYY". Use `Intl.DateTimeFormat` or library |
| Pluralization | "1 item" vs "3 items" — use `Intl.PluralRules` or i18n library with plural rules |
| Long words in German/Dutch | `word-break: break-word` on tight containers |
| Spacing in CJK | Chinese/Japanese/Korean needs less letter-spacing. Avoid global `letter-spacing` |

## Overflow Handling

| Component type | Overflow fix |
|---|---|
| Buttons with long text | `text-overflow: ellipsis; overflow: hidden; white-space: nowrap` + `title` attribute |
| Cards with variable content | `overflow: auto` on scrollable regions, never `overflow: hidden` on data |
| Tables | `overflow-x: auto` on wrapper, `min-width` on columns |
| Navigation | Collapse to hamburger or scroll horizontally with `-webkit-overflow-scrolling: touch` |
| Code blocks | `overflow-x: auto` + `white-space: pre` |
