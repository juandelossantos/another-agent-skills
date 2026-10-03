---
title: "Ciclo de vida"
description: "El ciclo de desarrollo de seis fases: Definir, Planear, Construir, Verificar, Revisar, Entregar. Cada fase tiene un criterio de salida y un conjunto de skills."
lang: "es"
order: 10
section: "concepts"
tldr: "Cada tarea pasa por Definir, Planear, Construir, Verificar, Revisar y Entregar. Ninguna fase es opcional, y cada una tiene un criterio de salida y un conjunto de skills que la sostienen."
---

## El camino

```
DEFINIR -> PLANEAR -> CONSTRUIR -> VERIFICAR -> REVISAR -> ENTREGAR
```

Ninguna fase es opcional. Cada paso tiene una skill. Cada skill tiene una puerta.

## Fase 1: Definir

Escribe la especificación antes de cualquier código. Entrevista los requisitos. Fija el alcance.

- **Skills:** `spec-driven-development`, `architecture-analysis`, `interview-me`, `idea-refine`
- **Salida:** `SPEC.md`, `DESIGN.md`, `.gitignore`
- **Puerta:** Sin código hasta que exista el contrato.

## Fase 2: Planear

Divide el trabajo en tareas atómicas. Cada tarea debe ser verificable de forma independiente.

- **Skills:** `planning-and-task-breakdown`
- **Salida:** Una lista de tareas con criterios de aceptación.

## Fase 3: Construir

Implementa una rebanada a la vez. Prueba cada rebanada antes de ampliarla.

- **Skills:** `incremental-implementation`, `test-driven-development`, `source-driven-development`, `doubt-driven-development`
- **Salida:** Código funcional con tests.
- **Puerta:** Cada rebanada se prueba antes de ampliarla.

## Fase 4: Verificar

Ejecuta los tests. Revisa el build. Verifica el comportamiento contra la especificación.

- **Skills:** `test-driven-development`, `debugging-and-error-recovery`, `browser-testing-with-devtools`
- **Salida:** Tests en verde, build limpio.

> **TOOL_GAP:** Si las herramientas no pueden alcanzar el mundo real, informa "estado de entrega desconocido". Nunca finjas un resultado. La ausencia de evidencia no es evidencia de ausencia.

## Fase 5: Revisar

Revisión de código, seguridad, rendimiento, calidad.

- **Skills:** `code-review-and-quality`, `security-and-hardening`, `performance-optimization`
- **Salida:** Un informe de revisión y puertas de calidad superadas.
- **Trabajo de UI:** ejecuta la secuencia de revisión de diseño: critique, audit, clarify, hard, polish, typeset, adapt, optimize, delight.

## Fase 6: Entregar

Commits limpios, CI/CD, despliegue.

- **Skills:** `git-workflow-and-versioning`, `ci-cd-and-automation`, `shipping-and-launch`
- **Salida:** Código desplegado y documentación actualizada.

## Ejecución según el propósito

El ciclo de vida pondera las fases según el propósito de la sesión, de modo que una sesión de lluvia de ideas no se fuerza a pasar por Entregar.

| Propósito | Fases principales | Skills clave |
|---|---|---|
| Lluvia de ideas | Definir | `interview-me`, `idea-refine` |
| Desarrollo | Definir a Construir | `spec-driven-development`, `incremental-implementation`, `test-driven-development` |
| Revisión de código | Revisar | `code-review-and-quality`, `security-and-hardening`, `performance-optimization` |
| Depuración | Verificar | `debugging-and-error-recovery` |
| Revisión de PR | Revisar a Entregar | `pr-review-checklist.sh` |

## Por qué importan las fases

Las fases no son ceremonia. Son los lugares donde un error todavía es barato de corregir. Una especificación equivocada cuesta una conversación. Un build equivocado cuesta un día. Un despliegue equivocado cuesta confianza.
