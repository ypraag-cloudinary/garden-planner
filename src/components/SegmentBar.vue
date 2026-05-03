<script setup lang="ts">
import { computed } from 'vue'
import type { Segment } from '../types/database'
import { useVegetables } from '../composables/useVegetables'

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
    <div class="flex h-7 rounded-lg overflow-hidden bg-base-300 gap-px">
      <button
        v-for="bar in bars"
        :key="bar.id"
        type="button"
        @click="emit('select-segment', bar.index)"
        class="rounded-lg transition-all duration-300 ease-out flex items-center justify-center cursor-pointer hover:brightness-105 active:brightness-95"
        :style="{ width: bar.width + '%', backgroundColor: bar.color + 'cc' }"
      >
        <span v-if="bar.icon" class="text-xs leading-none">{{ bar.icon }}</span>
        <span
          v-else-if="bar.vegetable && !bar.isEmpty && bar.width > 20"
          class="text-[10px] text-white/80 font-medium truncate px-1"
        >{{ bar.vegetable }}</span>
      </button>
      <div
        v-if="unallocatedPct > 2"
        class="rounded-lg border-2 border-dashed border-base-content/15 flex items-center justify-center"
        :style="{ width: unallocatedPct + '%' }"
      >
        <span v-if="unallocatedPct > 15" class="text-[10px] text-base-content/30">פנוי</span>
      </div>
    </div>
  </div>
  <div v-else class="h-7 rounded-lg bg-base-200 border-2 border-dashed border-base-300 flex items-center justify-center">
    <span class="text-[10px] text-base-content/30">לא הוקצה</span>
  </div>
</template>
