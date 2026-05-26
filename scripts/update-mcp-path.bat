@echo off
REM Lanzador de un click para update-mcp-path.ps1
REM Ejecutalo tras cada actualizacion de VS Code que cambie la version de la extension.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-mcp-path.ps1"
pause
