# Reglas del proyecto — Vue 3 + DevExtreme

Estas reglas son **no negociables**. Aplicar en todos los flujos del skill.

---

## Estructura de carpetas

```
src/
  assets/           # Imágenes, fuentes, estilos globales
  components/       # Componentes reutilizables sin lógica de negocio
  composables/      # Lógica Vue reutilizable (useGridStore, useEntityGrid, etc.)
  layouts/          # Layouts de página (AppLayout.vue)
  router/           # Vue Router (index.ts)
  services/         # Capa API: axios wrappers, un archivo por recurso
  stores/           # Pinia stores: solo estado de negocio/aplicación
  queries/          # TanStack Query hooks (useQuery / useMutation)
  views/            # Componentes de página (thin — delegan a composables)
```

---

## Separación de responsabilidades

| Capa | Responsabilidad |
|---|---|
| `views/` | Orquestar — sin lógica de negocio, sin llamadas API directas |
| `composables/` | Lógica Vue reutilizable, estado de UI complejo |
| `queries/` | TODO lo relacionado con servidor: useQuery, useMutation |
| `services/` | TODAS las llamadas HTTP — nunca directamente en componentes |
| `stores/` | Estado de negocio/aplicación (auth, user, config global) |
| `components/` | UI pura reutilizable — sin llamadas API |

**Prohibido:**
- `fetch` o `axios` dentro de archivos `.vue`
- `console.log` en código de producción
- Variables globales — usar Pinia
- Options API en componentes nuevos
- Tipo `any` — usar `unknown` + type guard si es necesario

---

## Nomenclatura

| Artefacto | Convención | Ejemplo |
|---|---|---|
| Componentes `.vue` | PascalCase | `UserGrid.vue`, `ProductForm.vue` |
| Composables | camelCase con `use` | `useGridStore.ts`, `useProductForm.ts` |
| Pinia stores | camelCase con `use` | `useAuthStore.ts`, `useUserStore.ts` |
| Queries TanStack | camelCase con `use` | `useProducts.ts`, `useCreateProduct.ts` |
| Services | camelCase sustantivo | `productsApi.ts`, `authService.ts` |
| Vistas | PascalCase + `View` | `ProductsView.vue`, `LoginView.vue` |

---

## Componentes Vue — siempre script setup

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
const props = defineProps<{ id: number }>()
const emit  = defineEmits<{ saved: [id: number] }>()
</script>
```

Nunca usar Options API en código nuevo.
Si un componente supera ~150 líneas, extraer lógica a un composable.

---

## Pinia — solo estado de negocio

```typescript
// src/stores/useExampleStore.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useExampleStore = defineStore('example', () => {
  const items = ref<Item[]>([])
  const count = computed(() => items.value.length)
  function setItems(data: Item[]) { items.value = data }
  return { items, count, setItems }
})
```

- Estado de UI (popup abierto, loading, fila seleccionada) → `ref` local en el componente
- Estado de negocio/aplicación → Pinia store

---

## TanStack Query — estado del servidor

```typescript
// src/queries/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { productsApi } from '@/services/productsApi'
import notify from 'devextreme/ui/notify'

export function useProducts() {
  return useQuery({ queryKey: ['products'], queryFn: productsApi.getAll })
}

export function useCreateProduct() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: productsApi.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['products'] })
      notify('Creado correctamente', 'success', 2000)
    },
    onError: () => notify('Error al crear', 'error', 3000),
  })
}
```

- GET → `useQuery`
- POST / PUT / DELETE → `useMutation`
- Nunca llamadas manuales a axios dentro de componentes

---

## DevExtreme — imports individuales (tree-shaking)

```typescript
import { DxDataGrid, DxColumn, DxEditing, DxPaging, DxPager,
         DxFilterRow, DxHeaderFilter, DxSearchPanel, DxExport,
         DxSummary, DxTotalItem, DxLookup } from 'devextreme-vue/data-grid'
import { DxForm, DxSimpleItem, DxGroupItem,
         DxRequiredRule, DxEmailRule, DxStringLengthRule } from 'devextreme-vue/form'
import { DxButton }    from 'devextreme-vue/button'
import { DxSelectBox } from 'devextreme-vue/select-box'
import { DxDateBox }   from 'devextreme-vue/date-box'
import { DxNumberBox } from 'devextreme-vue/number-box'
import { DxCheckBox }  from 'devextreme-vue/check-box'
import { DxTextBox }   from 'devextreme-vue/text-box'
import { DxPopup }     from 'devextreme-vue/popup'
import { DxLoadPanel } from 'devextreme-vue/load-panel'
import { DxToolbar, DxItem } from 'devextreme-vue/toolbar'
import { DxDrawer }    from 'devextreme-vue/drawer'
import { DxChart, DxSeries, DxCommonSeriesSettings,
         DxArgumentAxis, DxValueAxis, DxLegend,
         DxTooltip }   from 'devextreme-vue/chart'
