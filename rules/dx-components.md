# DX Components Rules

## Never use native HTML when a DX equivalent exists
- `<table>`              → DxDataGrid
- `<form>` / `<input>`  → DxForm / DxSimpleItem
- `<select>`            → DxSelectBox
- `<button>`            → DxButton
- `<dialog>` / alert()  → DxPopup
- toast manual          → notify() from 'devextreme/ui/notify'

## Imports — always individual (tree-shaking)
```ts
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
import { DxToolbar }   from 'devextreme-vue/toolbar'
import { DxChart, DxSeries, DxCommonSeriesSettings,
         DxArgumentAxis, DxValueAxis, DxLegend,
         DxTooltip }   from 'devextreme-vue/chart'
```

## Notifications — notify(), never DxToast
```ts
import notify from 'devextreme/ui/notify'
notify('Guardado', 'success', 2000)
notify('Error', 'error', 3000)
```

## DxDataGrid — required baseline config
```vue
<DxDataGrid
  :data-source="dataSource"
  :show-borders="true"
  :column-auto-width="true"
  :remote-operations="true"
  :repaint-changes-only="true"
  key-expr="id"
>
  <DxEditing mode="popup" :allow-adding="true" :allow-updating="true" :allow-deleting="true" />
  <DxFilterRow :visible="true" />
  <DxHeaderFilter :visible="true" />
  <DxSearchPanel :visible="true" />
  <DxPaging :page-size="15" />
  <DxPager :show-page-size-selector="true" :allowed-page-sizes="[10, 15, 30]" />
</DxDataGrid>
```

## DxForm — required baseline config
```vue
<DxForm :form-data="formData" label-mode="floating" :col-count="2">
  <DxSimpleItem data-field="name">
    <DxRequiredRule />
  </DxSimpleItem>
</DxForm>
```
- Use DxSimpleItem (not DxItem) for form fields
- Use DxGroupItem to group related fields
- Define editorOptions as const outside template — never inline objects

## DxPopup — dialogs
```vue
<DxPopup v-model:visible="visible" :drag-enabled="true" :show-close-button="true">
  <template #content> <!-- DxForm here --> </template>
</DxPopup>
```
- Use v-model:visible — never :visible + @update:visible
- Never use alert() or browser confirm()

## DxLoadPanel
```vue
<DxLoadPanel :visible="isLoading" message="Cargando..." />
```
- Bind to isLoading from TanStack Query or local ref
- Always show during async operations

## Theming
- Import theme CSS once in main.ts — never inside components
- Use :deep() for all scoped DX overrides
- Never use !important
- Do NOT introduce Tailwind, Bootstrap, or Material UI unless explicitly requested
```ts
// main.ts — pick one theme
import 'devextreme/dist/css/dx.fluent.blue.light.css'
```
```vue
<style scoped>
:deep(.dx-datagrid-header-panel) { background-color: var(--brand-primary); }
</style>
```

## i18n — always configure in main.ts
```ts
import { locale, loadMessages } from 'devextreme/localization'
import esMessages from 'devextreme/localization/messages/es.json'
loadMessages(esMessages)
locale('es')
```
