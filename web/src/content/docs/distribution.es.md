---
title: "Distribución y actualizaciones"
description: "Cómo llega Another Agent Skills a los usuarios: git clone, el bootstrap curl fijado, la CLI aas y el wrapper de npm, además de cómo funcionan las actualizaciones."
lang: "es"
order: 21
section: "reference"
tldr: "La distribución está fijada a un release inmutable, nunca a una rama mutable. Cada canal descarga el mismo tarball etiquetado y verifica su sha256 antes de extraer nada."
---

## Principio

La distribución está fijada a un release inmutable, nunca a una rama mutable. Cada canal descarga al final el mismo tarball del GitHub Release etiquetado y verifica su `sha256` contra el `checksums.txt` del release antes de extraer nada. El release lo construye y lo atestigua CI; los instaladores son delgados.

## Canales

| Canal | Para quién | Qué hace | Nunca |
|---|---|---|---|
| `git clone` | Contribuidores | Clona el repositorio y ejecuta `bash install.sh` | - |
| Bootstrap `curl` fijado | Instalación en una línea (Linux, macOS, Git Bash) | Descarga el tarball fijado, verifica el checksum, enlaza la CLI `aas` | Descarga `main` |
| CLI `aas` | Uso diario tras el bootstrap | `install`, `upgrade`, `doctor`, `uninstall` | Descarga `main` |
| Wrapper de npm | Usuarios de Node | `npx @juandelossantos/another-agent-skills install` | No incluye payload |

## Instalar con el bootstrap

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

`bootstrap.sh --version vX.Y.Z` fija un release exacto, `--dry-run` imprime cada acción sin escribir nada, y `--uninstall` elimina la raíz de instalación y el enlace `aas`. La raíz de instalación es `${XDG_DATA_HOME:-$HOME/.local/share}/another-agent-skills`, configurable con `AAS_HOME`.

## La CLI aas

```bash
aas install --agents auto     # activar en el proyecto actual
aas doctor                    # informe del entorno (agentes, estado del plugin)
aas upgrade                   # autoactualización desde el último release fijado
aas uninstall                 # eliminar la CLI, la raíz de instalación y la entrada del PATH
```

`--agents auto|all|<list>` selecciona en qué agentes detectados instalar. `auto` solo pregunta cuando stdin es una TTY, así que CI nunca se bloquea.

## npm

```bash
npx @juandelossantos/another-agent-skills install
npx @juandelossantos/another-agent-skills install --version v6.3.2
```

El paquete de npm contiene solo `cli.js` y un README. Descarga el tarball del release y `checksums.txt`, verifica el sha256 con `node:crypto` y delega en el `bootstrap.sh` del propio release, así que la lógica de instalación vive en un único lugar. Se publica con OIDC trusted publishing (sin token almacenado).

## Automatización del release

Empujar un tag `v*` dispara un flujo que construye el tarball más `checksums.txt`, atestigua la procedencia del build y publica el GitHub Release. Un segundo flujo sincroniza la versión de npm desde `VERSION`, omite el paso si esa versión ya existe y publica mediante OIDC Trusted Publishing sin token almacenado. Verifica un release localmente:

```bash
gh attestation verify dist/another-agent-skills-vX.Y.Z.tar.gz --repo juandelossantos/another-agent-skills
```

## Actualizaciones

```bash
aas upgrade    # autoactualización al último release fijado (atómica)
```

`aas upgrade` resuelve el último release y lo instala de forma atómica (directorio de staging más rename), así que una extracción parcial nunca deja una instalación rota. Para un proyecto que fija una versión del framework, aparece un aviso de deriva no bloqueante en `pre-commit` y `doctor` cuando la versión instalada difiere de la del proyecto en `.aas/config`. Ejecuta `aas upgrade` y después `init-agents --repair` para migrar.

> La cuenta de npm debe existir antes de poder configurar un Trusted Publisher, así que la primera publicación es un paso manual único. Después, los releases se publican con un token OIDC de corta duración.
