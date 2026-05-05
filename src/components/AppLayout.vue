<template>
  <div class="min-h-screen bg-base-200">
    <header class="navbar sticky top-0 z-30 bg-base-100/95 backdrop-blur-sm border-b border-base-300">
      <div class="max-w-lg md:max-w-3xl mx-auto px-4 w-full flex items-center justify-between">
        <router-link to="/" class="flex items-center gap-2.5 text-primary font-semibold text-base no-underline tracking-tight">
          <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21c0-4-2-7-5-9 3-1 5 1 5 4m0 5c0-4 2-7 5-9-3-1-5 1-5 4m0-12v8" /></svg>
          <span>גינה קהילתית</span>
        </router-link>
        <div class="flex items-center gap-2">
          <slot name="header-right" />
        </div>
      </div>
    </header>
    <main class="max-w-lg md:max-w-3xl mx-auto">
      <slot />
    </main>
  </div>
</template>
