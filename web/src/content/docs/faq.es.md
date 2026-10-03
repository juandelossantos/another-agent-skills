---
title: "Preguntas frecuentes"
description: "Respuestas directas sobre la instalación, las actualizaciones, el enforcement, los agentes y lo que el framework garantiza y lo que no."
lang: "es"
order: 30
section: "help"
tldr: "Respuestas breves y citables: una instalación por máquina, POSIX primero con Windows vía Git Bash, los hooks locales son feedback y el check remoto gates es autoridad, y ningún sistema puede impedir del todo que un agente actúe contra el protocolo."
---

## ¿Qué es Another Agent Skills?

Un framework de 57 skills componibles que convierten a los agentes de codificación con IA en ingenieros senior disciplinados. Agrega enforcement mecánico, no solo prompts. Las skills siguen un ciclo de vida de seis fases: Definir, Planear, Construir, Verificar, Revisar, Entregar.

## ¿Se instala por proyecto o una vez?

Una vez por máquina. El instalador coloca las skills de forma global, y cualquier proyecto puede usarlas sin duplicar los archivos. Ejecutas `init-agents` en cada proyecto para activar el framework allí.

## ¿Funciona en Windows, macOS y Linux?

Sí. El instalador es POSIX primero y funciona en Linux y macOS. En Windows, usa Git for Windows (Git Bash); `install.ps1` ofrece paridad con Claude Code. El wrapper de npm (próximamente) es la ruta portable para usuarios de Node.

## Un compañero clona mi proyecto y no tiene el framework. ¿Se rompe?

No. El proyecto sigue funcionando. Tu compañero puede instalar el framework cuando lo quiera, y el check remoto `gates` aplica las reglas para todos en el repositorio, independientemente de su configuración local.

## Heredé o migré un proyecto que usaba el framework. ¿Cómo lo reparo?

Ejecuta `aas doctor`, después `init-agents --dry-run` y después `init-agents --repair`. La reparación fusiona sin perder datos.

## Cambié de máquina. ¿Qué hago?

Instala la misma versión con `aas install` y después ejecuta `aas doctor` para confirmar el entorno.

## Hay un release nuevo. ¿Tengo que actualizar el proyecto?

No. Aparece un aviso de deriva no bloqueante en `pre-commit` y `doctor` cuando la versión instalada difiere de la fijada en el proyecto. Cuando quieras, ejecuta `aas upgrade` y después `init-agents --dry-run` e `init-agents --repair`.

## ¿Qué son L1, L2 y L3, y qué se aplica de verdad?

L1 son hooks de git locales para feedback rápido y orientativo. L2 es un check remoto `gates` requerido que quien hace el commit no puede saltar. L3 es la revisión con `CODEOWNERS` para rutas sensibles. L2 y L3 requieren GitHub. Un cambio de código sin test que lo cubra se bloquea, local y remotamente.

## ¿Qué configuraciones de git y GitHub se admiten?

Cuatro flujos, y el framework funciona en todos. **Sin git:** solo convención (reglas, skills, `AGENTS.md`); ejecuta `git init` y vuelve a ejecutar `init-agents` para agregar los hooks locales. **Git local:** solo hooks de L1, sin compuerta remota. **Git y GitHub:** L1, L2 y L3 completos. **Git después:** las capas crecen a medida que aparecen; vuelve a ejecutar `init-agents` después de `git init` y después de agregar el remoto, porque instala cada capa de forma condicional. Paso a paso: [Empieza sin git y agrégalo después](../no-git-and-later-git/) y [Conecta el enforcement remoto](../wire-remote-enforcement/).

## ¿Dónde están las guías paso a paso?

La sección Tutoriales recorre los trabajos comunes con comandos listos para copiar y el resultado que deberías ver: tu primer commit con compuerta, conectar el enforcement remoto, empezar sin git, migrar un proyecto heredado y moverte a otra máquina. Ver [Tu primer commit con compuerta](../first-gated-commit/).

## ¿Qué agentes admite?

Diseñado para OpenCode. Portable a Claude Code, Cursor, Codex, Gemini CLI, GitHub Copilot, Windsurf, Aider, Kiro, Zed y cualquier agente que lea `AGENTS.md`. El instalador detecta el agente y conecta las skills y los hooks correspondientes.

## ¿Es gratis?

Sí. Licencia MIT, código abierto, sin suscripciones ni niveles de pago. El instalador, las skills y el enforcement son gratuitos.

## ¿Un agente todavía puede romper las reglas?

Sí. Los hooks lo hacen más difícil, no imposible. Un agente podría malinterpretar una aprobación ambigua o actuar fuera del protocolo. Estas puertas crean fricción, no garantías. La persona sigue en el loop, y la persona sigue atenta.

## ¿Qué es el Harness?

El Harness es todo lo que rodea al modelo y convierte la inteligencia bruta en salida fiable: instrucciones, herramientas, sandboxes, orquestación, guardrails y observabilidad. Agente es igual a Modelo más Harness. La mayoría de los fallos de un agente son fallos de configuración.

## ¿Cómo lo instalo?

Clona y ejecuta `install.sh`, o usa el bootstrap `curl` fijado del último release. Git y curl están disponibles hoy; el wrapper de npm y Homebrew llegan pronto. Después ejecuta `init-agents` en cualquier proyecto. Ver [Primeros pasos](../getting-started/).
