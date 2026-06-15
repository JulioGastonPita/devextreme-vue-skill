# devextreme-vue-skill

Plugin de Claude Code para desarrollo enterprise con **Vue 3 + DevExtreme**.

---

## Instalación

### Opción A — Script automático (recomendado)

Ejecutar en PowerShell desde cualquier directorio:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JulioGastonPita/devextreme-vue-skill/master/install.ps1" -OutFile "install.ps1"; .\install.ps1; Remove-Item install.ps1
```

Instala el MCP de DevExtreme (scope global) y el plugin `vue3-devextreme`. Si ya están instalados, actualiza el plugin a la última versión.

### Opción B — Manual

**1. MCP de DevExtreme (por proyecto — se guarda en `.mcp.json`)**

```bash
claude mcp add --scope project --transport http dxdocs https://api.devexpress.com/mcp/docs
```

**2. Registrar el marketplace y instalar el plugin**

```bash
claude plugin marketplace add JulioGastonPita/devextreme-vue-skill
claude plugin install vue3-devextreme
```

**3. Actualizar a la última versión**

```bash
claude plugin update vue3-devextreme
```

---

## Qué incluye

### Plugin `vue3-devextreme`

Skill de Claude Code para generación de código enterprise Vue 3 + DevExtreme.

**Flujos disponibles:**

| Comando / intención | Qué genera |
|---|---|
| "proyecto nuevo", "scaffoldear" | Proyecto Vite completo con auth JWT, DxDrawer layout, router, stores |
| "CRUD de X", "pantalla de X" | Servicio + queries TanStack + composable + vista con DxDataGrid + DxPopup + DxForm |
| "formulario de X" | Vista de formulario standalone con DxForm + DxLoadPanel |
| "revisar componente" | Auditoría contra las reglas del proyecto + fixes automáticos |
| "dashboard", "gráfico de X" | DxChart con series, ejes, leyenda y tooltip |
| "maestro-detalle" | DxDataGrid padre + DxTabPanel + grilla hija con filtrado reactivo |

### `rules/` — Estándares de referencia

| Archivo | Contenido |
|---|---|
| `code-quality.md` | Estructura de carpetas, nomenclatura, separación de responsabilidades |
| `dx-components.md` | Imports individuales DX, configs base obligatorias |
| `performance.md` | Optimizaciones para grillas, lazy loading, Vue 3 |
| `state-and-data.md` | Pinia, TanStack Query, CustomStore patterns |

---

## Estructura del repo

```
.claude-plugin/
  marketplace.json              # Registro del marketplace
plugins/
  vue3-devextreme/
    .claude-plugin/
      plugin.json               # Manifest del plugin
    skills/
      vue3-devextreme/
        SKILL.md                # Instrucciones del skill
        references/
          rules.md              # Reglas no negociables
          crud-patterns.md      # Templates CRUD completos
          scaffold.md           # Setup completo desde cero
rules/                          # Estándares de referencia (lectura humana)
install.ps1                     # Script de instalación automática
```

---

## Stack objetivo

| Tecnología | Rol |
|---|---|
| Vue 3 + Vite | Framework y bundler |
| DevExtreme Vue (latest) | Componentes UI enterprise |
| Pinia | Estado de aplicación |
| TanStack Query | Estado del servidor (cache, mutaciones) |
| TypeScript | Tipado estático |
| Axios | Cliente HTTP |
| Vue Router | Navegación con guards JWT |
