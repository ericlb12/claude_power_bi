# CLAUDE.md — Reglas para Claude Code en este repo

Este repo configura el **Power BI Modeling MCP** local contra Power BI Desktop.

## Reglas de seguridad (OBLIGATORIAS)

- **NUNCA** correr operaciones de modificación contra un `.pbix` de producción.
  Trabajar siempre sobre una COPIA.
- **ANTES** de aplicar cualquier cambio al modelo (medidas, columnas, relaciones,
  tablas), mostrar el plan completo y esperar confirmación explícita del usuario
  ("aplica" o "go").
- Las queries DAX de **solo lectura** no requieren confirmación.
- El servidor MCP soporta el protocolo **Elicitation** y por defecto pide aprobación
  antes de la primera modificación y la primera query. **NO** usar la flag
  `--skipconfirmation` salvo que el usuario lo justifique explícitamente.

## Convenciones del repo

- El server MCP se lanza vía `npx @microsoft/powerbi-modeling-mcp@latest` (no requiere
  VS Code ni binario local). Solo se versiona `.mcp.json.example`; el `.mcp.json` real
  está en `.gitignore`.
- Archivos `.pbix`, `.pbip` y las carpetas `*.SemanticModel/` / `*.Report/` NO se
  commitean (`.gitignore`) — contienen datos de negocio y el repo es público.
