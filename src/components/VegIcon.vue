<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  name: string | null | undefined
  size?: string
}>(), {
  size: '1.25rem'
})

const src = computed(() => {
  if (!props.name) return null
  const base = import.meta.env.BASE_URL
  return `${base}icons/${props.name}.png`
})
</script>

<template>
  <img v-if="src" :src="src" :style="{ width: size, height: size }" class="inline-block object-contain" alt="" />
  <svg v-else :style="{ width: size, height: size }" class="inline-block text-success/60" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
    <path stroke-linecap="round" stroke-linejoin="round" d="M12 21c0-4-2-7-5-9 3-1 5 1 5 4m0 5c0-4 2-7 5-9-3-1-5 1-5 4m0-12v8" />
  </svg>
</template>
