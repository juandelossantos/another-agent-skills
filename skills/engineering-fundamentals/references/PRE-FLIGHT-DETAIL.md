# Pre-Flight Detail

Detailed steps for the mandatory pre-flight repo state check.

## Step 1 — Diagnose

```bash
# This repo
bash scripts/pre-flight.sh

# Any repo
git status && git fetch --dry-run && git branch --show-current
git log --oneline -3
```

## Step 2 — Present & Ask (MANDATORY)

Present full state and ask about branch intent before any action:

```
Git state: [branch] [clean/dirty] [up-to-date/behind] [upstream]
→ "Estás en [branch]. Quieres seguir aquí, crear una rama nueva, o cambiar?"
```

| State | Ask |
|---|---|
| Clean + correct branch | ¿Seguir en [branch] o crear rama? |
| Dirty tree | ¿Commit, stash, o descartar? |
| Behind remote | ¿Pull --rebase ahora? |
| Wrong branch | ¿Cambiar a [target] o crear nueva? |
| Detached HEAD | ¿Crear rama o checkout a main? |

## Step 3 — Verify

- Not a git repo → `git init` (see `git-init-and-versioning`)
- Dirty tree → ask: commit, stash, or discard
- Remote has unpulled changes → ask: pull --rebase?

## Enforcement

Pre-commit hook enforces this mechanically. See `scripts/git-hooks/pre-commit`.
