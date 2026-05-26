# Setup: Claude Code + Power BI Modeling MCP (Windows, modelo local)

## Contexto

No tengo acceso de admin al tenant de Power BI, así que las opciones de servidor
remoto (oficial de Microsoft + plugin `powerbi-mcp-claude`) están bloqueadas hasta
que un admin active la preview. Voy con el **Modeling MCP local** que corre contra
Power BI Desktop. Sistema operativo: Windows.

> **Nota sobre la config MCP:** el plan original usaba `.claude.json` con una clave
> raíz vacía. Eso es el formato del config **global** de Claude Code (claves = rutas
> de proyecto). Para un MCP scoped a este repo y versionable usamos **`.mcp.json`**
> en la raíz — es lo que Claude Code carga automáticamente al lanzarse desde esta
> carpeta. Plantilla en [`.mcp.json.example`](.mcp.json.example).

## Objetivo

Que Claude Code pueda leer el contexto (tablas, columnas, relaciones, medidas, DAX)
de un modelo de Power BI abierto localmente en Power BI Desktop, y opcionalmente
modificarlo previa aprobación explícita.

## Pre-requisitos a verificar

1. Power BI Desktop instalado y actualizado.
2. Visual Studio Code instalado (solo como vehículo para obtener el binario MCP).
3. Node.js LTS instalado (lo usaremos para el script de mantenimiento).
4. Una **COPIA** del `.pbix` con el que vamos a trabajar — nunca el de producción.

## Fase 1 — Preparar Power BI Desktop

1. Abrir Power BI Desktop → File → Options and settings → Options → Preview features.
2. Activar las cuatro casillas:
   - Power BI Project (.pbip) save option
   - Store semantic model using TMDL format
   - Store reports using enhanced metadata format (PBIR)
   - Store PBIX reports using enhanced metadata format (PBIR)
3. OK y reiniciar Power BI Desktop.
4. Abrir la COPIA del `.pbix`.
5. File → Save as → seleccionar tipo "Power BI Project files (.pbip)".
6. Guardar en una ruta dentro del repo de este setup (o referenciada desde él).

## Fase 2 — Instalar el MCP server

1. Abrir VS Code → Extensions.
2. Buscar "Power BI Modeling MCP Server" (publisher: `analysis-services`).
3. Instalar.
4. Verificar que el binario existe. La ruta sigue el patrón:
   `C:\Users\<USUARIO>\.vscode\extensions\analysis-services.powerbi-modeling-mcp-<VERSION>-win32-x64\server\powerbi-modeling-mcp.exe`
5. Anotar la versión exacta instalada — se usará en la config.
6. (VS Code ya no se vuelve a tocar después de esto.)

## Fase 3 — Configurar Claude Code

1. Copiar `.mcp.json.example` a `.mcp.json` en la raíz del proyecto.
2. Sustituir `<USUARIO>` y `<VERSION>` por valores reales.
3. Usar dobles backslashes en las rutas (JSON las requiere).
4. `.mcp.json` real va en `.gitignore` (contiene la ruta personal); se commitea solo
   `.mcp.json.example`.

## Fase 4 — Verificar la conexión

1. Cerrar cualquier sesión de Claude Code existente.
2. Lanzar Claude Code **DESDE la carpeta del proyecto** (el scope es por carpeta).
3. Ejecutar el comando `/mcp` dentro de Claude Code.
4. Confirmar que `powerbi-modeling-mcp` aparece con estado "connected" en verde.
5. Si no aparece:
   - Verificar que la ruta del `.exe` existe:
     `dir "C:\Users\<USUARIO>\.vscode\extensions\analysis-services.powerbi-modeling-mcp-*"`
   - Verificar que el JSON es válido (sin comas colgantes, backslashes dobles).
   - Confirmar que Claude Code se lanzó desde la carpeta correcta.

## Fase 5 — Prueba humo

Con Power BI Desktop abierto y el `.pbip` cargado, pedirle a Claude Code:

1. "Conéctate a mi instancia local de Power BI Desktop."
2. "Dame un resumen del modelo: número de tablas, columnas y medidas."
3. "Lista las medidas existentes con su DAX."
4. "Genera un diagrama mermaid de las relaciones entre tablas."

Si los cuatro funcionan, el setup está listo.

## Fase 6 — Script de mantenimiento (version-pinning)

**PROBLEMA:** VS Code auto-actualiza la extensión y la versión en la ruta cambia,
rompiendo `.mcp.json`.

**SOLUCIÓN:** [`scripts/update-mcp-path.ps1`](scripts/update-mcp-path.ps1) busca la
carpeta de extensión más reciente que coincida con el patrón, reconstruye la ruta al
`.exe` y reescribe el campo `command` en `.mcp.json`. Ejecutarlo después de cada
actualización de VS Code. Lanzador de un click: `scripts/update-mcp-path.bat`.

## Cuando consigas acceso al tenant

Tener listo este repo para activar las Opciones A y B (ambas dan acceso a modelos
**publicados** sin necesidad de tener Desktop abierto):

- **Opción B** (plugin comunidad): ver [`docs/opcion-b-plugin-comunidad.md`](docs/opcion-b-plugin-comunidad.md).
- **Opción A** (remoto oficial): ver [`docs/opcion-a-remote-oficial.md`](docs/opcion-a-remote-oficial.md).

## Estructura del repo

```
claude_power_bi/
├── README.md                     ← este plan
├── CLAUDE.md                     ← reglas de seguridad para Claude Code
├── .mcp.json.example             ← plantilla sin datos personales
├── .gitignore                    ← .mcp.json real, *.pbix, *.pbip
├── scripts/
│   ├── update-mcp-path.ps1       ← version-pinning (Fase 6)
│   └── update-mcp-path.bat       ← lanzador de un click
└── docs/
    ├── opcion-a-remote-oficial.md
    └── opcion-b-plugin-comunidad.md
```
