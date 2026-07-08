# Component Architecture

> **Sources:** React.dev (react.dev/learn) — component composition, passing props, conditional rendering, thinking in React. TypeScript with React (react.dev/learn/typescript) — props interface typing conventions. Web.dev — accessibility and semantic HTML patterns.

## Component Contract

Every component has a contract defined by its props:

| Aspect | Rule |
|---|---|
| Required props | Explicitly typed, no defaults |
| Optional props | Have sensible defaults, documented |
| Children | Use slot-based composition for flexible content |
| Callbacks | Named after the event (onClick, onSubmit) |
| Styling | Use design tokens, never hardcoded values |

## Composition Over Inheritance

Inheritance creates tight coupling. Composition creates flexibility:

```typescript
// Prefer composition (slots):
interface DashboardProps {
  header: React.ReactNode;
  sidebar: React.ReactNode;
  main: React.ReactNode;
}

// Instead of inheritance (extends):
// class Dashboard extends BaseLayout { ... }
```

## Container vs Presentational

Separate concerns into two component types:

| Type | Responsibility | Reusable? |
|---|---|---|
| Container | Data fetching, state, side effects | No (project-specific) |
| Presentational | Rendering, layout, styling | Yes (across projects) |

```typescript
// Container — fetches data, manages state
function UserListContainer() {
  const [users, loading] = useUsers();
  if (loading) return <Spinner />;
  return <UserList users={users} />;
}

// Presentational — renders props
function UserList({ users }: { users: User[] }) {
  return (
    <ul>
      {users.map(user => (
        <UserItem key={user.id} user={user} />
      ))}
    </ul>
  );
}
```

## Conditional Rendering Patterns

| Pattern | Use Case |
|---|---|
| Ternary | Binary state (loading vs loaded) |
| Early return | Guard clause (error, empty, unauthorized) |
| Logical AND | Show/hide without else branch |
| Switch/map | Multiple states (idle, loading, error, empty, success) |

Guard clauses first, then ternary, then switch for complex states.

## Component Hierarchy Design

Design from the outside in:

1. Page layout (header, sidebar, content, footer)
2. Feature sections (each section is a composed component)
3. Reusable primitives (buttons, inputs, cards)
4. Shared patterns (lists, tables, forms)

Each level only knows about the levels immediately below it.

## Anti-Patterns

1. Prop drilling — passing data through 5+ layers. Compose instead.
2. God component — a 500-line component doing everything. Split by responsibility.
3. Premature abstraction — creating a reusable component before there are 3+ instances.
4. Mixing concerns — data fetching inside a presentational component.
5. Missing loading/error states — component assumes data is always available.
