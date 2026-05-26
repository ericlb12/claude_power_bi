# Opción B — Plugin de la comunidad (powerbi-mcp-claude)

> **Estado: BLOQUEADO** — hereda el mismo requisito que la Opción A.

## Por qué está bloqueado

El plugin es un **proxy sobre el endpoint oficial** (`api.fabric.microsoft.com/v1/mcp/powerbi`).
No esquiva el requisito de la preview — lo hereda. Si el tenant no tiene la preview
activa, el plugin se autentica bien pero **falla al listar workspaces**.

→ Primero hay que desbloquear lo del admin (ver `opcion-a-remote-oficial.md`).

## Qué da

Igual que la Opción A: acceso a modelos **publicados** sin tener Desktop abierto,
pero empaquetado como plugin de Claude Code con login device-code desde el chat.

## Setup (cuando se desbloquee)

1. Clonar el repo:
   ```bash
   git clone https://github.com/robertoamoreno/powerbi-mcp-claude
   cd powerbi-mcp-claude
   npm install && npm run build
   ```
2. Registrar como plugin:
   ```bash
   claude --plugin-dir <ruta-al-repo-clonado>
   ```
3. Login con device-code desde el chat de Claude Code.
