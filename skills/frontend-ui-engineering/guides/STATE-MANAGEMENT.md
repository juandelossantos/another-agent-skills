# State Management

> **Sources:** React.dev (react.dev/learn) — state: a component's memory, sharing state between components, choosing the state structure. React.dev — thinking in React (react.dev/learn/thinking-in-react) — state placement decision process. Web.dev — performance patterns for state updates and re-renders.

## State Decision Tree

```
Does only one component need this state?
├── YES → Local state (useState)
└── NO → Do parent and children need it?
    ├── YES → Lifted state (prop drilling or composition)
    └── NO → Do many unrelated components need it?
        ├── YES → External store (Redux, Zustand, Jotai)
        └── NO → Context (theme, locale, auth)
```

## Local State

State that belongs to a single component and has no effect on other components.

```typescript
function SearchInput() {
  const [value, setValue] = useState('');
  // No other component needs 'value'
  return <input value={value} onChange={e => setValue(e.target.value)} />;
}
```

**When:** form inputs, toggle states, hover states, local UI state.

## Lifted State

State that needs to be shared between a parent and its children.

```typescript
function Parent() {
  const [selectedId, setSelectedId] = useState<string | null>(null);
  // 'selectedId' is lifted to the parent
  return (
    <div>
      <List onSelect={setSelectedId} />
      <Detail id={selectedId} />
    </div>
  );
}
```

**When:** selected item, active tab, expanded accordion, form data submitted from child.

## Context

Context provides state to a subtree without prop drilling.

```typescript
const ThemeContext = createContext('light');

function App() {
  return (
    <ThemeContext.Provider value="dark">
      <DeeplyNestedTree />
    </ThemeContext.Provider>
  );
}
```

**When:** theme, locale, user preferences, feature flags.

**Not for:** frequently updating state (causes re-renders in all consumers), global state that many components write to.

## External Store

For state that is truly global and many unrelated components need to read or write.

```typescript
// Example with Zustand (concept — adapt to your store)
const useStore = create(set => ({
  user: null,
  notifications: [],
  setUser: (user) => set({ user }),
}));
```

**When:** cached API data, authenticated user, real-time notifications.

**Not for:** component-local UI state, form state that only one component uses.

## State Migration Path

Always start simple and move up only when needed:

```text
Local → Lifted → Context → External store
```

Each step adds complexity. Do not jump to Context or external store without proving local/lifted is insufficient.

## Rules

1. **Single source of truth** — the same state should not exist in two places.
2. **Derived state** — compute values from existing state, don't store them separately.
3. **State minimization** — if it can be derived from state or props, don't store it.
4. **Co-location** — keep state as close as possible to where it's used.

## Anti-Patterns

1. Putting everything in an external store — Redux for a counter.
2. Context for everything — wrapping the entire app in 10 providers.
3. Out-of-sync state — storing derived values that can go stale.
4. State in props — passing state down and expecting the child to mutate it (lift callbacks).
5. Ref over State — using refs for values that should trigger re-renders.
