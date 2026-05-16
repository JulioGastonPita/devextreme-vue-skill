# skillsDevExtreme

Colección de skills y reglas de desarrollo para proyectos **Vue 3 + DevExtreme**.

---

## Instalación

### 1. MCP de DevExtreme (una sola vez, global)

```bash
claude mcp add --scope user --transport http dxdocs https://api.devexpress.com/mcp/docs
```

### 2. Skill `vue3-devextreme` desde GitHub

Dentro del proyecto donde querés usarlo:

```bash
claude skills add JulioGastonPita/devextreme-vue-skill --skill-path vue3-devextreme/SKILL.md
```

### 3. Actualizar a la última versión

```bash
claude skills update vue3-devextreme
```

---

## Contenido

### `vue3-devextreme/` — Skill principal

Skill de Claude Code para desarrollo integral de aplicaciones enterprise con Vue 3, DevExtreme Vue, Pinia, TanStack Query y TypeScript.

**Capacidades:**
- Scaffoldear un proyecto desde cero (Vite + JWT + DxDrawer layout)
- Generar pantallas CRUD completas (servicio + queries + composable + vista)
- Crear formularios standalone como vistas completas
- Revisar y corregir componentes contra las reglas del proyecto
- Modificar archivos existentes
- Generar dashboards con DxChart
- Generar pantallas maestro-detalle con DxTabPanel

### `rules/` — Reglas de desarrollo (referencia)

Estándares de código para proyectos Vue 3 + DevExtreme. Estas reglas están también bundleadas dentro del skill.

| Archivo | Contenido |
|---|---|
| `code-quality.md` | Estructura de carpetas, nomenclatura, separación de responsabilidades |
| `dx-components.md` | Uso de componentes DX, imports, configs base |
| `performance.md` | Optimizaciones para grillas y Vue 3 |
| `state-and-data.md` | Pinia, TanStack Query, CustomStore |

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
