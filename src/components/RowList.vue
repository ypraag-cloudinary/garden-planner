<script setup lang="ts">
import { computed } from 'vue'
import type { RowWithSegments } from '../types/database'
import RowCard from './RowCard.vue'

const props = defineProps<{
  rows: RowWithSegments[]
}>()

const leftRows = computed(() => props.rows.filter((r) => r.section === 'left'))
const rightRows = computed(() => props.rows.filter((r) => r.section === 'right'))
</script>

<template>
  <div class="space-y-8 md:grid md:grid-cols-2 md:gap-8 md:space-y-0" style="direction: ltr">
    <section dir="rtl">
      <h2 class="text-xs font-semibold text-base-content/40 uppercase tracking-widest px-4 mb-3">
        צד שמאל · ערוגות 1–13
      </h2>
      <div class="space-y-2.5 px-4">
        <RowCard v-for="(row, i) in leftRows" :key="row.id" :row="row" :style="{ animationDelay: `${i * 30}ms` }" class="animate-row-in" />
      </div>
    </section>

    <section dir="rtl">
      <h2 class="text-xs font-semibold text-base-content/40 uppercase tracking-widest px-4 mb-3">
        צד ימין · ערוגות 14–27
      </h2>
      <div class="space-y-2.5 px-4">
        <RowCard v-for="(row, i) in rightRows" :key="row.id" :row="row" :style="{ animationDelay: `${i * 30}ms` }" class="animate-row-in" />
      </div>
    </section>
  </div>
</template>

<style scoped>
@keyframes row-in {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-row-in {
  animation: row-in 0.25s cubic-bezier(0.16, 1, 0.3, 1) both;
}
</style>
