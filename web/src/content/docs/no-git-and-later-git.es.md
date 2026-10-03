---
title: "Empieza sin git y agrégalo después"
description: "Usa Another Agent Skills en una carpeta sin git y luego haz crecer el enforcement a medida que aparecen las capas: git init, vuelve a ejecutar init-agents para L1, agrega un remoto de GitHub y vuelve a ejecutarlo para L2."
lang: "es"
order: 5
section: "tutorials"
tldr: "init-agents instala cada capa de forma condicional: hooks solo cuando existe .git, y el workflow gates solo cuando existe un remoto de GitHub. La regla es volver a ejecutar init-agents después de git init y después de agregar el remoto."
---

## Qué vas a hacer

No necesitas git para empezar. El framework funciona en una carpeta simple y luego hace crecer su enforcement a medida que agregas un repositorio y un remoto. La regla clave: **vuelve a ejecutar `init-agents` después de `git init` y después de agregar el remoto.**

**Terminarás con:** la misma carpeta mejorada de solo convención a hooks de L1 y luego al workflow de L2, sin reinstalar nada.

## Antes de empezar

- El framework instalado una vez en tu máquina (ver [Tu primer commit con compuerta](../first-gated-commit/)).
- Un agente que lea `AGENTS.md`.

## 1. Empieza sin git (solo convención)

```bash
mkdir scratch && cd scratch
init-agents
```

`init-agents` fusiona `AGENTS.md` y escribe `STACK_CONFIG.md`, pero no puede instalar hooks: no hay directorio `.git`. El enforcement es **solo convención**: las reglas y las skills guían al agente, y nada bloquea un commit porque no hay commits.

## Lo que deberías ver

```text
[init-agents] No git repository — skipping remote gate workflow (.github/workflows/gates.yml).

  ENFORCEMENT — convention-only (no git repository):
    No git repository: enforcement is convention-only. Run `git init`
    and re-run init-agents to enable local hooks; add a GitHub remote
    for remote enforcement.
```

## 2. Agrega git y vuelve a ejecutar para L1

```bash
git init
init-agents
```

Ahora existe `.git`, así que el instalador escribe los shims de hooks portátiles.

```text
  INSTALLED:
    ✓ .git/hooks/pre-commit — portable shim → $AAS_DIR
    ✓ .git/hooks/commit-msg — portable shim → $AAS_DIR

  ENFORCEMENT — local only (L1 hooks active):
    Local git only: L1 (hooks) is active. Remote enforcement (L2) needs
    a GitHub remote — `git remote add origin …` then re-run init-agents.
```

## 3. Agrega un remoto de GitHub y vuelve a ejecutar para L2

```bash
git remote add origin https://github.com/OWNER/REPO.git
init-agents
```

Ahora el proyecto puede usar el workflow remoto, así que el instalador lo escribe:

```text
  INSTALLED:
    ✓ .github/workflows/gates.yml — remote gate (required check)

  REMOTE ENFORCEMENT (L2 — the authority):
    Local hooks are fast feedback; they are writable. The required
    'gates' status check is what actually decides. Turn it on with:
      bash scripts/setup-branch-protection.sh --dry-run   # preview
      bash scripts/setup-branch-protection.sh             # apply
```

Haz commit y push del workflow y termina con [Conecta el enforcement remoto](../wire-remote-enforcement/).

## La regla de volver a ejecutar

| Flujo | Qué obtienes | Cómo habilitar más |
|---|---|---|
| Sin git | Solo convención (reglas, skills, `AGENTS.md`) | `git init`, vuelve a ejecutar `init-agents` |
| Git local | Solo hooks de L1 | Agrega un remoto de GitHub, vuelve a ejecutar `init-agents` |
| Git + GitHub | L1 + L2 + L3 completos | Ver [Conecta el enforcement remoto](../wire-remote-enforcement/) |
| Git después | Crece a medida que aparecen las capas | Vuelve a ejecutar `init-agents` después de cada capa |

Volver a ejecutar es seguro e idempotente: nunca duplica sus propias entradas y nunca sobrescribe las reglas de tu `AGENTS.md`.

## Siguiente

- [Migra un proyecto heredado](../migrate-a-legacy-project/) si heredaste una carpeta que ya usaba el framework.
- [Branch protection](../branch-protection/) tiene la tabla completa de flujos de git/GitHub.
