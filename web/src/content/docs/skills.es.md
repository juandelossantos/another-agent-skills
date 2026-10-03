---
title: "Skills"
description: "Cómo se organizan las 57 skills, cómo se cargan y cómo se mapean al ciclo de vida de seis fases."
lang: "es"
order: 11
section: "concepts"
tldr: "57 skills seleccionadas se mapean al ciclo de vida y se cargan bajo demanda cuando el agente detecta una tarea compatible. Tú describes lo que necesitas; no invocas las skills a mano."
---

## Qué es una skill

Una skill es un conjunto de instrucciones pequeño y enfocado, con un contrato de salida. Cada una es un índice de unas 250 líneas que apunta a guías más profundas, cargadas solo cuando la tarea las necesita. La arquitectura de carga diferida mantiene pequeño el contexto siempre activo y deja disponible el detalle.

Las skills no son un menú que pides. Se cargan cuando el agente reconoce una tarea compatible, y la puerta de skills registra cuáles se consultaron.

## Cómo se activan las skills

Tú describes lo que necesitas. El agente asocia la tarea con una o más skills.

| Dices | Skill que se carga |
|---|---|
| "Agrega una página de login" | `frontend-web` + `spec-driven-development` + `test-driven-development` |
| "Construye una API REST" | `backend-api-mastery` + `api-and-interface-design` |
| "Crea una herramienta CLI" | `cli-tools` + `spec-driven-development` |
| "Revisa este código" | `code-review-and-quality` |
| "Corrige este bug" | `debugging-and-error-recovery` |
| "Escribe tests" | `test-driven-development` |
| "Despliega a producción" | `shipping-and-launch` + `ci-cd-and-automation` |
| "Diseña una landing page" | `frontend-web` + `critique-skill` + `polish-skill` |

Si la detección automática falla, di "carga la skill `test-driven-development`" o "usa TDD para esto".

## Categorías

| Categoría | Ejemplos |
|---|---|
| Fundamentos | `engineering-fundamentals`, `context-engineering`, `user-onboarding` |
| Frontend | `frontend-web`, `frontend-mobile`, `frontend-desktop`, `frontend-pwa` |
| Backend | `backend-api-mastery`, `api-and-interface-design`, `cli-tools` |
| Proceso | `spec-driven-development`, `planning-and-task-breakdown`, `incremental-implementation`, `multi-agent-orchestration` |
| Calidad | `code-review-and-quality`, `test-driven-development`, `security-and-hardening`, `performance-optimization`, `code-simplification` |
| Diseño | `critique-skill`, `audit-skill`, `polish-skill`, `typeset-skill`, `adapt-skill`, `delight-skill` |
| DevOps | `ci-cd-and-automation`, `shipping-and-launch`, `fullstack-shipping` |
| Meta | `skill-creator`, `skill-improver`, `self-improvement` |

## Skills por fase

- **Definir:** `spec-driven-development`, `architecture-analysis`, `interview-me`, `idea-refine`
- **Planear:** `planning-and-task-breakdown`
- **Construir:** `incremental-implementation`, `test-driven-development`, `source-driven-development`, `doubt-driven-development`
- **Verificar:** `test-driven-development`, `debugging-and-error-recovery`, `browser-testing-with-devtools`
- **Revisar:** `code-review-and-quality`, `security-and-hardening`, `performance-optimization`
- **Entregar:** `git-workflow-and-versioning`, `ci-cd-and-automation`, `shipping-and-launch`

## Meta-skills

Tres skills trabajan sobre el propio framework. `skill-creator` genera una skill nueva a partir de una descripción de flujo de trabajo, `skill-improver` lee casos de evaluación que fallan y propone mejoras, y `self-improvement` ejecuta el bucle de auditar, diagnosticar, corregir y registrar.

## La evaluación de cada skill

Cada skill incluye una evaluación que comprueba que se activa con las tareas correctas y produce la forma esperada. La puerta de evaluación corre sobre las skills modificadas antes de que un commit llegue, así que una skill que deja de funcionar se detecta igual que el código.

> 57 skills, 74 guías, 6 componentes del harness y una evaluación para cada una.
