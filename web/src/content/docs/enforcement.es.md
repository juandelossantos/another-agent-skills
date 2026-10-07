---
title: "Enforcement (L1/L2/L3)"
description: "Las tres capas de enforcement: L1 hooks locales, L2 el check remoto gates requerido y L3 revisión con CODEOWNERS. Un cambio de código sin test que lo cubra se bloquea."
lang: "es"
order: 12
section: "concepts"
tldr: "L1 es feedback local rápido, L2 es la autoridad remota y L3 protege la configuración de las puertas. Un cambio de código sin test que lo cubra se bloquea, local y remotamente."
---

## Las tres capas

La mayoría de los frameworks se detiene en reglas dentro de un archivo, y una regla en un archivo es una sugerencia. El enforcement es un mecanismo: un cambio que rompe el proceso no puede llegar a `main`. Tres capas responden a tres preguntas distintas.

### L1: Feedback local

Falla rápido, informa y deja un rastro. Ergonomía para un agente cooperativo. **No es seguridad.**

### L2: Autoridad remota

Protección de ramas de GitHub más un status check requerido. Nada llega a `main` sin pasar el check `gates`. Quien hace el commit no puede saltarlo.

### L3: Integridad de la configuración

`CODEOWNERS` más revisión requerida de un code owner. Otro owner debe aprobar los cambios en la configuración de las puertas. Solo GitHub.

## La regla: nada pasa sin verificación

El hook `commit-msg` (v6) ejecuta una única puerta TDD que verifica cada artefacto en stage **por tipo**. El código necesita un test emparejado por nombre, no vacío y nuevo, creado antes que el código. Los docs pasan por el validador de honestidad de docs (un enlace interno roto bloquea). La config pasa por el validador de consistencia de config (sintaxis inválida, o un script de `package.json` que apunta a un archivo inexistente, bloquea). Los shims necesitan un test emparejado que realmente los invoque.

No existe ningún mecanismo de override. La puerta 0 de pre-commit bloquea hasta que el token de decisión esté vigente, pero eso es un aviso, no la autoridad de aprobación.

> **Por qué un hook no es una puerta.** El directorio de hooks lo puede escribir quien hace el commit, incluido un agente. Un solo comando de `git config` silencia todos los hooks a la vez. Por eso L1 es feedback y no autoridad. Si la puerta que decide puede ser editada por el cambio que juzga, no es una puerta.

## Un commit bloqueado

Esto es salida real, no un mock. El commit se detiene antes de existir.

```text
$ git commit -m "feat: add checkout"
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: none
✗ BLOCKED: every code change needs a matching test.
```

El mismo check corre en remoto como el estado `gates` requerido, así que quien hace el commit no puede saltarlo.

## Las puertas de un vistazo

| Capa | Dónde vive | Qué garantiza |
|---|---|---|
| L1 | Árbol de trabajo, `.git/hooks` | Feedback rápido y un punto de decisión visible. No es seguridad. |
| L2 | Protección de ramas de GitHub | Nada llega a `main` sin pasar el check `gates` requerido. |
| L3 | `CODEOWNERS` | Los cambios en la configuración de las puertas necesitan la aprobación de otro owner. |

## Qué revisan los hooks locales

El hook de pre-commit ejecuta una secuencia de puertas antes de cada commit: comprobación de rama, cambios en stage, sincronización con el remoto, integridad de HTML, escalado de overrides, la puerta de skills, verificación del build, anti-slop, seguimiento de depuración, enforcement de SPEC, estado de progreso, lint de skills y el runner de tests. Después, el hook `commit-msg` ejecuta la puerta TDD.

Un hook en verde es feedback, no aprobación. Todo lo que un lector pueda confundir con aprobación o se mueve a remoto o se etiqueta como L1.

## Cómo activarlo

El script de configuración detecta la forma del repositorio y elige un perfil seguro. Primero previsualiza y después aplica.

1. Previsualiza el payload exacto sin escribir nada:

```bash
bash scripts/setup-branch-protection.sh --dry-run
```

2. Aplícalo. El script detecta automáticamente solo o equipo y rechaza una configuración que podría dejarte fuera:

```bash
bash scripts/setup-branch-protection.sh
```

3. Verifica que la autoridad remota esté activa:

```bash
gh api repos/OWNER/REPO/branches/main/protection
```

4. Después de `git init` o de agregar un remoto, vuelve a ejecutar el instalador para que se instalen las capas faltantes:

```bash
init-agents
```

## Limitaciones honestas

Estas puertas crean fricción, no garantías. Los hooks L1 se pueden saltar editando el hook o cambiando la ruta de hooks. En un repositorio solo, el admin todavía puede saltarse las reglas remotas por diseño, así que las puertas siguen siendo obligatorias para todos los que no tienen permisos de admin. La persona sigue en el loop, y la persona sigue atenta.

Ver [Protección de ramas](../branch-protection/) para los perfiles solo y equipo, y el guardián anti-bloqueo que evita que un único mantenedor quede fuera.
