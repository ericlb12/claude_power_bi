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

- La config MCP real (`.mcp.json`) está en `.gitignore` porque contiene la ruta
  personal del binario. Solo se versiona `.mcp.json.example`.
- Archivos `.pbix` y `.pbip` NO se commitean (`.gitignore`).
- Tras cualquier actualización de VS Code que cambie la versión de la extensión,
  ejecutar `scripts/update-mcp-path.ps1` para re-apuntar la ruta del binario.
