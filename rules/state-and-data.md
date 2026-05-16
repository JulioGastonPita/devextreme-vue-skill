# State & Data Rules

## Vue component pattern — always script setup
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
const props = defineProps<{ id: number }>()
const emit  = defineEmits<{ saved: [id: number] }>()
</script>
```
- NEVER use Options API unless explicitly required by legacy code

## Pinia — business state only
- Business/application state → Pinia store
- UI state (open/close, loading, form data) → component local ref
- Never use global variables
```ts
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

## TanStack Query — server state
- GET  → useQuery
- POST / PUT / DELETE → useMutation
- NEVER write manual fetch/axios inside components
- All queries live in src/queries/, never inline in components
```ts
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
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['products'] }); notify('Creado', 'success', 2000) },
    onError:   () => notify('Error al crear', 'error', 3000)
  })
}
```

## DevExtreme data sources
- REST backend   → CustomStore (preferred)
- OData endpoint → ODataStore
- Local/static   → ArrayStore
- NEVER pass a raw reactive array as data-source to DxDataGrid

### CustomStore pattern
```ts
import CustomStore from 'devextreme/data/custom_store'
import DataSource  from 'devextreme/data/data_source'

const store = new CustomStore({
  key: 'id',
  load:   (opts)        => api.getAll(opts),  // must return { data, totalCount }
  insert: (values)      => api.create(values),
  update: (key, values) => api.update(key, values),
  remove: (key)         => api.delete(key)
})
const dataSource = new DataSource({ store, pageSize: 20 })
```

### ODataStore pattern
```ts
import ODataStore from 'devextreme/data/odata/store'
const store = new ODataStore({
  url: 'https://api.example.com/odata/Entity',
  key: 'id', version: 4,
  beforeSend(req) { req.headers['Authorization'] = `Bearer ${token}` }
})
```

## Composable useGridStore — reuse for every CRUD grid
```ts
// src/composables/useGridStore.ts
import CustomStore from 'devextreme/data/custom_store'
import DataSource  from 'devextreme/data/data_source'

export function useGridStore<T extends { id: number | string }>(api: {
  getAll: (opts: unknown) => Promise<{ data: T[]; totalCount: number }>
  create: (v: Partial<T>) => Promise<T>
  update: (id: T['id'], v: Partial<T>) => Promise<T>
  delete: (id: T['id']) => Promise<void>
}) {
  const store = new CustomStore({
    key: 'id',
    load:   opts    => api.getAll(opts),
    insert: v       => api.create(v),
    update: (k, v)  => api.update(k, v),
    remove: k       => api.delete(k)
  })
  return { dataSource: new DataSource({ store, pageSize: 20 }) }
}
```

## TypeScript event types — always use, never use any
```ts
import type { RowInsertedEvent, RowUpdatedEvent, RowRemovedEvent } from 'devextreme/ui/data_grid'
import type { FieldDataChangedEvent } from 'devextreme/ui/form'
import type { ValueChangedEvent }     from 'devextreme/ui/select_box'

// Instance ref
import type { DxDataGrid } from 'devextreme-vue/data-grid'
const gridRef = ref<InstanceType<typeof DxDataGrid> | null>(null)
const gridInstance = () => gridRef.value?.instance
```
