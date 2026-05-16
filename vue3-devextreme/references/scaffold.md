# Scaffold — Proyecto Vue 3 + DevExtreme desde cero

Variables a reemplazar antes de ejecutar:
- `<project-name>` → nombre del proyecto (ej: `mi-app`)
- `<api-url>` → URL base de la API (ej: `http://localhost:3000/api/v1`)

---

## Paso 1 — Crear el proyecto con Vite

```bash
npm create vue@latest <project-name>
```

Seleccionar estas opciones en el wizard:
```
✔ Add TypeScript?                → Yes
✔ Add JSX Support?               → No
✔ Add Vue Router?                → Yes
✔ Add Pinia?                     → Yes
✔ Add Vitest?                    → Yes
✔ Add an End-to-End Testing?     → No
✔ Add ESLint?                    → Yes
✔ Add Prettier?                  → Yes
✔ Add Vue DevTools?              → Yes
```

```bash
cd <project-name>
```

---

## Paso 2 — Instalar dependencias

```bash
npm install devextreme devextreme-vue
npm install @tanstack/vue-query
npm install axios
```

---

## Paso 3 — Crear estructura de carpetas

```bash
mkdir -p src/composables src/layouts src/services src/queries
```

La estructura final de `src/`:
```
src/
  assets/
  components/
    AppMenu.vue
  composables/
    useGridStore.ts
  layouts/
    AppLayout.vue
  router/
    index.ts          ← reemplazar el generado
  services/
    http.ts
  stores/
    useAuthStore.ts   ← reemplazar el generado counter store
  views/
    HomeView.vue      ← reemplazar el generado
    LoginView.vue
  App.vue             ← reemplazar el generado
  main.ts             ← reemplazar el generado
```

---

## Paso 4 — Archivos de configuración

### `.env`
```
VITE_API_URL=<api-url>
```

### `.env.production`
```
VITE_API_URL=https://tu-api.com/api/v1
```

### `src/env.d.ts` (agregar al final del existente o crear)
```typescript
interface ImportMetaEnv {
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

---

## Paso 5 — Archivos fuente

### `src/main.ts`
```typescript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { VueQueryPlugin } from '@tanstack/vue-query'
import { locale, loadMessages } from 'devextreme/localization'
import esMessages from 'devextreme/localization/messages/es.json'
import 'devextreme/dist/css/dx.material.blue.light.compact.css'
import App from './App.vue'
import router from './router'

loadMessages(esMessages)
locale('es')

createApp(App)
  .use(createPinia())
  .use(router)
  .use(VueQueryPlugin)
  .mount('#app')
```

---

### `src/App.vue`
```vue
<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<template>
  <RouterView />
</template>
```

---

### `src/services/http.ts`
```typescript
import axios from 'axios'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: { 'Content-Type': 'application/json' },
})

// Agregar token JWT a cada request
http.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Redirigir a login si el servidor responde 401
http.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default http
```

> **Por qué leer de localStorage directamente**: importar `useAuthStore` en http.ts crearía
> una dependencia circular (store → http → store). Leer del storage evita este problema.

---

### `src/stores/useAuthStore.ts`
```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import http from '@/services/http'

interface User {
  id: number
  name: string
  email: string
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('token'))
  const user  = ref<User | null>(null)

  const isAuthenticated = computed(() => !!token.value)

  async function login(email: string, password: string) {
    const { data } = await http.post<{ token: string; user: User }>('/auth/login', { email, password })
    token.value = data.token
    user.value  = data.user
    localStorage.setItem('token', data.token)
  }

  function logout() {
    token.value = null
    user.value  = null
    localStorage.removeItem('token')
    window.location.href = '/login'
  }

  return { token, user, isAuthenticated, login, logout }
})
```

---

### `src/router/index.ts`
```typescript
import { createRouter, createWebHistory } from 'vue-router'
import AppLayout from '@/layouts/AppLayout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
    },
    {
      path: '/',
      component: AppLayout,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'home',
          component: () => import('@/views/HomeView.vue'),
        },
        // Agregar rutas de nuevas vistas aquí
      ],
    },
  ],
})

router.beforeEach(to => {
  const token = localStorage.getItem('token')
  if (to.meta.requiresAuth && !token) {
    return { name: 'login' }
  }
  if (to.name === 'login' && token) {
    return { name: 'home' }
  }
})

export default router
```

---

### `src/layouts/AppLayout.vue`
```vue
<script setup lang="ts">
import { ref } from 'vue'
import { RouterView } from 'vue-router'
import { DxDrawer }              from 'devextreme-vue/drawer'
import { DxToolbar, DxItem }     from 'devextreme-vue/toolbar'
import { DxButton }              from 'devextreme-vue/button'
import AppMenu                   from '@/components/AppMenu.vue'
import { useAuthStore }          from '@/stores/useAuthStore'

const auth        = useAuthStore()
const drawerOpen  = ref(true)
</script>

<template>
  <div class="app-shell">
    <DxToolbar class="app-toolbar">
      <DxItem location="before">
        <template #default>
          <DxButton
            icon="menu"
            styling-mode="text"
            @click="drawerOpen = !drawerOpen"
          />
        </template>
      </DxItem>
      <DxItem location="before" text="Mi Aplicación" css-class="app-title" />
      <DxItem location="after">
        <template #default>
          <DxButton
            text="Salir"
            icon="runner"
            styling-mode="text"
            @click="auth.logout()"
          />
        </template>
      </DxItem>
    </DxToolbar>

    <DxDrawer
      v-model:opened="drawerOpen"
      template="navigation"
      position="left"
      reveal-mode="slide"
      :close-on-outside-click="false"
      :width="220"
      class="app-drawer"
    >
      <template #navigation>
        <AppMenu />
      </template>
      <div class="app-content">
        <RouterView />
      </div>
    </DxDrawer>
  </div>
