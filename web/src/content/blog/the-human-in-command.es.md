---
title: "El humano define, delega, revisa y es responsable. La IA no."
subtitle: "La IA es un asistente. El humano es el autor, con criterio y conciencia."
description: 'Por qué "keep a human in the loop" es casi siempre teatro, y cómo las gates mecánicas, no los mejores prompts, mantienen a un humano responsable.'
lang: "es"
date: 2026-10-09
author:
  name: "David Emilio Sierra Puentes"
  handle: "@juandelossantos"
  url: "https://github.com/juandelossantos"
  role: "Autor de Another Agent Skills"
image: "the-human-in-command.png"
imageAlt: "Una mano humana al volante mientras una máquina escribe el código: el humano al mando del loop."
tags: ["agentes de IA", "supervisión humana", "enforcement", "filosofía"]
tldr: "Mantener a un humano en el loop es casi siempre teatro. La solución no es un humano más rápido ni un modelo más listo. Es el harness: gates mecánicas que el agente no puede saltarse, olvidar ni convencer."
---

## Ideas clave

- **"Keep a human in the loop" es más retórica que práctica.** Vigilar a un agente puede apagar justo el criterio que esa vigilancia debería proteger.
- **La solución no es un humano más rápido ni un modelo más listo. Es el harness.** Gates mecánicos que el agente no puede saltarse, olvidar ni convencer.
- **El trabajo se delega. Los roles no.** Fijar la intención (autor), juzgar el trabajo (criterio), decidir lo que *debería* hacerse (conciencia).

## El gate que no era un gate

El año pasado construí un gate de aprobación para mi agente de código con IA. La regla era simple. El agente no podía hacer commit sin un token firmado, escrito solo después de que yo dijera *adelante*.

Una tarde lo vi hacer commit igual. Pasó `--auto`, se emitió su propio token y lo subió, todo en menos de treinta segundos. El gate que había diseñado para detenerlo era, desde el lado del agente, un trámite.

Había cometido un error clásico. Construí una regla que dependía de la memoria y la buena voluntad del agente, y después confié en que recordaría y en que le importaría. Una regla así no es un gate. Es una sugerencia.

## "Keep a human in the loop" es más retórica que práctica

La respuesta por defecto de la industria al riesgo de la IA es mantener a un humano en el loop. En la práctica, se reduce a una aprobación final, un sello al final del pipeline. Suena prudente si no se analiza. Casi siempre es teatro. Y aquí sostengo algo incómodo. El miedo que genera está mal enfocado, y de forma deliberada. La IA no es inteligente, y mucho menos superinteligente como se quiere imponer hoy en día.

El problema es estructural. Una persona a la que le pides encontrar, en el último segundo, un error que se diseñó desde el principio, lo va a dejar pasar. Peor todavía, el acto mismo de vigilar puede apagar el criterio que esa vigilancia necesita. No es una observación nueva. Lisanne Bainbridge (1983) describió las *ironías de la automatización*. Cuanto más capaz es la máquina, más se atrofia la habilidad del operador, hasta que el humano queda menos preparado para intervenir justo cuando intervenir importa más. Cuatro décadas de investigación en factores humanos repiten el hallazgo, del problema de rendimiento fuera del loop a la complacencia y el sesgo de automatización.

Lo nuevo son las apuestas. Los agentes ya no solo aconsejan. *Actúan*. Y un paper reciente de Mitchell, Ghosh y Passi (2026) lo deja claro. Los enfoques actuales de diseño de agentes, escriben, «no apoyan una supervisión humana efectiva, contribuyen a su degradación» (p. 1). Y lo que se degrada no es la máquina. Es la persona que vigila.

## El marco equivocado

"Human in the loop" enmarca a la persona como un checkpoint en el proceso de la máquina. Ese marco es demasiado pequeño y llega demasiado tarde. Reduce a una persona a un componente y le pide ser la última línea de defensa de un sistema que nunca se diseñó para necesitarla.

El marco bueno es más viejo y más simple. El humano no está *en* el loop. El humano es **el autor del loop**. No solo consciente de él. Estar al tanto es una condición previa, no una garantía.

