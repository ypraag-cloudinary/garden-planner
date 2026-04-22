<script setup lang="ts">
</script>

<template>
  <div class="min-h-screen bg-soil-50">
    <header class="sticky top-0 z-30 bg-white/95 backdrop-blur-sm border-b border-soil-200">
      <div class="max-w-lg mx-auto px-4 h-14 flex items-center justify-between">
        <router-link to="/" class="flex items-center gap-2.5 text-garden-700 font-semibold text-base no-underline tracking-tight">
          <span class="text-xl">🌱</span>
          <span>גינה קהילתית</span>
        </router-link>
        <slot name="header-right" />
      </div>
    </header>
    <main class="max-w-lg mx-auto">
      <slot />
    </main>
  </div>
</template>
