---
title: "Resumen"
description: "Qué es Another Agent Skills: 57 skills componibles y enforcement mecánico que convierte a los agentes de IA en ingenieros senior disciplinados."
lang: "es"
order: 1
section: "start"
tldr: "Another Agent Skills es un framework de 57 skills componibles más enforcement mecánico (L1 hooks locales, L2 el check remoto gates requerido, L3 revisión con CODEOWNERS) que convierte a los agentes de IA en ingenieros senior disciplinados."
---

## Qué es

Another Agent Skills es un framework de 57 skills componibles que convierten a los agentes de codificación con IA en ingenieros senior disciplinados. La mayoría de las librerías de skills venden capacidad. Esta vende disciplina que puedes verificar: cada tarea sigue un ciclo de vida de seis fases, y las partes que importan están respaldadas por mecanismos, no por prompts.

La idea central es simple. Una regla que vive solo en un archivo es una sugerencia. Una regla que vive en una capa es una puerta. El framework incluye las capas: hooks de git locales para feedback rápido, un check remoto `gates` requerido como autoridad, y revisión con `CODEOWNERS` para la configuración de las puertas.

## La tesis

- Los modelos capaces igual se saltan tests, revisión y contexto. La brecha es de proceso, no de inteligencia.
- Las skills se mapean a un ciclo de vida: Definir, Planear, Construir, Verificar, Revisar, Entregar. Ninguna fase es opcional.
- El enforcement tiene tres capas. Un cambio de código sin test que lo cubra se bloquea, local y remotamente.
- El agente nunca ejecuta `git commit` ni `git push`. Lo hace la persona.

## De un vistazo

| Dato | Valor |
|---|---|
| Skills | 57, mapeadas al ciclo de vida de seis fases |
| Guías | 151 |
| Componentes del harness | 6 |
| Enforcement | L1 hooks locales, L2 check `gates` requerido, L3 `CODEOWNERS` |
| Licencia | MIT |
| Canales de instalación | `git clone` y bootstrap `curl` fijado (activos); wrapper de npm y Homebrew (próximamente) |
| Agentes | OpenCode primero, portable a Claude Code, Cursor, Codex, Gemini CLI, Copilot y cualquier agente que lea `AGENTS.md` |

## A dónde ir ahora

- [Primeros pasos](getting-started/) recorre la instalación y tu primer proyecto.
- [Ciclo de vida](lifecycle/) explica las seis fases y sus criterios de salida.
- [Enforcement](enforcement/) muestra el modelo L1/L2/L3 con salida real.
- [Protección de ramas](branch-protection/) activa la capa de autoridad remota.

## Guías

Cinco recorridos breves, cada uno con comandos listos para copiar y el resultado que deberías ver:

- [Tu primer commit con compuerta](first-gated-commit/) — observa cómo la compuerta local bloquea un cambio de código sin test.
- [Conecta el enforcement remoto](wire-remote-enforcement/) — haz que `gates` sea un check requerido.
- [Empieza sin git y agrégalo después](no-git-and-later-git/) — haz crecer las capas a medida que aparecen.
- [Migra un proyecto heredado](migrate-a-legacy-project/) — `aas doctor` → `--dry-run` → `--repair`.
- [Muévete a otra máquina](move-to-another-machine/) — reinstala la misma versión y confirma.

Las [Preguntas frecuentes](faq/) responden las dudas comunes de forma directa y citan los hechos.

> El framework funciona sin conexión después de instalarlo, no tiene dependencias externas en tiempo de ejecución y no incluye rastreadores.
