# Performance Rules

## DxDataGrid
- ALWAYS set :remote-operations="true" when data comes from a server
- ALWAYS set :repaint-changes-only="true" on large datasets
- NEVER pass a raw reactive array as data-source — use DataSource / CustomStore
- Enable virtual scrolling for lists with 500+ rows:
  `<DxScrolling mode="virtual" />`

## Vue 3
- NEVER define editorOptions as inline objects in template — causes re-renders every tick
```ts
// WRONG
:editor-options="{ dataSource: roles, valueExpr: 'id' }"

// CORRECT — define outside template
const roleOptions = { dataSource: roles, valueExpr: 'id', displayExpr: 'name' }
```
- Prefer computed over watch whenever possible
- Avoid unnecessary watchers — use watchEffect only for side effects
- Use v-model:visible on DxPopup and DxDrawer (not :visible + @update:visible)

## DxDataGrid column best practices
- Set :column-auto-width="true" unless fixed widths are required
- Set :row-alternation-enabled="true" for readability on large grids
- Hide key columns: `<DxColumn data-field="id" :visible="false" />`
- Always specify data-type on date and number columns to avoid sorting issues

## Lazy loading
- Use :deferred-rendering="true" on DxTabPanel to avoid rendering hidden tabs
- Wrap heavy views in Vue's `<Suspense>` + defineAsyncComponent when appropriate
