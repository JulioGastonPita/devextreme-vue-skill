# Plantillas CRUD — Vue 3 + DevExtreme

En todos los templates, reemplazar:
- `<Entity>` / `<entity>` / `<entities>` → nombre de la entidad en el caso correcto
- `<Field>` → campos según el esquema confirmado

---

## Tabla de mapeo DB → DX (completa)

| Tipo DB | ¿Nullable? | Editor DX | Reglas DX | Notas |
|---|---|---|---|---|
| `int` / `bigint` PK | — | Oculto | — | `<DxColumn :visible="false" />` en grid, excluir del form |
| `varchar(n)` / `nvarchar(n)` | NOT NULL | dxTextBox | DxRequiredRule + DxStringLengthRule(max=n) | |
| `varchar(n)` / `nvarchar(n)` | NULL | dxTextBox | DxStringLengthRule(max=n) | |
| `text` / `ntext` | NOT NULL | dxTextArea | DxRequiredRule | |
| `decimal(p,s)` / `numeric(p,s)` | NOT NULL | dxNumberBox | DxRequiredRule | format: 'fixedPoint' o 'currency' según contexto |
| `float` / `real` | NOT NULL | dxNumberBox | DxRequiredRule | |
| `bit` / `boolean` | — | dxCheckBox | — | |
| `date` | NOT NULL | dxDateBox | DxRequiredRule | displayFormat: 'dd/MM/yyyy' |
| `datetime` / `datetime2` / `timestamp` | NOT NULL | dxDateBox | DxRequiredRule | displayFormat: 'dd/MM/yyyy HH:mm' |
| `int` FK | NOT NULL | dxSelectBox | DxRequiredRule | Lookup con datos del paso 2c |
| `int` FK | NULL | dxSelectBox | — | Lookup, puede quedar vacío |
| columna con "email" en nombre | NOT NULL | dxTextBox mode:email | DxRequiredRule + DxEmailRule | |
| columna "activo" / "active" / "habilitado" / "enabled" | — | dxCheckBox | — | |
| `createdAt` / `updatedAt` / `fechaCreacion` | — | dxDateBox | — | Solo lectura — excluir del form de edición |
| `uniqueidentifier` / `uuid` | — | dxTextBox | — | Generado en servidor — excluir del form si es PK |

---

## Archivo 1: `src/services/<entity>Api.ts`

```typescript
import http from './http'
import type { LoadOptions } from 'devextreme/data/load_options'

// ── Tipos ────────────────────────────────────────────────────────────────────

export interface <Entity> {
  id: number
  // Campos según el esquema — ejemplo:
  // name: string
  // price: number
  // categoryId: number
  // active: boolean
  // createdAt: string
}

type ApiList = { data: <Entity>[]; totalCount: number }

// ── API object ────────────────────────────────────────────────────────────────

export const <entity>Api = {
  // El backend debe aceptar los parámetros de DevExtreme (skip, take, filter, sort)
  // y devolver { data: T[], totalCount: number }
  getAll: (opts: LoadOptions): Promise<ApiList> =>
    http.get('/<entities>', { params: opts }).then(r => r.data),

  getById: (id: number): Promise<<Entity>> =>
    http.get(`/<entities>/${id}`).then(r => r.data),

  create: (payload: Omit<<Entity>, 'id' | 'createdAt' | 'updatedAt'>): Promise<<Entity>> =>
    http.post('/<entities>', payload).then(r => r.data),

  update: (id: number, payload: Partial<Omit<<Entity>, 'id' | 'createdAt' | 'updatedAt'>>): Promise<<Entity>> =>
    http.put(`/<entities>/${id}`, payload).then(r => r.data),

  delete: (id: number): Promise<void> =>
    http.delete(`/<entities>/${id}`).then(() => undefined),
}
```

> Ajustar el tipo de `id` a `string` si el backend usa UUIDs.
> Ajustar la URL según la convención del proyecto (`/<entities>` debe coincidir con el endpoint real).

---

## Archivo 2: `src/queries/use<Entity>.ts`

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { <entity>Api, type <Entity> }            from '@/services/<entity>Api'
import notify                                     from 'devextreme/ui/notify'

const KEY = ['<entities>'] as const

// ── Queries ───────────────────────────────────────────────────────────────────

export function use<Entity>List() {
  return useQuery({
    queryKey: KEY,
    queryFn:  () => <entity>Api.getAll({}),
  })
}

// ── Mutations ─────────────────────────────────────────────────────────────────

