---
title: "Skills"
description: "Referencia detallada de las 57 skills: qué hace cada una, cuándo se activa, cuándo usarla y cuándo no."
lang: "es"
order: 11
section: "concepts"
tldr: "57 skills, cada una con un disparador y un contrato de salida. Son índices que se cargan bajo demanda; la meta-skill using-agent-skills enruta cada tarea a la correcta. Tú describes la tarea, no la skill."
---

## Índice

- [Fundamentos](#cat-foundation) · [Ideación](#cat-ideation) · [Proceso](#cat-process) · [Frontend](#cat-frontend) · [Backend](#cat-backend) · [Pruebas](#cat-testing) · [Calidad](#cat-quality)
- [Revisión de diseño](#cat-design-review) · [Pieles de diseño](#cat-design-skins) · [Git](#cat-git) · [DevOps](#cat-devops) · [Métricas](#cat-metrics) · [Meta](#cat-meta)

## Qué es una skill

Una skill es un conjunto de instrucciones pequeño y enfocado, con un contrato de salida. Cada una es un índice de unas 250 líneas que apunta a guías más profundas, cargadas solo cuando la tarea las necesita. La arquitectura de carga diferida mantiene pequeño el contexto siempre activo y deja disponible el detalle.

Las skills no son un menú que pides. Se cargan cuando el agente reconoce una tarea compatible, y la compuerta de skills registra cuáles se consultaron.

## Cómo se activan las skills

Tú describes lo que necesitas. La meta-skill `using-agent-skills` enruta la tarea a una o más skills según sus disparadores.

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

## Cómo leer el catálogo

Cada entrada de abajo se genera a partir del propio `SKILL.md` de la skill. Muestra el **nombre** de la skill, un **qué** de una línea, los **disparadores** que la activan, para qué **sirve** y para qué **no sirve**. El número es la cantidad de guías más profundas que incluye la skill; el enlace `SKILL.md` abre la fuente de verdad.

## Skills por fase

- **Definir:** `spec-driven-development`, `architecture-analysis`, `interview-me`, `idea-refine`
- **Planear:** `planning-and-task-breakdown`
- **Construir:** `incremental-implementation`, `test-driven-development`, `source-driven-development`, `doubt-driven-development`
- **Verificar:** `test-driven-development`, `debugging-and-error-recovery`, `browser-testing-with-devtools`
- **Revisar:** `code-review-and-quality`, `security-and-hardening`, `performance-optimization`
- **Entregar:** `git-workflow-and-versioning`, `ci-cd-and-automation`, `shipping-and-launch`

## Meta-skills

Cuatro skills trabajan sobre el propio framework. `skill-creator` genera una skill nueva a partir de una descripción de flujo de trabajo, `skill-improver` lee casos de evaluación que fallan y propone mejoras, `self-improvement` ejecuta el bucle de auditar, diagnosticar, corregir y registrar, y `customize-opencode` edita la configuración propia de OpenCode.

## La evaluación de cada skill

Cada skill incluye una evaluación que comprueba que se activa con las tareas correctas y produce la forma esperada. La compuerta de evaluación corre sobre las skills modificadas antes de que un commit llegue, así que una skill que deja de funcionar se detecta igual que el código.
