# Code Quality Rules

## Project structure
```
src/
  components/   # Reusable UI components (no business logic)
  views/        # Page-level components (thin — delegate to composables)
  stores/       # Pinia stores — business/application state only
  services/     # API layer (axios/fetch wrappers — one file per resource)
  queries/      # TanStack Query hooks (useQuery / useMutation)
  composables/  # Reusable Vue logic (useGridStore, useForm, etc.)
```

## Component size
- Keep components small and focused — one responsibility per component
- If a component exceeds ~150 lines, extract logic to a composable
- No business logic inside templates

## Separation of concerns
- Queries and mutations → src/queries/ only, never inline in components
- API calls → src/services/ only, never directly in components or stores
- Pinia stores → application/business state only (auth, user, config)
- UI state (popup open, loading, selected row) → local ref in component

## Naming conventions
- Components: PascalCase — `UserGrid.vue`, `ProductForm.vue`
- Composables: camelCase with `use` prefix — `useGridStore.ts`, `useProductForm.ts`
- Stores: camelCase with `use` prefix — `useUserStore.ts`
- Queries: camelCase with `use` prefix — `useProducts.ts`, `useCreateProduct.ts`
- Services: camelCase noun — `productsApi.ts`, `authService.ts`

## No prohibited patterns
- No raw fetch/axios inside .vue components
- No `console.log` in production code (use proper logging or remove)
- No `any` type unless strictly necessary — use unknown + type guard
- No Options API in new components
- No global variables — use Pinia for shared state