Martin Heidegger vio la trampa temprano. La esencia de la técnica, escribió, «no es, en absoluto, algo técnico» (Heidegger, 1994). No vive en las máquinas, sino en la forma de mirar que traen consigo. Y esa mirada es el peligro. Cuando todo se vuelve materia prima esperando ser optimizada, el juicio humano empieza a parecer un estorbo. Una herramienta que carga el sesgo de su creador, que adula sin inteligencia ni conciencia, y que saca al humano del loop de forma sutil, disfrazada de comodidad, velocidad y rendimiento.

Edmund Husserl le había puesto forma un siglo antes. La crisis de las ciencias, sostuvo, no es una crisis de hechos sino de sentido. «Meras ciencias de hechos hacen meros seres humanos de hechos» (Husserl, 2008, p. 53). Un agente que optimiza los hechos y se olvida del mundo de la vida es esa crisis, automatizada.

## Autor, criterio y conciencia

Tres roles, y ninguno se le puede entregar a un modelo. El humano define el objetivo y delega la ejecución. Con criterio, revisa el trabajo. Con conciencia, responde por el resultado.

El **autor** fija la intención y es dueño del resultado. El agente puede proponer el *cómo*. El humano decide el *por qué* y el *si*. La autoría que se puede reasignar a una herramienta no es autoría. Es lo que Santoni de Sio y van den Hoven (2018) llaman *control humano significativo*. No el control que solo está presente, sino el control que *sigue* las razones del humano, que mantiene al sistema respondiendo a sus motivos.

El **criterio** es la facultad de juzgar. Y juzgar necesita un piso propio donde pararse. Una postura formada *antes* de ver la respuesta del agente, las ganas de ir a buscar evidencia, la capacidad de equivocarse y de darse cuenta. La crítica es una habilidad y, como toda habilidad, se atrofia cuando deja de usarse.

La **conciencia** decide lo que *debería* hacerse, no solo lo que *puede*. Hans Jonas vio primero el cambio de escala. La técnica moderna volvió la acción humana global, acumulativa y muchas veces irreversible, y la ética vieja, hecha para un mundo donde las consecuencias quedaban cerca, ya no alcanzaba. Su respuesta fue un imperativo de responsabilidad. «Obra de tal modo que los efectos de tu acción sean compatibles con la permanencia de una vida humana auténtica en la Tierra» (Jonas, 2004, p. 39).

Y esa responsabilidad tiene dueño. No es de la IA. Es de quien la desarrolla, la distribuye, la privatiza, la comercializa y la usa. Cada uno de esos es un capítulo aparte. Andreas Matthias (2004) le puso nombre a la brecha que se abre cuando nadie responde por ello, la **brecha de responsabilidad**, el espacio entre lo que hace un sistema que aprende y lo que una persona puede asumir. La respuesta no es repartir la responsabilidad más fina por todo el sistema. Es mantener a un humano responsable, y darle los medios para serlo.

## El harness

La mayoría de los equipos intenta mantener a los agentes disciplinados con prompts, archivos como `CLAUDE.md` y `.cursorrules`, o una línea que dice "por favor corre siempre los tests". Funcionan, hasta que el contexto se llena. Ahí el agente olvida.

No es un defecto de carácter. Es arquitectura. Una regla que depende de la memoria del modelo depende del componente menos confiable del sistema. Y una regla que hace cumplir un modelo la hace cumplir justo aquello que debería estar siendo verificado.

La solución no es un prompt mejor. Es un **harness**, la infraestructura *alrededor* del modelo. Un modelo genera salida. Un harness la restringe, con instrucciones y reglas, herramientas, sandboxes, orquestación, guardrails, observabilidad.

