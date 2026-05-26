# Opción A — Endpoint remoto oficial de Microsoft (Fabric / Power BI MCP)

> **Estado: BLOQUEADO** hasta que un admin del tenant active la preview.

## Requisito previo

Un admin de Power BI debe activar la tenant setting:

> **"Users can use the Power BI Model Context Protocol server endpoint (preview)"**

Sin esto, el endpoint responde con error de permisos da igual qué cliente uses.
Es un toggle de un click para el admin — el bloqueo suele ser política, no técnica.

## Qué da

Acceso a modelos **publicados** en el Power BI Service, sin necesidad de tener
Power BI Desktop abierto.

## Setup (cuando se desbloquee)

1. Añadir a `.mcp.json` un server HTTP apuntando a:
   `https://api.fabric.microsoft.com/v1/mcp/powerbi`
2. Resolver autenticación Entra ID (OAuth / device-code).

```jsonc
{
  "mcpServers": {
    "powerbi-remote": {
      "type": "http",
      "url": "https://api.fabric.microsoft.com/v1/mcp/powerbi"
      // + config de auth Entra ID
    }
  }
}
```

## Email tipo para el admin

> Asunto: Activar preview MCP de Power BI
>
> Hola, para un proyecto de análisis con Claude Code necesito que actives la tenant
> setting "Users can use the Power BI Model Context Protocol server endpoint (preview)"
> en el admin portal de Power BI. Es un toggle de la sección de preview features.
> Gracias.
