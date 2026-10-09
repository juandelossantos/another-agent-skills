---
title: "Agentes"
description: "Matriz de compatibilidad y configuración por agente: OpenCode, Claude Code, Cursor, Kiro y cualquier agente que use git."
lang: "es"
order: 20
section: "reference"
tldr: "Los hooks de git funcionan en todas partes. Las skills se cargan automáticamente para OpenCode y Claude Code, y el instalador detecta el agente y conecta las skills y los hooks correspondientes."
---

## Qué funciona dónde

| Función | OpenCode | Claude Code | Cursor | Kiro | Cualquier agente git |
|---|---|---|---|---|---|
| Hooks de git | Auto | Auto | Auto | Auto | Auto |
| Puerta de manifiesto | Auto | Auto | Auto | Auto | Auto |
| `SOUL.md` / `AGENTS.md` | Auto | Manual | Manual | Manual | Manual |
| Conceptos de `SKILL.md` | Auto | Auto | Manual | Manual | Manual |
| Detección de stack | Auto | Auto | Auto | Auto | Auto |

## Configuración por agente

### OpenCode (predeterminado)

Sin configuración extra. Las skills se cargan automáticamente mediante la herramienta de skills.

```bash
bash install.sh
cd your-project
init-agents
```

### Claude Code

Paridad completa: las 58 skills se instalan en `~/.claude/skills/` (se detectan automáticamente en cada proyecto) y los hooks de enforcement se conectan solos en `.claude/settings.json`. Para cargar también las reglas de `SOUL.md` y `AGENTS.md`, copia los principios clave en tu `CLAUDE.md`; esa parte sigue siendo manual.

```bash
bash install.sh --agent claude
```

### Cursor

Crea `.cursor-plugin/agent-discipline/` con hooks. Agrega `SOUL.md` y `AGENTS.md` a `.cursorrules`.

```bash
bash install.sh --agent cursor
```

### Kiro

Crea `.kiro/hooks/agent-discipline.json` con los hooks de pre-flight, aprobación de commit y edit guard.

```bash
bash install.sh --agent kiro
```

### Cualquier agente basado en git

Copia los hooks de git en el proyecto. Funcionan con cualquier agente que use git.

```bash
cp scripts/git-hooks/pre-commit .git/hooks/pre-commit
cp scripts/git-hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
cp scripts/commit-approval.sh scripts/
```

## Principios portables

Los principios centrales son agnósticos al agente. Adóptalos en cualquier lugar.

| Principio | Cómo usarlo |
|---|---|
| TOOL_GAP | Cuando las herramientas no pueden verificar, informa "estado de entrega desconocido". Nunca finjas un resultado. |
| Etiquetas de severidad | Clasifica los hallazgos: bloqueante, importante, detalle, sugerencia, aprendizaje, elogio. |
| Diseño de rutas de error | Cada llamada a herramienta, puerta y bucle necesita una ruta de fallo, diseñada al construir. |
| Continuar antes que resumir | Después de perder contexto, retoma. Pregunta "¿dónde estábamos?" en vez de reexplicar. |
| Detección de deriva | Comprueba la documentación contra la realidad con regularidad: datos, versiones, funciones, comandos, enlaces. |
| Puerta de manifiesto | Exige un resumen escrito de lo que cambió antes de aprobar un commit. |

> Se admite cualquier agente que lea `AGENTS.md`. El instalador detecta el agente y conecta las skills y los hooks correspondientes.
