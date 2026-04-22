<script setup lang="ts">
import { useAuth } from '../composables/useAuth'
import { useRouter } from 'vue-router'

const { signOut } = useAuth()
const router = useRouter()

async function handleLogout() {
  await signOut()
  router.replace('/login')
}
</script>

<template>
  <div class="min-h-screen bg-soil-50">
    <header class="sticky top-0 z-30 bg-white/95 backdrop-blur-sm border-b border-soil-200">
      <div class="max-w-lg mx-auto px-4 h-14 flex items-center justify-between">
        <router-link to="/" class="flex items-center gap-2.5 text-garden-700 font-semibold text-base no-underline tracking-tight">
          <span class="text-xl">🌱</span>
          <span>גינה קהילתית</span>
        </router-link>
        <div class="flex items-center gap-2">
          <slot name="header-right" />
          <button
            @click="handleLogout"
            class="w-10 h-10 rounded-lg bg-soil-50 text-soil-500 flex items-center justify-center hover:bg-soil-100 hover:text-soil-700 active:scale-[0.97] transition-all duration-150 cursor-pointer text-base"
            title="התנתק"
          >
            ⏻
          </button>
        </div>
      </div>
    </header>
    <main class="max-w-lg mx-auto">
      <slot />
    </main>
  </div>
</template>
