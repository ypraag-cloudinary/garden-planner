<script setup lang="ts">
import { computed } from 'vue'
import type { Segment } from '../types/database'
import { useVegetables } from '../composables/useVegetables'
import VegIcon from './VegIcon.vue'

const props = defineProps<{
  segments: Segment[]
  rowLength: number
}>()

const emit = defineEmits<{
  'select-segment': [index: number]
}>()

const { getVegetableColor, vegetables } = useVegetables()

const EMPTY_VEGETABLE = 'ריקה'

function getIcon(name: string): string | null {
  return vegetables.value.find((v) => v.name === name)?.icon ?? null
}

const bars = computed(() => {
  if (props.segments.length === 0) return []

  return props.segments.map((seg, index) => {
    const pct = seg.length_m
      ? (seg.length_m / props.rowLength) * 100
      : 100 / props.segments.length
    const isEmpty = seg.vegetable === EMPTY_VEGETABLE
    return {
      id: seg.id || `new-${index}`,
      index,
      vegetable: seg.vegetable,
      icon: isEmpty ? null : getIcon(seg.vegetable),
      color: isEmpty ? '#d4d0c8' : getVegetableColor(seg.vegetable),
      width: Math.max(pct, 8),
      isEmpty,
    }
  })
})

const unallocatedPct = computed(() => {
  const allocated = props.segments.reduce((sum, s) => sum + (s.length_m ?? 0), 0)
  const remaining = Math.max(0, props.rowLength - allocated)
  return (remaining / props.rowLength) * 100
})
</script>

<template>
  <div v-if="bars.length > 0" class="space-y-1.5">
    <div class="flex h-7 rounded-md overflow-hidden gap-1">
      <button
        v-for="bar in bars"
        :key="bar.id"
        type="button"
        @click="emit('select-segment', bar.index)"
        class="rounded-md border transition-all duration-300 ease-out flex items-center justify-start ps-2 cursor-pointer hover:bg-base-200 active:bg-base-300"
        :style="{ width: bar.width + '%', borderColor: bar.color + '66', background: `linear-gradient(to right, ${bar.color}22, transparent 40%)` }"
      >
        <VegIcon v-if="bar.icon" :name="bar.icon" size="0.875rem" />
        <span
          v-else-if="bar.vegetable && !bar.isEmpty && bar.width > 20"
          class="text-[10px] text-base-content/50 font-medium truncate px-1"
        >{{ bar.vegetable }}</span>
      </button>
      <div
        v-if="unallocatedPct > 2"
        class="rounded-md border-2 border-dashed border-base-content/15 flex items-center justify-center"
        :style="{ width: unallocatedPct + '%' }"
      >
        <span v-if="unallocatedPct > 15" class="text-[10px] text-base-content/30">פנוי</span>
      </div>
    </div>
  </div>
  <div v-else class="h-7 rounded-md bg-base-200 border-2 border-dashed border-base-300 flex items-center justify-center">
    <span class="text-[10px] text-base-content/30">לא הוקצה</span>
  </div>
</template>