export function useCreate<Entity>() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (payload: Parameters<typeof <entity>Api.create>[0]) =>
      <entity>Api.create(payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: KEY })
      notify('<Entity> creado correctamente', 'success', 2000)
    },
    onError: () => notify('Error al crear <entity>', 'error', 3000),
  })
}

export function useUpdate<Entity>() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<<Entity>> }) =>
      <entity>Api.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: KEY })
      notify('<Entity> actualizado correctamente', 'success', 2000)
    },
    onError: () => notify('Error al actualizar <entity>', 'error', 3000),
  })
}

export function useDelete<Entity>() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: number) => <entity>Api.delete(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: KEY })
      notify('<Entity> eliminado', 'success', 2000)
    },
    onError: () => notify('Error al eliminar <entity>', 'error', 3000),
  })
}
```

---

## Archivo 3: `src/composables/use<Entity>Grid.ts`

```typescript
import { ref, reactive }                          from 'vue'
import { useGridStore }                           from './useGridStore'
import { <entity>Api, type <Entity> }            from '@/services/<entity>Api'
import { useCreate<Entity>, useUpdate<Entity> }  from '@/queries/use<Entity>'

export function use<Entity>Grid() {
  // DataSource para DxDataGrid (CustomStore con remote operations)
  const { dataSource } = useGridStore(<entity>Api)

  // Mutations
  const { mutate: create, isPending: isCreating } = useCreate<Entity>()
  const { mutate: update, isPending: isUpdating } = useUpdate<Entity>()

  // Estado del popup de edición/creación
  const popupVisible = ref(false)
  const isEditMode   = ref(false)
  const formData     = reactive<Partial<<Entity>>>({})

  const isSaving = computed(() => isCreating.value || isUpdating.value)

  function openAdd() {
    // Limpiar formData completamente
    Object.keys(formData).forEach(k => delete (formData as Record<string, unknown>)[k])
    isEditMode.value   = false
    popupVisible.value = true
  }

  function openEdit(row: <Entity>) {
    // Copiar datos de la fila al form (spread para no mutar la fila)
    Object.assign(formData, { ...row })
    isEditMode.value   = true
    popupVisible.value = true
  }

  function handleSave() {
    if (isEditMode.value) {
      update(
        { id: formData.id as number, data: formData },
        { onSuccess: () => { popupVisible.value = false } },
      )
    } else {
      create(
        formData as Parameters<typeof <entity>Api.create>[0],
        { onSuccess: () => { popupVisible.value = false } },
      )
    }
  }

  return {
    dataSource,
    formData,
    popupVisible,
    isEditMode,
    isSaving,
    openAdd,
    openEdit,
    handleSave,
  }
}
```

> Agregar `import { computed } from 'vue'` si no está en el bloque de imports.

---

## Archivo 4: `src/views/<Entity>View.vue`

Este template es el más variable. Adaptar columnas y campos según el esquema confirmado.

```vue
<script setup lang="ts">
import { computed }    from 'vue'
import {
  DxDataGrid, DxColumn, DxEditing, DxPaging, DxPager,
  DxFilterRow, DxHeaderFilter, DxSearchPanel, DxExport,
} from 'devextreme-vue/data-grid'
import { DxForm, DxSimpleItem, DxGroupItem,
         DxRequiredRule, DxStringLengthRule } from 'devextreme-vue/form'
import { DxPopup }     from 'devextreme-vue/popup'
import { DxButton }    from 'devextreme-vue/button'
import { DxToolbar, DxItem } from 'devextreme-vue/toolbar'
import { DxLoadPanel } from 'devextreme-vue/load-panel'
import { use<Entity>Grid } from '@/composables/use<Entity>Grid'
import { useDelete<Entity> } from '@/queries/use<Entity>'
import type { RowRemovedEvent } from 'devextreme/ui/data_grid'

const {
  dataSource, formData, popupVisible,
  isEditMode, isSaving, openAdd, openEdit, handleSave,
} = use<Entity>Grid()

const { mutate: deleteEntity } = useDelete<Entity>()

// ── editorOptions como const fuera del template (nunca inline) ────────────────
// Ejemplo de FK lookup:
// const categoryOptions = { dataSource: categories, valueExpr: 'id', displayExpr: 'name' }

// ── Handlers de grilla ────────────────────────────────────────────────────────
function onRowRemoved(e: RowRemovedEvent) {
  deleteEntity(e.data.id)
}
</script>

