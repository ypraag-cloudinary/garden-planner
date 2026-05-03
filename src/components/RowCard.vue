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
    class="card bg-base-100 border border-base-300 hover:border-neutral/30 active:bg-base-200 transition-all duration-150 no-underline text-inherit"
  >
    <div class="card-body p-4 gap-2.5">
      <div class="flex items-start justify-between">
        <div class="flex items-center gap-2.5">
          <span class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-primary/10 text-primary font-bold text-sm tabular-nums">
            {{ row.id }}
          </span>
          <div>
            <div class="font-medium text-base-content text-sm flex items-center gap-1.5">
              {{ vegetableNames }}
              <span
                v-if="row.has_trellis"
                class="badge badge-warning badge-xs"
              >הדליה</span>
            </div>
            <div class="text-xs text-base-content/50 mt-0.5">
              {{ row.length_m }} מ׳
              · טפטוף כל {{ row.drip_spacing_cm }} ס״מ
              · {{ row.segments.length }} {{ row.segments.length === 1 ? 'חלק' : 'חלקים' }}
            </div>
          </div>
        </div>
        <div v-if="daysSincePlanting !== null" class="badge badge-primary badge-outline badge-sm tabular-nums">
          {{ daysSincePlanting }} ימים
        </div>
      </div>
      <SegmentBar :segments="row.segments" :row-length="row.length_m" />
    </div>
  </router-link>
</template>
