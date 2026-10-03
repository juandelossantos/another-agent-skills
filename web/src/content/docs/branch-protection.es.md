---
title: "Protección de ramas"
description: "Cómo funciona la capa de enforcement remota: protección de ramas de GitHub, el check gates requerido, CODEOWNERS y los perfiles solo y equipo."
lang: "es"
order: 22
section: "reference"
tldr: "Las puertas locales son feedback rápido; las puertas remotas son autoridad. Si la puerta que decide puede ser editada por el cambio que juzga, no es una puerta."
---

## Las tres capas

| Capa | Dónde vive | Qué garantiza | Naturaleza |
|---|---|---|---|
| L1: Feedback local | `.git/hooks/*` | Falla rápido, informa, hace visible el punto de decisión | Ergonomía para un agente cooperativo. No es seguridad. |
| L2: Autoridad remota | Protección de ramas de GitHub más status checks requeridos | Nada llega a `main` sin pasar las puertas reales | Enforcement real para quien no tiene admin. Un admin en solitario todavía puede saltarlo. |
| L3: Integridad de la configuración | `CODEOWNERS` más revisión requerida de un code owner | Otro code owner debe aprobar los cambios en la configuración de las puertas | Cierra el agujero de "CI es falsificable" solo mientras la revisión de code owners esté activa |

El principio rector: diseña para el agente cooperativo, aplica para el adversario. L1 es primario para la cooperación; L2 y L3 son la red de seguridad.

## Por qué los hooks locales no bastan

`.git/hooks/` lo puede escribir quien hace el commit, incluido un agente. Hay dos saltos que no necesitan `--no-verify`:

- `git config core.hooksPath /some/empty/dir` silencia todos los hooks a la vez.
- Editar o borrar `.git/hooks/pre-commit` o `.git/hooks/commit-msg`.

Los hooks además viven fuera del control de versiones, así que se desvían del repositorio y se reinstalan en cada clon. Son excelentes para feedback rápido y para hacer visible el proceso; no pueden ser la autoridad.

## Sin GitHub

L2 y L3 son solo de GitHub. La protección de ramas y el status check `gates` requerido son funciones de GitHub, y el enforcement de `CODEOWNERS` depende de la revisión de code owners de GitHub. Sin un remoto de GitHub solo tienes L1.

| Flujo | Enforcement disponible | Pasos |
|---|---|---|
| Sin git | Solo convención (reglas, skills, `AGENTS.md`) | Ejecuta `git init` y vuelve a ejecutar `init-agents` para obtener L1 |
| Git local | Solo hooks L1, sin L2 ni L3 | Agrega un remoto de GitHub, vuelve a ejecutar `init-agents` y después el script de configuración |
| Git y GitHub | L1, L2 y L3 completos | Ver "Cómo ejecutarlo" |
| Git después | Crece a medida que aparecen capas | Vuelve a ejecutar `init-agents` tras `git init` y tras agregar el remoto |

La regla de re-ejecución importa porque `init-agents` instala cada capa de forma condicional: hooks locales solo cuando existe `.git`, y el flujo `gates` solo cuando existe un remoto de GitHub.

## Solo versus equipo

GitHub no te deja aprobar tu propia pull request. Eso hace imposible satisfacer una regla de "requerir 1 aprobación" cuando eres la única persona que puede hacer push. El script de configuración detecta la forma del repositorio y elige uno de dos perfiles.

| Perfil | Se elige cuando | Strict | Aprobaciones | Revisión de code owners | Aplicar a admins |
|---|---|---|---|---|---|
| Solo | El owner es un usuario y hay como máximo una persona con push | No | 0 | No | No |
| Equipo | Cualquier otro caso (organización, o más de una persona) | Sí | 1 | Sí | Sí |

Ambos perfiles siguen exigiendo una pull request y el status check `gates`, requieren resolver la conversación y desactivan force push y borrados.

> **Advertencia del perfil solo:** deja `enforce_admins` desactivado, así que el admin todavía puede saltarse la PR requerida y el check `gates`. Las puertas siguen siendo obligatorias para todos los que no tienen admin. Si quieres que las puertas también te apliquen a ti, necesitas una segunda persona con acceso de push.

## El guardián anti-bloqueo

Si menos de dos personas tienen acceso de push, el script fuerza el perfil solo incluso cuando pasas explícitamente `--mode team`. Exigir una aprobación que nadie puede dar te dejaría fuera de `main`, así que el script se niega a emitir esa configuración e imprime una advertencia. También limita un `--approvals N` demasiado grande: con N personas con push, como máximo N menos 1 aprobaciones son alcanzables.

## Cómo ejecutarlo

Requisitos: la CLI `gh` autenticada con permisos de admin en el repositorio, y `jq` en el `PATH`.

```bash
# Previsualizar el payload exacto sin llamar a la API (seguro, sin escrituras):
bash scripts/setup-branch-protection.sh --repo OWNER/REPO --dry-run

# Detectar el perfil automáticamente y aplicarlo a main del repo actual:
bash scripts/setup-branch-protection.sh

# Forzar un perfil explícitamente:
bash scripts/setup-branch-protection.sh --mode solo
bash scripts/setup-branch-protection.sh --mode team
```

| Flag | Efecto |
|---|---|
| `--mode auto\|solo\|team` | `auto` detecta la forma; `solo` y `team` fuerzan un perfil. |
| `--approvals N` | Revisiones aprobatorias requeridas, limitadas al máximo de 6 de GitHub. |
| `--code-owner-reviews` / `--no-code-owner-reviews` | Exigir o quitar la revisión de code owners. |
| `--strict` | Exigir que la rama esté actualizada antes de fusionar. |
| `--enforce-admins` | Aplicar las reglas también a los admins. |
| `--force-lockout-risk` | Permitir una configuración que puede dejar fuera a un único mantenedor. |
| `--dry-run` | Imprimir el modo detectado y el payload; no hacer escrituras en la API. |

El script es idempotente: lee primero la protección actual y, si el estado deseado ya está, lo informa y sale sin escribir. Verifica después:

```bash
gh api repos/OWNER/REPO/branches/main/protection --jq '.required_status_checks.contexts'
# -> ["gates"]
```

> El flujo es de solo lectura (`permissions: contents: read`) y nunca hace push ni commit. Cada comando que ejecuta es un script del repositorio, así que "pasó en local" y "pasó en CI" significan lo mismo.
