---
title: "Migra un proyecto heredado"
description: "¿Heredaste un proyecto con un layout antiguo de Another Agent Skills? Ejecuta aas doctor, previsualiza con init-agents --dry-run y migra con --repair sin perder el AGENTS.md del equipo."
lang: "es"
order: 6
section: "tutorials"
tldr: "Para un proyecto heredado ejecuta aas doctor, después init-agents --dry-run para previsualizar y después init-agents --repair. La reparación elimina los symlinks absolutos o rotos del framework y materializa los archivos de configuración del agente; el AGENTS.md de tu equipo y los archivos personalizados se conservan."
---

## Qué vas a hacer

Un proyecto que usó un layout antiguo del framework puede tener symlinks absolutos que se rompieron cuando el framework se movió, o un archivo de configuración enlazado donde debería ser un archivo real. Vas a diagnosticarlo, previsualizar la migración y repararlo sin perder el `AGENTS.md` de tu equipo.

**Terminarás con:** un proyecto portátil que fija la versión actual del framework, con tus reglas intactas y una copia de seguridad de la configuración original.

## Antes de empezar

- El framework instalado una vez en tu máquina (ver [Tu primer commit con compuerta](../first-gated-commit/)).
- El proyecto con `AGENTS.md`, `STACK_CONFIG.md` o symlinks del framework de una instalación anterior.

## 1. Diagnostica el entorno

```bash
cd legacy-project
aas doctor
```

## Lo que deberías ver

`aas doctor` imprime la versión instalada, la raíz de instalación, los agentes detectados con sus versiones y el estado del plugin `agent-discipline`:

```text
[aas] aas 6.2.0
[aas] source: /home/you/.local/share/another-agent-skills/6.2.0
[aas] install root: /home/you/.local/share/another-agent-skills
agents=opencode,claude
agent:opencode=1.0.0
agent:claude=2.0.0
opencode=1.0.0
agent-discipline=dual-contract
```

Si el proyecto tiene artefactos del framework pero no un marcador de versión, `init-agents` también avisa:

```text
[init-agents] Legacy AAS project detected (AGENTS.md marker) with no version marker.
[init-agents]   Next: 'bash scripts/init-agents.sh --dry-run' then 'bash scripts/init-agents.sh --repair'
```

## 2. Previsualiza la migración (sin escrituras)

```bash
init-agents --dry-run
```

El dry run imprime exactamente qué cambiaría y no muta nada. Léelo antes de ejecutar la operación real.

## Lo que deberías ver

```text
[init-agents] DRY RUN — no changes will be made.
[init-agents] plan: back up AGENTS.md and append the AAS rules footer
[init-agents] plan: install portable hook shims (.git/hooks/pre-commit, commit-msg)
[init-agents] plan: write .aas/config (version 6.2.0)
[init-agents] plan: copy scripts/aas-resolve.sh → .aas/aas-resolve.sh
[init-agents] plan: create STACK_CONFIG.md
[init-agents] Dry run complete — nothing changed.
```

Si dice `leave AGENTS.md (AAS rules already present)`, tus reglas ya están fusionadas y la migración no las tocará.

## 3. Migra con --repair

```bash
init-agents --repair
```

La reparación no es destructiva. Elimina los symlinks **absolutos o rotos** del framework y luego la instalación normal (idempotente) recrea la forma portátil. Los archivos de configuración del agente que son symlinks se **materializan** en el proyecto en lugar de eliminarse.

## Lo que deberías ver

```text
[init-agents] Repairing legacy project (non-destructive)...
[init-agents] Removed absolute symlink rules/common → /old/path/rules/common
[init-agents] Removed broken symlink scripts/tdd-gate.sh
[init-agents] Materialized AGENTS.md from its symlink target
...
[init-agents] PROJECT UPDATED — RULES MERGED
    ✓ AGENTS.md — skill-driven rules merged
    ✓ .aas/config — pins the framework version
    ✓ .git/hooks/commit-msg — portable shim → $AAS_DIR
```

El contenido del `AGENTS.md` de tu equipo se fusiona, nunca se reemplaza: el instalador hace una copia de seguridad del archivo existente y agrega el footer de reglas del framework.

## Si no funciona

| Síntoma | Solución |
|---|---|
| Un hook personalizado bloquea la instalación | Vuelve a ejecutar con `init-agents --repair --force` para permitir reemplazar hooks personalizados. |
| Aparece un aviso de deriva de versión | Es **no bloqueante**. Ejecuta `aas upgrade` y después `init-agents --repair`. |
| Faltan tus reglas | Revisa la copia de seguridad que creó el instalador junto a `AGENTS.md`; la fusión es aditiva. |

## Siguiente

- [Muévete a otra máquina](../move-to-another-machine/) para la misma historia de portabilidad entre computadoras.
- [Distribución y actualizaciones](../distribution/) documenta `aas upgrade` y el aviso de deriva.
