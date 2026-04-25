<script setup lang="ts">
import { computed } from 'vue'
import type { RowWithSegments } from '../types/database'
import SegmentBar from './SegmentBar.vue'

const props = defineProps<{
  row: RowWithSegments
}>()

const EMPTY_VEGETABLE = 'ריקה'

const vegetableNames = computed(() => {
  if (props.row.segments.length === 0) return 'ריקה'
  const planted = props.row.segments.filter((s) => s.vegetable !== EMPTY_VEGETABLE)
  if (planted.length === 0) return 'ריקה'
  return planted.map((s) => s.vegetable).join(', ')
})

const daysSincePlanting = computed(() => {
  const dates = props.row.segments
    .filter((s) => s.planted_at)
    .map((s) => new Date(s.planted_at!))
  if (dates.length === 0) return null
  const earliest = new Date(Math.min(...dates.map((d) => d.getTime())))
  const diff = Math.floor((Date.now() - earliest.getTime()) / (1000 * 60 * 60 * 24))
  return diff
})
</script>

<template>
  <router-link
    :to="{ name: 'row', params: { id: row.id } }"
    class="block bg-white rounded-xl border border-soil-200 p-4 hover:border-soil-300 active:bg-soil-50 transition-all duration-150 no-underline text-inherit"
  >
    <div class="flex items-start justify-between mb-2.5">
      <div class="flex items-center gap-2.5">
        <span class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-garden-100 text-garden-700 font-bold text-sm tabular-nums">
          {{ row.id }}
        </span>
        <div>
          <div class="font-medium text-soil-800 text-sm flex items-center gap-1.5">
            {{ vegetableNames }}
            <span
              v-if="row.has_trellis"
              class="inline-block text-[10px] bg-harvest-50 text-harvest-700 border border-harvest-200 px-1.5 py-0 rounded font-normal leading-relaxed"
            >הדליה</span>
          </div>
          <div class="text-xs text-soil-400 mt-0.5">
            {{ row.length_m }} מ׳
            · טפטוף כל {{ row.drip_spacing_cm }} ס״מ
            · {{ row.segments.length }} {{ row.segments.length === 1 ? 'חלק' : 'חלקים' }}
          </div>
        </div>
      </div>
      <div v-if="daysSincePlanting !== null" class="text-xs font-medium text-garden-700 bg-garden-50 px-2 py-0.5 rounded-full whitespace-nowrap tabular-nums">
        {{ daysSincePlanting }} ימים
      </div>
    </div>
    <SegmentBar :segments="row.segments" :row-length="row.length_m" />
  </router-link>
</template>
