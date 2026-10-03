---
title: "Muévete a otra máquina"
description: "Recrea tu configuración en una computadora nueva: instala la misma versión del framework, ejecuta aas install en el proyecto, confirma con aas doctor y el proyecto funciona sin reconfigurarlo."
lang: "es"
order: 7
section: "tutorials"
tldr: "El framework se instala una vez por máquina. En una computadora nueva instala la misma versión, ejecuta aas install en el proyecto para reconectar los hooks locales y después aas doctor para confirmar. La configuración del proyecto que está en git no cambia."
---

## Qué vas a hacer

Tu proyecto vive en git; el framework vive en la máquina. En una computadora nueva reinstalas el framework una vez, reconectas los hooks locales del proyecto y confirmas el entorno. Nada del repositorio cambia.

**Terminarás con:** el mismo proyecto en la máquina nueva, con la misma versión, las mismas reglas y el mismo enforcement.

## Antes de empezar

- El proyecto ya usa el framework (tiene `.aas/config`, `AGENTS.md` y `STACK_CONFIG.md` en git).
- Git y tu agente preferido instalados en la máquina nueva.

## 1. Instala la misma versión en la máquina nueva

Usa el release fijado para que la versión coincida con la que fija el proyecto:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

Para fijar una versión exacta:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash -s -- --version v6.2.0
```

> npm y Homebrew llegan **pronto**. Hoy usa el bootstrap `curl` fijado o `git clone`.

## 2. Activa el framework en el proyecto

```bash
git clone https://github.com/OWNER/REPO.git
cd REPO
aas install --agents auto
```

`aas install` ejecuta la instalación del proyecto: reconecta las skills y los hooks por agente y vuelve a fusionar `AGENTS.md` sin tocar tus reglas. Este es el paso que recrea los hooks **locales** (`.git/hooks/`) que no se guardan en git.

## 3. Confirma el entorno

```bash
aas doctor
```

## Lo que deberías ver

```text
[aas] aas 6.2.0
[aas] source: /home/you/.local/share/another-agent-skills/6.2.0
[aas] install root: /home/you/.local/share/another-agent-skills
agents=opencode
agent:opencode=1.0.0
opencode=1.0.0
agent-discipline=dual-contract
```

El proyecto está listo. Los archivos que están en git (`.aas/config`, `AGENTS.md`, `STACK_CONFIG.md`, `.github/workflows/gates.yml`) no cambian; solo se recrearon la instalación de la máquina y los hooks locales.

## Si las versiones difieren

Si el framework instalado difiere de la versión fijada por el proyecto, recibes un aviso **no bloqueante**:

```text
[aas] advisory: project pins v6.2.0, framework v6.3.0 is installed — run "aas upgrade" then "init-agents --repair" (non-blocking)
```

Ejecuta `aas upgrade` para avanzar y después `init-agents --repair` para migrar el proyecto. Ver [Migra un proyecto heredado](../migrate-a-legacy-project/).

## Si no funciona

| Síntoma | Solución |
|---|---|
| `aas: command not found` | El bootstrap enlaza `aas` en `$HOME/.local/bin`; agrégalo al `PATH` y recarga tu shell. |
| Los hooks no se disparan después de clonar | Ejecuta `aas install` (o `init-agents`) dentro del proyecto: los hooks locales no están en git. |
| El agente no carga las skills | Ejecuta `aas doctor` y revisa las líneas `agents=` y `agent-discipline=`. |

## Siguiente

- [Distribución y actualizaciones](../distribution/) documenta cada canal y `aas upgrade`.
- [Preguntas frecuentes](../faq/) responde las dudas comunes sobre instalar una vez o por proyecto.