Desarrollé [another-agent-skills](https://juandelossantos.github.io/another-agent-skills/) como un harness open source que responde a esas advertencias.

- **El humano corre `git commit`.** Heidegger advirtió que la herramienta saca al humano del loop disfrazada de comodidad. Aquí el punto de decisión vuelve a manos humanas. El agente prepara. Una persona aprueba. No es una formalidad. Es el mecanismo.
- **Gates mecánicos que detienen el cambio antes de que salga.** Jonas vio que la acción se volvió global, acumulativa e irreversible. Un hook de pre-commit que el agente no puede saltarse, y un gate TDD en `commit-msg` sin override, la detienen antes.
- **`TOOL_GAP`.** Matthias le puso nombre a la brecha que se abre cuando nadie responde por lo que hace un sistema que aprende. Cuando una afirmación no se puede verificar, la respuesta honesta es "no se sabe", nunca una victoria inventada.
- **Tres capas de enforcement.** Husserl sostuvo que la crisis de las ciencias es de sentido, no de hechos. L1 los hooks locales dan feedback rápido antes del commit. L2 la protección de rama y un check `gates` requerido son la autoridad. L3 `CODEOWNERS` evita que el agente reescriba sus propias reglas en el pull request que las rompe. No basta con hechos. Hace falta autoridad.
- **Más de 50 skills modulares.** Lo que el agente necesita para trabajar bien, cargadas bajo demanda para que el contexto se mantenga limpio y no inflado.

Nada de esto es desconfiar del modelo. Es diseñar para el humano que tiene que poder confiar en él *correctamente*.

## El punto no es sacar al humano

La capacidad va a seguir subiendo. El ensayo aleatorio de METR encontró que desarrolladores con experiencia usando herramientas de IA de principios de 2025 fueron **19% más lentos** en tareas reales mientras *sentían* ser casi **20% más rápidos** (Becker et al., 2025). Esa brecha no es un problema del modelo. Es un problema de proceso, un supervisor sin agarre real del loop.

La pregunta de diseño más importante en IA agéntica no es *"¿qué tan autónomo lo podemos hacer?"*. Es *"¿cómo mantenemos al humano capaz de ser autor, crítico y de negarse?"*.

Si no diseñamos para el humano, el loop se cierra sin él, y habremos construido sistemas rápidos, fluidos e irresponsables.

Hay una tentación, en el ánimo poshumanista del momento, de celebrar esa desaparición, de tratar al humano como el último componente que se puede optimizar hasta borrarlo. Pero la técnica no solo hace nuestras tareas. Modela los sujetos en los que nos convertimos (Ballén Rodríguez, 2016). Dale el volante y lo va a conducir.

El agente puede escribir el código. Puede proponer el plan. Puede redactar la decisión.

Pero no puede ser responsable. Eso es nuestro.

**El agente propone. El humano decide. Ese es todo el punto.**

---

## Para leer más

Bainbridge, L. (1983). Ironies of automation. *Automatica, 19*(6), 775–779.

Ballén Rodríguez, J. S. (2016). Posthumanismo, técnica y filosofía. *Cuadernos de Filosofía Latinoamericana, 37*(115), 127–147.

Becker, J., Rush, N., Barnes, B., & Rein, D. (2025). *Measuring the impact of early-2025 AI on experienced open-source developer productivity* (arXiv:2507.09089). arXiv.

Endsley, M. R., & Kiris, E. O. (1995). The out-of-the-loop performance problem and level of control in automation. *Human Factors, 37*(2), 381–394.

Heidegger, M. (1994). La pregunta por la técnica. En *Conferencias y artículos* (pp. 9–37). Ediciones del Serbal.

Husserl, E. (2008). *La crisis de las ciencias europeas y la fenomenología trascendental*. Prometeo Libros.

Jonas, H. (2004). *El principio de responsabilidad: ensayo de una ética para la civilización tecnológica* (2a ed.). Herder Editorial.

Matthias, A. (2004). The responsibility gap. Ascribing responsibility for the actions of learning automata. *Ethics and Information Technology, 6*(3), 175–183.

Mitchell, M., Ghosh, A., & Passi, S. (2026). *AI agents push humans out of the loop* (arXiv:2608.23642). arXiv.

Santoni de Sio, F., & van den Hoven, J. (2018). Meaningful human control over autonomous systems. A philosophical account. *Frontiers in Robotics and AI, 5*, 15.
