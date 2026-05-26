<#
.SYNOPSIS
  Re-apunta el campo "command" de .mcp.json al binario del Power BI Modeling MCP
  más reciente instalado por la extensión de VS Code.

.DESCRIPTION
  VS Code auto-actualiza la extensión y la versión va en la ruta de la carpeta, lo
  que rompe .mcp.json. Este script busca la carpeta de extensión más reciente que
  coincide con el patrón, reconstruye la ruta al .exe y reescribe el campo command.

  Ejecutar después de cada actualización de VS Code.

.NOTES
  Si .mcp.json no existe todavía, lo crea a partir de .mcp.json.example.
#>

$ErrorActionPreference = "Stop"

# Raíz del repo = carpeta padre de este script
$repoRoot   = Split-Path -Parent $PSScriptRoot
$mcpJson    = Join-Path $repoRoot ".mcp.json"
$mcpExample = Join-Path $repoRoot ".mcp.json.example"

$extRoot = Join-Path $env:USERPROFILE ".vscode\extensions"
$pattern = "analysis-services.powerbi-modeling-mcp-*-win32-x64"

# 1. Localizar la carpeta de extensión más reciente
$extDir = Get-ChildItem -Path $extRoot -Directory -Filter $pattern -ErrorAction SilentlyContinue |
          Sort-Object LastWriteTime -Descending |
          Select-Object -First 1

if (-not $extDir) {
    Write-Error "No se encontró ninguna extensión que coincida con '$pattern' en $extRoot. ¿Está instalada en VS Code?"
    exit 1
}

# 2. Construir la ruta al .exe
$exePath = Join-Path $extDir.FullName "server\powerbi-modeling-mcp.exe"
if (-not (Test-Path $exePath)) {
    Write-Error "La extensión existe ($($extDir.Name)) pero falta el binario: $exePath"
    exit 1
}
Write-Host "Binario encontrado: $exePath" -ForegroundColor Green

# 3. Asegurar que .mcp.json existe (crear desde el ejemplo si hace falta)
if (-not (Test-Path $mcpJson)) {
    if (-not (Test-Path $mcpExample)) {
        Write-Error "No existe .mcp.json ni .mcp.json.example en $repoRoot"
        exit 1
    }
    Copy-Item $mcpExample $mcpJson
    Write-Host "Creado .mcp.json a partir de la plantilla." -ForegroundColor Yellow
}

# 4. Reescribir el campo command
$config = Get-Content $mcpJson -Raw | ConvertFrom-Json
if (-not $config.mcpServers.'powerbi-modeling-mcp') {
    Write-Error "El bloque 'powerbi-modeling-mcp' no existe en .mcp.json"
    exit 1
}
$config.mcpServers.'powerbi-modeling-mcp'.command = $exePath

# ConvertTo-Json escapa los backslashes automáticamente al serializar
$config | ConvertTo-Json -Depth 10 | Set-Content $mcpJson -Encoding UTF8

Write-Host "`n.mcp.json actualizado correctamente." -ForegroundColor Green
Write-Host "Reinicia Claude Code desde la carpeta del proyecto y ejecuta /mcp para verificar." -ForegroundColor Cyan
