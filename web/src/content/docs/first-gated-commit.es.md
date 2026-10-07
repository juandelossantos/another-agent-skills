---
title: "Tu primer commit con compuerta"
description: "Un recorrido de cinco minutos: instala Another Agent Skills, ejecuta init-agents, observa cómo la compuerta local bloquea un cambio de código sin test, agrega el test y haz el commit."
lang: "es"
order: 3
section: "tutorials"
tldr: "Instala una vez por máquina, ejecuta init-agents en el proyecto y haz un commit con un cambio de código sin test: la compuerta commit-msg imprime BLOCKED. Agrega el test correspondiente y el mismo commit pasa."
---

## Qué vas a hacer

Instala el framework una vez en tu máquina, actívalo en un proyecto y observa cómo la compuerta local detiene un commit que cambia código sin un test que lo cubra. Después agregas el test y vuelves a hacer el commit. Todo el ciclo toma unos cinco minutos.

**Terminarás con:** un proyecto donde `init-agents` conectó los hooks, un commit bloqueado que viste con tus propios ojos y un commit en verde.

## Antes de empezar

- **Git** en el `PATH`.
- **Bash** (Linux, macOS o Git Bash en Windows).
- Un agente que lea `AGENTS.md` (OpenCode es el predeterminado; Claude Code, Cursor, Codex y Gemini CLI también funcionan).

## 1. Instala una vez por máquina

El instalador coloca las skills de forma global. Cualquier proyecto puede usarlas sin duplicar los archivos.

```bash
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
bash install.sh
```

El bootstrap del release fijado es la ruta de una sola línea y verifica un checksum antes de extraer:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

> Hoy usa `git clone`, el bootstrap `curl` fijado, o `npm`.

## 2. Actívalo en un proyecto

```bash
mkdir my-project && cd my-project
git init
init-agents
```

`init-agents` fusiona `AGENTS.md` (nunca sobrescribe tus reglas), escribe `STACK_CONFIG.md` e instala los shims de hooks locales porque `.git` ya existe.

## 3. Prepara un cambio de código sin test

Crea un archivo fuente y prepáralo para el commit:

```bash
mkdir -p src
printf 'export function checkout() { return true; }\n' > src/checkout.js
git add src/checkout.js
git commit -m "feat: add checkout"
```

## Lo que deberías ver

El commit se bloquea antes de existir:

```text
$ git commit -m "feat: add checkout"
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: none
✗ BLOCKED: every code change needs a matching test.
```

El archivo sigue preparado. No se creó ningún commit.

## 4. Agrega el test correspondiente

```bash
printf 'import { test } from "node:test";\nimport assert from "node:assert/strict";\nimport { checkout } from "../src/checkout.js";\ntest("checkout", () => assert.equal(checkout(), true));\n' > src/checkout.test.js
git add src/checkout.test.js
git commit -m "feat: add checkout"
```

## Lo que deberías ver ahora

```text
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: src/checkout.test.js
✓ TDD gate passed
```

El commit se crea. Esta es la regla central del framework: un cambio de código sin un test que lo cubra se bloquea, local y remotamente.

## Si no funciona

| Síntoma | Solución |
|---|---|
| `init-agents: command not found` | Recarga tu shell (`source ~/.zshrc` o `source ~/.bashrc`). |
| El hook no se dispara | Vuelve a ejecutar `bash scripts/init-agents.sh` dentro del proyecto. |
| `matching test: none` después de agregar uno | El test debe estar preparado en el **mismo** commit y emparejado por nombre (`checkout.js` ↔ `checkout.test.js`). |

## Siguiente

- [Conecta el enforcement remoto](../wire-remote-enforcement/) para que la misma regla se aplique en CI, no solo en tu máquina.
- [Enforcement (L1/L2/L3)](../enforcement/) explica por qué los hooks locales son feedback y el check remoto `gates` es la autoridad.