</template>

<style scoped>
.app-shell {
  display: flex;
  flex-direction: column;
  height: 100vh;
}
.app-toolbar {
  flex-shrink: 0;
}
:deep(.app-title) {
  font-size: 1.1rem;
  font-weight: 600;
}
.app-drawer {
  flex: 1;
  overflow: hidden;
}
.app-content {
  padding: 1.5rem;
  height: 100%;
  overflow-y: auto;
  box-sizing: border-box;
}
</style>
```

---

### `src/components/AppMenu.vue`
```vue
<script setup lang="ts">
import { useRouter, useRoute } from 'vue-router'
import { DxList } from 'devextreme-vue/list'

interface MenuItem {
  text: string
  icon: string
  route: string
}

const router = useRouter()
const route  = useRoute()

const menuItems: MenuItem[] = [
  { text: 'Inicio', icon: 'home',  route: '/' },
  // Agregar ítems aquí a medida que se crean nuevas vistas
]

function onItemClick(e: { itemData: MenuItem }) {
  router.push(e.itemData.route)
}
</script>

<template>
  <div class="app-menu">
    <DxList
      :data-source="menuItems"
      :focus-state-enabled="false"
      selection-mode="single"
      :selected-item-keys="[route.path]"
      key-expr="route"
      @item-click="onItemClick"
    />
  </div>
</template>

<style scoped>
.app-menu {
  width: 220px;
  height: 100%;
  border-right: 1px solid var(--dx-color-border);
}
</style>
```

---

### `src/composables/useGridStore.ts`
```typescript
import CustomStore from 'devextreme/data/custom_store'
import DataSource  from 'devextreme/data/data_source'
import type { LoadOptions } from 'devextreme/data/load_options'

export function useGridStore<T extends { id: number | string }>(api: {
  getAll: (opts: LoadOptions) => Promise<{ data: T[]; totalCount: number }>
  create: (values: Partial<T>) => Promise<T>
  update: (id: T['id'], values: Partial<T>) => Promise<T>
  delete: (id: T['id']) => Promise<void>
}) {
  const store = new CustomStore({
    key: 'id',
    load:   opts        => api.getAll(opts as LoadOptions),
    insert: values      => api.create(values as Partial<T>),
    update: (key, vals) => api.update(key as T['id'], vals as Partial<T>),
    remove: key         => api.delete(key as T['id']),
  })

  return {
    dataSource: new DataSource({ store, pageSize: 20 }),
  }
}
```

---

### `src/views/LoginView.vue`
```vue
<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter }     from 'vue-router'
import { DxForm, DxSimpleItem, DxRequiredRule, DxEmailRule } from 'devextreme-vue/form'
import { DxButton }      from 'devextreme-vue/button'
import { DxLoadPanel }   from 'devextreme-vue/load-panel'
import { useAuthStore }  from '@/stores/useAuthStore'
import notify            from 'devextreme/ui/notify'

const auth      = useAuthStore()
const router    = useRouter()
const isLoading = ref(false)

const formData = reactive({ email: '', password: '' })

const passwordOptions = { mode: 'password' }

async function handleLogin() {
  isLoading.value = true
  try {
    await auth.login(formData.email, formData.password)
    router.push('/')
  } catch {
    notify('Credenciales incorrectas', 'error', 3000)
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <div class="login-container">
    <DxLoadPanel :visible="isLoading" message="Verificando..." />

    <div class="login-card">
      <h2 class="login-title">Iniciar sesión</h2>

      <DxForm
        :form-data="formData"
        label-mode="floating"
        :col-count="1"
        @editor-enter-key="handleLogin"
      >
        <DxSimpleItem data-field="email" editor-type="dxTextBox">
          <DxRequiredRule message="El email es requerido" />
          <DxEmailRule message="Email inválido" />
        </DxSimpleItem>
        <DxSimpleItem
          data-field="password"
          editor-type="dxTextBox"
          :editor-options="passwordOptions"
        >
          <DxRequiredRule message="La contraseña es requerida" />
        </DxSimpleItem>
      </DxForm>

      <DxButton
        text="Ingresar"
        type="default"
        styling-mode="contained"
        width="100%"
        :use-submit-behavior="false"
        @click="handleLogin"
      />
    </div>
  </div>
</template>

<style scoped>
.login-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: #f5f5f5;
}
.login-card {
  width: 380px;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
  background: white;
}
.login-title {
  margin: 0 0 1.5rem;
  font-size: 1.4rem;
  font-weight: 600;
  color: #333;
}
</style>
```

---

### `src/views/HomeView.vue`
```vue
<script setup lang="ts">
import { useAuthStore } from '@/stores/useAuthStore'
const auth = useAuthStore()
</script>

<template>
  <div>
    <h1>Bienvenido{{ auth.user ? `, ${auth.user.name}` : '' }}</h1>
    <p>Seleccioná una opción del menú para comenzar.</p>
  </div>
</template>
```

---

## Paso 6 — Verificar instalación

```bash
npm run dev
```

Abrir `http://localhost:5173` → debe mostrar la pantalla de login.
Ingresar credenciales → debe redirigir al home con el DxDrawer visible.
