---
title: "Primeros pasos"
description: "Instala Another Agent Skills, ejecuta init-agents y observa cómo la puerta local bloquea un commit que no tiene un test que lo cubra."
lang: "es"
order: 2
section: "start"
tldr: "Instala con git clone o el bootstrap curl fijado (o npm); ejecuta init-agents en cualquier proyecto; el instalador detecta tu agente y tu stack y conecta las skills y los hooks correspondientes."
---

## Requisitos

- **Git** en el `PATH`.
- **Bash** en Linux y macOS, o **PowerShell** en Windows (Git Bash es la ruta recomendada en Windows).
- Un agente: **OpenCode** es el predeterminado, o cualquier agente compatible como Claude Code, Cursor, Codex, Gemini CLI o Kiro.

## Instalar el framework

El instalador coloca las skills de forma global, una vez por máquina. Cualquier proyecto puede usarlas sin duplicar los archivos.

```bash
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
bash install.sh
```

Windows (PowerShell):

```powershell
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
.\install.ps1
```

O usa el bootstrap del release fijado, que descarga el release etiquetado, verifica su checksum y enlaza la CLI `aas`:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

El wrapper de npm no incluye payload propio:

```bash
npx @juandelossantos/another-agent-skills install
```

## Inicializar un proyecto

Ejecuta `init-agents` dentro del proyecto. Fusiona `AGENTS.md` sin sobrescribir tus reglas, enlaza los archivos del framework, detecta tu stack e instala los hooks que corresponden a la forma actual del repositorio.

```bash
cd your-project
init-agents
```

Para un proyecto nuevo:

```bash
mkdir my-project && cd my-project
git init
init-agents
```

## Qué ocurre en un proyecto existente

1. Detecta un `AGENTS.md`, `CLAUDE.md` o `.cursorrules` existente.
2. Hace una copia de seguridad del archivo existente.
3. Fusiona las reglas del framework y conserva las tuyas.
4. Detecta tu stack y crea `STACK_CONFIG.md` si falta.
5. Instala los hooks y respalda los hooks existentes.
6. Muestra un resumen de "Próximos pasos".

## Detección de stack

`init-agents` detecta tu stack a partir de lockfiles y archivos de configuración, y escribe `STACK_CONFIG.md` con tus comandos reales (test, lint, build, dev). Todas las skills leen de ese archivo.

| Stack | Detecta desde |
|---|---|
| Node.js | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb` |
| Rust | `Cargo.lock`, `Cargo.toml` |
| Python | `poetry.lock`, `Pipfile.lock`, `pyproject.toml` |
| Go | `go.sum`, `go.mod` |
| Ruby | `Gemfile.lock`, `Gemfile` |
| Dart | `pubspec.lock`, `pubspec.yaml` |

## Verificar el enforcement

Haz un cambio de código sin un test que lo cubra y observa cómo la puerta local bloquea el commit:

```bash
$ git commit -m "feat: add checkout"
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: none
✗ BLOCKED: every code change needs a matching test.
```

El mismo check corre en remoto como el estado `gates` requerido. Ver [Enforcement](../enforcement/).

## Solución de problemas

| Problema | Solución |
|---|---|
| `init-agents: command not found` | Recarga la configuración de tu shell, por ejemplo `source ~/.zshrc`. |
| `STACK_CONFIG.md not found` | Ejecuta `init-agents` en el proyecto. |
| El hook de pre-commit no se dispara | Vuelve a ejecutar `bash scripts/init-agents.sh`. |
| "No commit approval found" | El agente debe presentar un DECISION POINT, obtener una aprobación explícita y después ejecutar `bash scripts/commit-approval.sh "message"`. |

## Migrar o reparar

Si heredaste un proyecto que ya usaba el framework, o cambiaste de máquina, repara sin perder datos:

```bash
aas doctor
init-agents --dry-run
init-agents --repair
```

> Un compañero que clona tu proyecto sin el framework no queda bloqueado: el proyecto sigue funcionando. El check remoto `gates` aplica las reglas para todos en el repositorio.