import { DxTabPanel, DxItem as DxTabItem } from 'devextreme-vue/tab-panel'
import { DxList }      from 'devextreme-vue/list'
```

**Nunca** importar desde `'devextreme-vue'` (bundle completo).

---

## HTML nativo prohibido — equivalentes DX obligatorios

| HTML nativo | Usar en su lugar |
|---|---|
| `<table>` | `DxDataGrid` |
| `<form>` / `<input>` | `DxForm` / `DxSimpleItem` |
| `<select>` | `DxSelectBox` |
| `<button>` | `DxButton` |
| `<dialog>` / `alert()` / `confirm()` | `DxPopup` |
| Toast manual | `notify()` de `devextreme/ui/notify` |

---

## Notificaciones — notify(), nunca DxToast

```typescript
import notify from 'devextreme/ui/notify'
notify('Guardado', 'success', 2000)
notify('Error al procesar', 'error', 3000)
notify('Atención: revisar datos', 'warning', 2500)
```

---

## DxDataGrid — config base obligatoria

```vue
<DxDataGrid
  :data-source="dataSource"
  :show-borders="true"
  :column-auto-width="true"
  :remote-operations="true"
  :repaint-changes-only="true"
  :row-alternation-enabled="true"
  key-expr="id"
>
  <DxEditing mode="popup" :allow-adding="false" :allow-updating="false" :allow-deleting="true" />
  <DxFilterRow :visible="true" />
  <DxHeaderFilter :visible="true" />
  <DxSearchPanel :visible="true" />
  <DxPaging :page-size="15" />
  <DxPager :show-page-size-selector="true" :allowed-page-sizes="[10, 15, 30]" />
  <DxExport :enabled="true" />
</DxDataGrid>
```

- **SIEMPRE** `:remote-operations="true"` cuando los datos vienen del servidor
- **SIEMPRE** `:repaint-changes-only="true"` en datasets grandes
- **NUNCA** pasar un array reactivo como `data-source` — usar `DataSource`/`CustomStore`
- Para listas con 500+ filas: `<DxScrolling mode="virtual" />`

---

## DxForm — config base obligatoria

```vue
<DxForm :form-data="formData" label-mode="floating" :col-count="2">
  <DxSimpleItem data-field="nombre">
    <DxRequiredRule />
  </DxSimpleItem>
</DxForm>
```

- Usar `DxSimpleItem` (nunca `DxItem`) para campos de formulario
- Usar `DxGroupItem` para agrupar campos relacionados
- `editorOptions` SIEMPRE como `const` fuera del template — nunca inline

```typescript
// CORRECTO — fuera del template
const emailOptions = { mode: 'email', placeholder: 'usuario@dominio.com' }
const passwordOptions = { mode: 'password' }

// INCORRECTO — causa re-renders cada tick
// :editor-options="{ mode: 'email' }"
```

---

## DxPopup — diálogos

```vue
<DxPopup v-model:visible="popupVisible" :drag-enabled="true" :show-close-button="true">
  <template #title>Título del popup</template>
  <template #content>
    <!-- DxForm aquí -->
  </template>
</DxPopup>
```

- Usar `v-model:visible` — nunca `:visible + @update:visible`
- Nunca `alert()` o `confirm()` del browser

---

## DevExtreme — tipos TypeScript en eventos

```typescript
import type { RowInsertedEvent, RowUpdatedEvent, RowRemovedEvent,
              SelectionChangedEvent } from 'devextreme/ui/data_grid'
import type { FieldDataChangedEvent } from 'devextreme/ui/form'
import type { ValueChangedEvent }     from 'devextreme/ui/select_box'

// Ref a instancia del grid
import type { DxDataGrid } from 'devextreme-vue/data-grid'
const gridRef = ref<InstanceType<typeof DxDataGrid> | null>(null)
const gridInstance = () => gridRef.value?.instance
```

Nunca usar `any` en handlers de eventos DX.

---

## Fuente de datos para DxDataGrid

```typescript
import CustomStore from 'devextreme/data/custom_store'
import DataSource  from 'devextreme/data/data_source'

// REST → CustomStore (patrón preferido)
const store = new CustomStore({
  key: 'id',
  load:   opts        => api.getAll(opts),   // debe retornar { data, totalCount }
  insert: values      => api.create(values),
  update: (key, vals) => api.update(key, vals),
  remove: key         => api.delete(key),
})
const dataSource = new DataSource({ store, pageSize: 20 })

// OData → ODataStore
import ODataStore from 'devextreme/data/odata/store'
const odataStore = new ODataStore({
  url: `${import.meta.env.VITE_API_URL}/odata/Entidad`,
  key: 'id', version: 4,
  beforeSend: req => { req.headers['Authorization'] = `Bearer ${localStorage.getItem('token')}` }
})
```

---

## Theming

- Importar CSS del tema **una sola vez** en `main.ts` — nunca dentro de componentes
- Usar `:deep()` para overrides scoped de DX — **nunca** `!important`
- No introducir Tailwind, Bootstrap ni Material UI sin solicitud explícita

```typescript
// main.ts
import 'devextreme/dist/css/dx.material.blue.light.compact.css'
```

```vue
<style scoped>
:deep(.dx-datagrid-header-panel) { background-color: var(--dx-color-main); }
</style>
```

---

## i18n — configurado en main.ts

```typescript
import { locale, loadMessages } from 'devextreme/localization'
import esMessages from 'devextreme/localization/messages/es.json'
loadMessages(esMessages)
locale('es')
```

No re-importar ni re-configurar el locale dentro de componentes.

---

## DxTabPanel — performance

```vue
<DxTabPanel :deferred-rendering="true">
  <DxTabItem title="General">
    <!-- contenido pesado no se renderiza hasta abrir el tab -->
  </DxTabItem>
</DxTabPanel>
```

Usar siempre `:deferred-rendering="true"` en tabs con contenido pesado.