<template>
  <!-- Loading global mientras la grilla carga -->
  <DxLoadPanel :visible="false" message="Cargando..." />

  <!-- Toolbar de página -->
  <DxToolbar class="page-toolbar">
    <DxItem location="before" text="<Entidades>" css-class="page-title" />
    <DxItem location="after">
      <template #default>
        <DxButton
          text="Nuevo"
          type="default"
          icon="plus"
          @click="openAdd"
        />
      </template>
    </DxItem>
  </DxToolbar>

  <!-- Grilla principal -->
  <DxDataGrid
    :data-source="dataSource"
    :show-borders="true"
    :column-auto-width="true"
    :remote-operations="true"
    :repaint-changes-only="true"
    :row-alternation-enabled="true"
    key-expr="id"
    @row-dbl-click="e => openEdit(e.data)"
    @row-removed="onRowRemoved"
  >
    <DxEditing
      mode="row"
      :allow-adding="false"
      :allow-updating="false"
      :allow-deleting="true"
    />
    <DxFilterRow :visible="true" />
    <DxHeaderFilter :visible="true" />
    <DxSearchPanel :visible="true" />
    <DxPaging :page-size="15" />
    <DxPager :show-page-size-selector="true" :allowed-page-sizes="[10, 15, 30]" />
    <DxExport :enabled="true" />

    <!-- Columna PK oculta -->
    <DxColumn data-field="id" :visible="false" />

    <!-- ── Columnas según esquema ───────────────────────────────────────── -->
    <!-- Ejemplo de columnas comunes: -->
    <!-- <DxColumn data-field="name"       caption="Nombre"      data-type="string" /> -->
    <!-- <DxColumn data-field="price"      caption="Precio"      data-type="number" format="currency" /> -->
    <!-- <DxColumn data-field="active"     caption="Activo"      data-type="boolean" /> -->
    <!-- <DxColumn data-field="createdAt"  caption="Creado"      data-type="datetime" format="dd/MM/yyyy HH:mm" /> -->
    <!-- FK con lookup: -->
    <!--
    <DxColumn data-field="categoryId" caption="Categoría">
      <DxLookup :data-source="categories" value-expr="id" display-expr="name" />
    </DxColumn>
    -->
  </DxDataGrid>

  <!-- Popup de alta/edición -->
  <DxPopup
    v-model:visible="popupVisible"
    :drag-enabled="true"
    :show-close-button="true"
    :width="680"
    height="auto"
    :max-height="'90vh'"
  >
    <template #title>
      {{ isEditMode ? 'Editar <Entidad>' : 'Nueva <Entidad>' }}
    </template>
    <template #content>
      <DxForm
        :form-data="formData"
        label-mode="floating"
        :col-count="2"
      >
        <!-- ── Campos según esquema ──────────────────────────────────────── -->
        <!-- Ejemplo de campos comunes: -->
        <!--
        <DxSimpleItem data-field="name" caption="Nombre">
          <DxRequiredRule message="El nombre es requerido" />
          <DxStringLengthRule :max="200" message="Máximo 200 caracteres" />
        </DxSimpleItem>

        <DxSimpleItem data-field="price" caption="Precio" editor-type="dxNumberBox">
          <DxRequiredRule message="El precio es requerido" />
        </DxSimpleItem>

        <DxSimpleItem data-field="active" caption="Activo" editor-type="dxCheckBox" />

        FK con selectBox:
        <DxSimpleItem
          data-field="categoryId"
          caption="Categoría"
          editor-type="dxSelectBox"
          :editor-options="categoryOptions"
        >
          <DxRequiredRule message="La categoría es requerida" />
        </DxSimpleItem>

        Campos de solo lectura (createdAt):
        <DxSimpleItem
          data-field="createdAt"
          caption="Creado"
          editor-type="dxDateBox"
          :is-required="false"
          :disabled="true"
          :col-span="2"
          v-if="isEditMode"
        />
        -->
      </DxForm>

      <!-- Botones de acción -->
      <div class="popup-actions">
        <DxButton
          text="Cancelar"
          styling-mode="outlined"
          @click="popupVisible = false"
        />
        <DxButton
          text="Guardar"
          type="default"
          :disabled="isSaving"
          @click="handleSave"
        />
      </div>
    </template>
  </DxPopup>
</template>

<style scoped>
.page-toolbar {
  margin-bottom: 1rem;
}
:deep(.page-title .dx-toolbar-item-content) {
  font-size: 1.2rem;
  font-weight: 600;
}
.popup-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--dx-color-border);
}
</style>
```

---

## Agregar la ruta al router

```typescript
// Dentro del array children de AppLayout en src/router/index.ts
{
  path: '<entities>',
  name: '<entities>',
  component: () => import('@/views/<Entity>View.vue'),
},
```

---

## Agregar al menú

```typescript
// En src/components/AppMenu.vue — array menuItems
{ text: '<Entidades>', icon: 'folder', route: '/<entities>' },
```
