---
title: "Conecta el enforcement remoto"
description: "Convierte el feedback de L1 en la autoridad de L2: haz commit del workflow gates, abre un pull request para que el check gates reporte, previsualiza la protección de rama con --dry-run, aplícala y verifica."
lang: "es"
order: 4
section: "tutorials"
tldr: "Haz commit de .github/workflows/gates.yml, abre un PR para que el check gates reporte al menos una vez, previsualiza la protección de rama con --dry-run, aplícala y verifica que los contexts requeridos incluyan gates. L2 y L3 requieren GitHub."
---

## Qué vas a hacer

Los hooks locales son feedback rápido, no autoridad: quien hace el commit puede reapuntar o editar `.git/hooks`. El check remoto `gates` es lo que decide de verdad. Este tutorial lo activa en un repositorio que ya tiene un remoto de GitHub.

**Terminarás con:** `main` protegida, un check de estado `gates` requerido y un comando de verificación que lo demuestra.

## Antes de empezar

- Un proyecto que ya ejecutó `init-agents` y tiene un **remoto de GitHub**.
- La CLI `gh` autenticada con permisos de **administrador** en el repositorio.
- `jq` en el `PATH`.

Si tu proyecto todavía no está en GitHub, haz primero [Empieza sin git y agrégalo después](no-git-and-later-git/).

## 1. Haz commit del workflow gates

`init-agents` escribe `.github/workflows/gates.yml` solo cuando el proyecto tiene un remoto de GitHub. Su job se llama `gates`. Haz commit en una rama:

```bash
git checkout -b ci/arm-gates
git add .github/workflows/gates.yml
git commit -m "ci: arm the remote gates check"
git push -u origin ci/arm-gates
```

## 2. Abre un pull request para que el check reporte

GitHub solo ofrece un check de estado como "requerido" **después de que se ejecutó al menos una vez**. Abre un PR:

```bash
gh pr create --fill --base main
```

Espera a que termine el check `gates`. Ejecuta los comandos de tu `STACK_CONFIG.md` más la auditoría del proyecto, y es de solo lectura (`contents: read`): nunca hace push ni commit.

## 3. Previsualiza la protección de rama (sin escrituras)

```bash
bash scripts/setup-branch-protection.sh --dry-run
```

El script detecta si el repositorio es individual (una sola persona con push) o de equipo, imprime el payload exacto y **no hace ninguna llamada a la API**.

## 4. Aplícala

```bash
bash scripts/setup-branch-protection.sh
```

El script es idempotente: si el estado deseado ya está puesto, lo informa y sale sin escribir. También rechaza una configuración que podría dejar fuera a un único mantenedor.

## 5. Verifica

```bash
gh api repos/OWNER/REPO/branches/main/protection \
  --jq '.required_status_checks.contexts'
```

## Lo que deberías ver

```text
["gates"]
```

Los push directos a `main` ahora se rechazan y ningún pull request puede fusionarse hasta que `gates` pase, sin importar lo que hagan los hooks locales.

## Individual versus equipo

| Perfil | Cuándo se elige | Aprobaciones | Revisión de code owners |
|---|---|---|---|
| Individual | El propietario es un usuario y como máximo una persona con push | 0 | Desactivada |
| Equipo | Organización, o más de una persona | 1 | Activada |

> **Advertencia del perfil individual:** el perfil individual deja `enforce_admins` desactivado, así que el administrador todavía puede saltarse las reglas. Las compuertas siguen siendo obligatorias para todos los que no tienen permisos de administrador. Si quieres que también te obliguen a ti, necesitas una segunda persona con acceso de push.

## Limitaciones honestas

L2 y L3 son **solo de GitHub**. La protección de rama y el check de estado requerido son funciones de GitHub, y el enforcement de `CODEOWNERS` depende de la revisión de code owners de GitHub. Sin un remoto de GitHub todavía tienes L1.

## Siguiente

- [Branch protection](../branch-protection/) tiene el modelo completo L1/L2/L3, los perfiles individual/equipo y la protección contra bloqueos.
- [Evidencia de enforcement remoto](../enforcement/) registra lo que se verificó de verdad, incluida la demo de bypass.
