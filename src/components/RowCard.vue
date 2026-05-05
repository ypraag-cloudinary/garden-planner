<script setup lang="ts">
import { computed } from 'vue'
import type { RowWithSegments } from '../types/database'
import SegmentBar from './SegmentBar.vue'
import { PlusCircleIcon } from '@heroicons/vue/24/outline'
import { useVegetables } from '../composables/useVegetables'

const props = defineProps<{
  row: RowWithSegments
}>()

const { vegetables } = useVegetables()

const EMPTY_VEGETABLE = 'ריקה'

const vegetableNames = computed(() => {
  if (props.row.segments.length === 0) return 'ריקה'
  const planted = props.row.segments.filter((s) => s.vegetable !== EMPTY_VEGETABLE)
  if (planted.length === 0) return 'ריקה'
  return planted.map((s) => s.vegetable).join(', ')
})

const hasPlannedSegments = computed(() =>
  props.row.segments.some((s) => s.is_planned && s.vegetable !== EMPTY_VEGETABLE)
)

const hasEmptySegments = computed(() =>
  props.row.segments.some((s) => s.vegetable === EMPTY_VEGETABLE) || props.row.segments.length === 0
)

const harvestInfo = computed(() => {
  const results: { vegetable: string; plantedAt: Date; daysLeft: number }[] = []
  for (const seg of props.row.segments) {
    if (!seg.planted_at || seg.vegetable === EMPTY_VEGETABLE) continue
    const veg = vegetables.value.find((v) => v.name === seg.vegetable)
    if (!veg?.days_to_harvest) continue
    const planted = new Date(seg.planted_at)
    const harvestDate = new Date(planted.getTime() + veg.days_to_harvest * 86400000)
    const daysLeft = Math.ceil((harvestDate.getTime() - Date.now()) / 86400000)
    results.push({ vegetable: seg.vegetable, plantedAt: planted, daysLeft })
  }
  if (results.length === 0) return null
  results.sort((a, b) => a.daysLeft - b.daysLeft)
  return results[0]
})

const isReadyToHarvest = computed(() => harvestInfo.value !== null && harvestInfo.value.daysLeft <= 0)

const subtitleText = computed(() => {
  if (!harvestInfo.value) {
    const planted = props.row.segments.filter((s) => s.planted_at && s.vegetable !== EMPTY_VEGETABLE)
    if (planted.length > 0) {
      const dates = planted.map((s) => new Date(s.planted_at!))
      const earliest = new Date(Math.min(...dates.map((d) => d.getTime())))
      return `נשתל ${formatDate(earliest)}`
    }
    return `${props.row.segments.length} ${props.row.segments.length === 1 ? 'חלק' : 'חלקים'}`
  }
  const { vegetable, plantedAt, daysLeft } = harvestInfo.value
  const datePart = `נשתל ${formatDate(plantedAt)}`
  const harvestPart = daysLeft <= 0 ? `${vegetable} מוכן לקטיף!` : `${daysLeft} ימים לקטיף`
  return `${datePart} · ${harvestPart}`
})

function formatDate(d: Date): string {
  return `${d.getDate()}/${d.getMonth() + 1}`
}
</script>

<template>
  <router-link
    :to="{ name: 'row', params: { id: row.id } }"
    class="card rounded-lg bg-base-100 border border-base-300 hover:border-neutral/30 active:bg-base-200 transition-all duration-150 no-underline text-inherit"
  >
    <div class="card-body p-4 gap-2.5">
      <div class="flex items-start gap-2.5">
        <span class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-primary/10 text-primary font-bold text-sm tabular-nums shrink-0">
          {{ row.id }}
        </span>
        <div class="flex-1 min-w-0">
          <div class="font-medium text-base-content text-sm truncate" :title="vegetableNames">
            {{ vegetableNames }}
          </div>
          <div class="text-xs mt-0.5" :class="isReadyToHarvest ? 'text-warning font-medium' : 'text-base-content/50'">
            {{ subtitleText }}
          </div>
        </div>
        <div class="flex flex-col items-start gap-1 shrink-0">
          <div class="flex gap-1">
            <span
              v-if="hasEmptySegments"
              class="badge badge-success badge-outline badge-xs gap-0.5 rounded"
            ><PlusCircleIcon class="w-3 h-3" /> פנוי לשתילה</span>
            <span
              v-if="hasPlannedSegments"
              class="badge badge-info badge-xs rounded"
            >מתוכנן</span>
          </div>
        </div>
      </div>
      <SegmentBar :segments="row.segments" :row-length="row.length_m" />
    </div>
  </router-link>
</template>
