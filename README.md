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

## Fase 2 — Configurar el MCP server (vía npx, sin VS Code)

Microsoft publica el server en npm (`@microsoft/powerbi-modeling-mcp`). Como Node.js
ya está instalado, no hace falta VS Code ni descargar binarios: `npx` baja y ejecuta
la última versión automáticamente.

1. Copiar `.mcp.json.example` a `.mcp.json` en la raíz del proyecto (ya está listo,
   sin placeholders que rellenar):
   ```json
   {
     "mcpServers": {
       "powerbi-modeling-mcp": {
         "type": "stdio",
         "command": "npx",
         "args": ["-y", "@microsoft/powerbi-modeling-mcp@latest", "--start"]
       }
     }
   }
   ```
2. `.mcp.json` va en `.gitignore` igualmente; se versiona solo `.mcp.json.example`.

> **Alternativa sin Node** (si npx diera problemas): instalar la extensión "Power BI
> Modeling MCP Server" (publisher `analysis-services`) en VS Code, o descargar el VSIX
> del Marketplace, renombrarlo a `.zip`, extraerlo y apuntar `command` al
> `powerbi-modeling-mcp.exe`. Es el camino antiguo y exige re-apuntar la ruta tras cada
> actualización; usar solo como fallback.

## Fase 4 — Verificar la conexión

1. Cerrar cualquier sesión de Claude Code existente.
2. Lanzar Claude Code **DESDE la carpeta del proyecto** (el scope es por carpeta).
3. Ejecutar el comando `/mcp` dentro de Claude Code.
4. Confirmar que `powerbi-modeling-mcp` aparece con estado "connected" en verde.
5. Si no aparece:
   - Verificar que Node.js está instalado (`node --version`, `npx --version`).
   - La primera ejecución de `npx` descarga el paquete; puede tardar unos segundos.
   - Verificar que el JSON es válido (sin comas colgantes).
   - Confirmar que Claude Code se lanzó desde la carpeta correcta.

## Fase 5 — Prueba humo

Con Power BI Desktop abierto y el `.pbip` cargado, pedirle a Claude Code:

1. "Conéctate a mi instancia local de Power BI Desktop."
2. "Dame un resumen del modelo: número de tablas, columnas y medidas."
3. "Lista las medidas existentes con su DAX."
4. "Genera un diagrama mermaid de las relaciones entre tablas."

Si los cuatro funcionan, el setup está listo.

> **Versionado:** con `npx ... @latest` el server se auto-actualiza en cada arranque,
> así que no hay ruta versionada que mantener (el viejo script `update-mcp-path.ps1` ya
> no es necesario y se eliminó). Si quieres fijar una versión concreta, sustituye
> `@latest` por `@x.y.z` en `.mcp.json`.

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
├── .mcp.json.example             ← plantilla npx (sin placeholders)
├── .gitignore                    ← .mcp.json real, *.pbix, *.pbip, modelo
└── docs/
    ├── opcion-a-remote-oficial.md
    └── opcion-b-plugin-comunidad.md
```

El modelo en `.pbip` + `*.SemanticModel/` + `*.Report/` se trabaja localmente pero
no se versiona (está en `.gitignore` — contiene datos de negocio).
