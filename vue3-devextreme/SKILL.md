---
name: vue3-devextreme
description: >
  Desarrollo integral de aplicaciones enterprise con Vue 3, DevExtreme Vue, Pinia, TanStack Query
  y TypeScript. Usar cuando el usuario necesite: crear un proyecto desde cero (scaffold), generar
  pantallas CRUD completas, crear formularios standalone, crear o revisar/corregir componentes,
  modificar archivos existentes, generar dashboards con gráficos o pantallas maestro-detalle.
  Activar también para: "nueva entidad", "pantalla de X", "gestionar X", "revisar componente",
  "DxDataGrid", "DxForm", "DxPopup", "scaffoldear proyecto Vue", "grilla de X", "chart de X".
agent: claude-code
---

# vue3-devextreme

Stack: **Vue 3 · DevExtreme Vue (latest) · Pinia · TanStack Query · TypeScript · Vite · npm**

Reglas siempre activas → leer `references/rules.md` antes de generar cualquier código.
Templates de código → `references/crud-patterns.md`
Setup completo → `references/scaffold.md`

---

## Paso 0 — Identificar intención

Detectar qué quiere el usuario y saltar al flujo correspondiente:

| Palabras clave del usuario | Flujo |
|---|---|
| "proyecto nuevo", "desde cero", "inicializar", "scaffoldear" | → [Scaffold](#scaffold) |
| "CRUD", "pantalla de X", "gestionar X", "nueva entidad", "tabla X" | → [CRUD](#crud) |
| "formulario", "form de X", "vista de configuración", "página de perfil" | → [Form](#form) |
| "revisar", "corregir", "review", "¿está bien este componente?" | → [Revisión](#revision) |
| "agregar columna", "modificar", "añadir campo", "cambiar X en archivo Y" | → [Modificar](#modificar) |
| "gráfico", "chart", "dashboard", "estadísticas" | → [Chart/Dashboard](#chart) |
| "maestro-detalle", "master-detail", "tab de hijos", "detalle de X" | → [Master-Detail](#master-detail) |

Si la intención no está clara, hacer **una sola pregunta concisa** al usuario.

---

## DevExtreme MCP — uso obligatorio

Antes de generar código con cualquier componente DX, verificar su API actual:

```
mcp__dxdocs__devexpress_docs_search  query: "DxDataGrid remote operations Vue"
mcp__dxdocs__devexpress_docs_get_content  url: <url devuelta>
```

**Si `dxdocs` no está disponible**, avisar y continuar con conocimiento base:
```
⚠️ El MCP de DevExtreme no está conectado.
   Generando con conocimiento base — verificar API en js.devexpress.com si hay dudas.
```

---

## Flujo: Scaffold {#scaffold}

Leer `references/scaffold.md` y ejecutar el proceso completo.

Antes de empezar, preguntar:
1. **Nombre del proyecto** (ej: `mi-app`)
2. **URL base de la API** (ej: `http://localhost:3000/api/v1`)

El scaffold genera un proyecto Vite + Vue 3 con:
- Estructura de carpetas `src/{assets,components,composables,layouts,router,services,stores,views}`
- Tema `dx.material.blue.light.compact`, locale `es`
- Layout con `DxDrawer` + `DxToolbar`
- Auth completo: `useAuthStore` + `http.ts` con interceptores JWT + guards de router
- `LoginView.vue`, `HomeView.vue`
- `useGridStore.ts` composable base
- `.env` con `VITE_API_URL`

---

## Flujo: CRUD {#crud}

### Paso 1 — Obtener entidad

Preguntar:
> "¿Qué entidad vamos a gestionar? Dame el nombre (ej: Productos, Clientes, Pedidos)"

### Paso 2 — Inspeccionar esquema

**Si hay MCP de base de datos conectado** (PostgreSQL o SQL Server):

Ejecutar en orden:

```sql
-- 2a. Columnas
SELECT column_name, data_type, is_nullable, column_default, character_maximum_length
FROM information_schema.columns
WHERE table_name = '<tabla>'
ORDER BY ordinal_position;

-- 2b. Foreign keys
SELECT
  kcu.column_name       AS fk_column,
  ccu.table_name        AS ref_table,
  ccu.column_name       AS ref_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = '<tabla>';

-- 2c. Datos de lookup por cada FK encontrada
SELECT id, name FROM <ref_table> LIMIT 100;
-- Si la tabla referenciada no tiene columna 'name', adaptar al nombre de la columna descriptiva
```

Mapeo DB → DX (tabla completa en `references/crud-patterns.md`):

| Tipo DB | Editor DX | Notas |
|---|---|---|
| int/bigint PK | — | Columna oculta en grilla y form |
| varchar/text | dxTextBox | NOT NULL → DxRequiredRule; character_maximum_length → DxStringLengthRule |
| decimal/numeric | dxNumberBox | format: 'currency' o 'fixedPoint' |
| boolean/bit | dxCheckBox | — |
| date | dxDateBox | displayFormat: 'dd/MM/yyyy' |
| datetime/timestamp | dxDateBox | displayFormat: 'dd/MM/yyyy HH:mm' |
| int FK | dxSelectBox | Lookup con datos de paso 2c |
| columna con "email" en el nombre | dxTextBox mode:email | DxEmailRule |
| columna "activo"/"active"/"habilitado" | dxCheckBox | — |
| createdAt/updatedAt | solo lectura | Excluir del form de edición |

**Si NO hay MCP de base de datos conectado:**
```
⚠️ No detecto una conexión de base de datos activa.
   Indicame los campos de la entidad con su tipo:
   (ej: nombre: texto requerido, precio: decimal, categoriaId: FK a Categorias, activo: booleano)
```

### Paso 3 — Confirmar esquema

Mostrar tabla markdown con columnas: `campo | tipo DB | editor DX | reglas inferidas`
- Marcar PKs como `oculto`
- Marcar createdAt/updatedAt como `solo lectura`

Preguntar:
> "¿El esquema es correcto? ¿Hay campos que excluir del form o la grilla? Confirmá con 'sí' o indicá ajustes."

Esperar confirmación antes de continuar.

### Paso 4 — Generar 4 archivos

Ver plantillas completas en `references/crud-patterns.md`. Generar en este orden:

1. `src/services/<entity>Api.ts` — Interface TypeScript + CRUD usando `http.ts`
2. `src/queries/use<Entity>.ts` — `useQuery` + `useMutation` con `notify`
3. `src/composables/use<Entity>Grid.ts` — `useGridStore` + estado del popup
4. `src/views/<Entity>View.vue` — `DxDataGrid` + `DxPopup` + `DxForm`

### Paso 5 — Checklist post-generación

```
✅ Archivos generados:
   src/services/<entity>Api.ts
   src/queries/use<Entity>.ts
   src/composables/use<Entity>Grid.ts
   src/views/<Entity>View.vue

📋 Pasos pendientes:
   [ ] Agregar ruta en src/router/index.ts  (dentro del children de AppLayout)
   [ ] Agregar ítem al menú en src/components/AppMenu.vue
   [ ] Verificar VITE_API_URL en .env
   [ ] Verificar que los lookups de FK devuelvan los campos correctos
```

---

## Flujo: Form (vista completa) {#form}

Para formularios que son páginas completas (perfil de usuario, configuración del sistema, etc.).

Preguntar:
1. ¿Qué entidad/datos gestiona el form?
2. ¿Tiene secciones/grupos de campos (`DxGroupItem`)?
3. ¿Hay campos que son solo lectura?

Generar:
- `src/services/<entity>Api.ts` si no existe
- `src/queries/use<Entity>.ts` con `useQuery` para GET y `useMutation` para PUT
- `src/views/<Entity>FormView.vue`:
  - `DxLoadPanel` ligado a `isLoading`
  - `DxForm` con `label-mode="floating"` y `:col-count="2"`
  - `DxGroupItem` para agrupar secciones relacionadas
  - `DxButton` "Guardar" (type="default") y "Cancelar"
  - Todos los `editorOptions` como `const` fuera del template

---

## Flujo: Revisión de componente {#revision}

1. Leer el archivo que indica el usuario
2. Verificar cada regla de `references/rules.md`
3. Listar violaciones con formato:

```
❌ Línea 23: editorOptions definido como objeto inline en template
   Fix: mover a const fuera del <script setup>

❌ Línea 45: <table> nativo en lugar de DxDataGrid
   Fix: reemplazar con DxDataGrid

❌ Línea 67: import de DxButton desde 'devextreme-vue' (bundle completo)
   Fix: import { DxButton } from 'devextreme-vue/button'
```

4. Aplicar todos los fixes directamente en el archivo
5. Mostrar resumen de cambios (qué líneas se modificaron y por qué)

---

## Flujo: Modificar archivo existente {#modificar}

1. Leer el archivo a modificar con la herramienta Read
2. Aplicar exactamente el cambio solicitado siguiendo las reglas de `references/rules.md`
3. No modificar código no relacionado con el cambio pedido
4. Mostrar qué se cambió y por qué

---

## Flujo: Chart / Dashboard {#chart}

Verificar API de `DxChart` con el MCP antes de generar:
```
mcp__dxdocs__devexpress_docs_search  query: "DxChart series Vue configuration"
```

Preguntar al usuario:
1. ¿Qué datos muestra? (endpoint dedicado o datos del mismo grid)
2. ¿Tipo de gráfico? (bar, line, pie, area, stackedBar)
3. ¿Solo el gráfico o también tabla/grilla debajo?

Generar `DxChart` con:
- `DxSeries` (type según respuesta)
- `DxArgumentAxis` con etiquetas
- `DxValueAxis`
- `DxLegend` (position: "bottom")
- `DxTooltip` (enabled: true)

Si el dashboard tiene múltiples widgets, envolver en `DxScrollView`.
Si hay grilla + gráfico, usar layout de dos columnas con CSS Grid.

---

## Flujo: Master-Detail {#master-detail}

Verificar API de `DxTabPanel` con el MCP antes de generar:
```
mcp__dxdocs__devexpress_docs_search  query: "DxTabPanel deferred rendering Vue"
```

Preguntar:
1. Entidad padre y entidad hija
2. ¿Cómo se filtra la hija? (`/api/v1/<padre>/{id}/<hija>` o `?<padreId>={id}`)

Generar:
- Grilla padre: `DxDataGrid` con `selection-mode="single"` y `@selection-changed`
- `DxTabPanel` con `:deferred-rendering="true"` (evita renderizar tabs ocultos)
- Grilla hija dentro del tab, con `dataSource` filtrado por el ID del padre seleccionado
- `computed(() => padre seleccionado)` que reactivamente actualiza el datasource del hijo

```typescript
// Patrón de filtrado reactivo
const selectedParentId = ref<number | null>(null)

function onParentSelectionChanged(e: SelectionChangedEvent) {
  selectedParentId.value = e.selectedRowsData[0]?.id ?? null
}

const childDataSource = computed(() =>
  selectedParentId.value
    ? new DataSource({ store: childStore, filter: ['parentId', '=', selectedParentId.value] })
    : null
)
```
