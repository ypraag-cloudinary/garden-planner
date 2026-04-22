<script setup lang="ts">
import { computed } from 'vue'
import type { Segment } from '../types/database'
import { useVegetables } from '../composables/useVegetables'

const props = defineProps<{
  segments: Segment[]
  rowLength: number
}>()

const { getVegetableColor } = useVegetables()

const bars = computed(() => {
  if (props.segments.length === 0) return []

  const totalAllocated = props.segments.reduce((sum, s) => sum + (s.length_m ?? 0), 0)

  return props.segments.map((seg) => {
    const pct = totalAllocated > 0 && seg.length_m
      ? (seg.length_m / props.rowLength) * 100
      : 100 / props.segments.length
    return {
      id: seg.id,
      vegetable: seg.vegetable,
      color: getVegetableColor(seg.vegetable),
      width: Math.max(pct, 5),
    }
  })
})
</script>

<template>
  <div class="flex h-2 rounded-full overflow-hidden bg-soil-200 gap-px" v-if="bars.length > 0">
    <div
      v-for="bar in bars"
      :key="bar.id"
      class="rounded-full transition-all duration-300 ease-out"
      :style="{ width: bar.width + '%', backgroundColor: bar.color }"
      :title="bar.vegetable"
    />
  </div>
  <div v-else class="h-2 rounded-full bg-soil-100 border border-dashed border-soil-300" />
</template>
