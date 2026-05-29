# Harden — State Matrix

**Every component type needs loading, empty, error, and edge-case states.**

## Form

| State | What to show | Example |
|---|---|---|
| **Default** | Empty inputs with labels | `[Name: ____]` |
| **Filled** | User-entered values | `[Name: Juan]` |
| **Loading (submit)** | Disable button + spinner. All fields locked. | `[⟳ Saving... (disabled)]` |
| **Validation error** | Red border on field + message below field. Never a generic toast. | `[Email: juan@@] ⚠ This doesn't look like a valid email` |
| **Server error** | Inline alert above form. Not a toast (toast dismisses too fast). | `⚠ Could not save. Your changes are safe. Try again. [Retry]` |
| **Success** | Brief confirmation + transition to next state. | `✓ Saved` then navigate to next page |
| **Rate limited** | "Too many attempts. Try again in 30 seconds." Countdown timer. | Wait 30s before enabling submit |

## List / Feed

| State | What to show | Example |
|---|---|---|
| **Loading** | Skeleton rows matching list item shape (not a spinner). | 3 grey rectangles with shimmer |
| **Empty** | Why it's empty + expectation + action. | "No messages yet. Team chats appear here. [Start a conversation]" |
| **Error** | What failed + retry option. | "Couldn't load messages. Check your connection. [Retry]" |
| **Refresh** | Pull-to-refresh indicator (mobile) or button (web). | Show last updated timestamp |
| **End of list** | "You're up to date" or nothing (with infinite scroll). | Not "Error" when API returns empty page |
| **Filtered empty** | "No items match "search term". Try a different search." | Show what was searched |

## Detail View

| State | What to show | Example |
|---|---|---|
| **Loading** | Skeleton matching page structure (header block, body block). | Title shimmer + 3 text line shimmers |
| **Not found** | "This item doesn't exist or was deleted." Link to list. | "Invoice #404 not found. [View all invoices]" |
| **Error** | "Couldn't load details. [Retry]" with back button. | Full-page error, not a toast |
| **Stale data** | Show cached data + "Offline — showing cached version" banner. | Keep page usable, indicate stale |
| **Deleted by another user** | "This item was deleted by [name]." | Refresh button to go back |

## Card / Tile

| State | What to show | Example |
|---|---|---|
| **Loading** | Grey card outline with shimmer. Same dimensions as loaded card. | Prevent layout shift |
| **Default** | Full content: image, title, description, action | — |
| **Image missing** | Placeholder icon/gradient in image slot. Not a broken image icon. | Gray box with centered icon |
| **Long title** | `text-overflow: ellipsis` on title (2 lines max). | Truncate with ellipsis |
| **Action pending** | Disable action button + spinner. | "Adding..." while API processes |
| **Action failed** | Toast or inline error on the specific card. | "Couldn't add to cart" |

## Navigation

| State | What to show | Example |
|---|---|---|
| **Default** | All nav items visible. Active item highlighted. | — |
| **Loading (async nav)** | Skeleton for nav items. | Grey bars where labels will be |
| **Empty section** | Section header visible, items area shows "Nothing here yet." | Don't hide the section entirely |
| **Error** | Section shows "Couldn't load items." Not removed from nav. | Keep nav structure intact |
| **Overflow (too many items)** | "Show more" expander or scroll. Not hidden behind overflow:hidden. | `+5 more` expander |

## Empty State Design Rules

1. **Never leave a blank page.** If the data is empty, ALWAYS show something.
2. **Explain WHY.** "You have no invoices" → "Invoices you create will appear here."
3. **Set expectation.** "Messages from your team will show up here."
4. **Offer action.** "[Create first invoice]" / "[Browse templates]"
5. **No dead ends.** Every empty state has a way forward.

## Error Message Formula

```
What failed + Why + Fix + (optional) Safety reassurance
```

| Component | Formula applied |
|---|---|
| Save form | "We couldn't save (what). Your data is safe (safety). Check your connection and try again (fix)." |
| Load list | "Couldn't load messages (what). This may be a temporary issue (why). [Tap to retry] (fix)." |
| Submit payment | "Your card wasn't charged (safety). This card doesn't support monthly billing (why). Try a different card (fix)." |
