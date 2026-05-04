<script setup lang="ts">
import type { Segment } from '../types/database'
import VegetableSelect from './VegetableSelect.vue'
import { useVegetables } from '../composables/useVegetables'
import { estimatePlanting } from '../composables/usePlantingEstimate'
import { computed, ref } from 'vue'

const props = withDefaults(defineProps<{
  segment: Segment
  index: number
  rowLength: number
  remainingPct: number
  readonly: boolean
  expanded: boolean
  dripSpacingCm: number
}>(), {
  remainingPct: 100,
  readonly: false,
  expanded: true,
  dripSpacingCm: 20,
})

const emit = defineEmits<{
  'update:segment': [segment: Segment]
  remove: []
  toggle: []
}>()

const { getVegetableColor, vegetables } = useVegetables()

const EMPTY_VEGETABLE = 'ריקה'

const showNotes = ref(!!props.segment.notes)

const isEmpty = computed(() => props.segment.vegetable === EMPTY_VEGETABLE)

const accentColor = computed(() => {
  if (isEmpty.value) return '#d4d0c8'
  return props.segment.vegetable ? getVegetableColor(props.segment.vegetable) : '#c5c0b8'
})

const vegIcon = computed(() => {
  if (!props.segment.vegetable) return null
  return vegetables.value.find((v) => v.name === props.segment.vegetable)?.icon ?? null
})

const daysSincePlanting = computed(() => {
  if (!props.segment.planted_at) return null
  const planted = new Date(props.segment.planted_at)
  return Math.floor((Date.now() - planted.getTime()) / (1000 * 60 * 60 * 24))
})

const formattedDate = computed(() => {
  if (!props.segment.planted_at) return 'לא הוגדר'
  return new Date(props.segment.planted_at).toLocaleDateString('he-IL')
})

const selectedVegetable = computed(() => {
  if (!props.segment.vegetable || isEmpty.value) return null
  return vegetables.value.find((v) => v.name === props.segment.vegetable) ?? null
})

const plantingEstimate = computed(() => {
  const veg = selectedVegetable.value
  if (!veg?.spacing_cm || !veg.lines || !props.segment.length_m) return null
  return estimatePlanting(
    props.segment.length_m,
    props.dripSpacingCm,
    veg.spacing_cm,
    veg.lines,
  )
})

const LINE_LABELS: Record<string, string> = {
  all: 'כל הקווים',
  sides: 'שמאל + ימין',
  middle: 'אמצע בלבד',
}

const expectedHarvest = computed(() => {
  const veg = selectedVegetable.value
  if (!veg?.days_to_harvest || !props.segment.planted_at) return null
  const planted = new Date(props.segment.planted_at)
  const harvestDate = new Date(planted.getTime() + veg.days_to_harvest * 86400000)
  const daysLeft = Math.ceil((harvestDate.getTime() - Date.now()) / 86400000)
  return { date: harvestDate, daysLeft }
})

const formattedHarvestDate = computed(() => {
  if (!expectedHarvest.value) return ''
  const d = expectedHarvest.value.date
  return `${d.getDate()}.${d.getMonth() + 1}`
})

const fractionLabel = computed(() => {
  if (!props.segment.length_m || !props.rowLength) return ''
  const ratio = props.segment.length_m / props.rowLength
  if (Math.abs(ratio - 1) < 0.05) return 'הכל'
  if (Math.abs(ratio - 0.66) < 0.05) return '2/3'
  if (Math.abs(ratio - 0.5) < 0.05) return '1/2'
  if (Math.abs(ratio - 0.33) < 0.05) return '1/3'
  return `${props.segment.length_m} מ׳`
})

type LengthFraction = 0.33 | 0.5 | 0.66 | 1

interface FractionOption {
  value: LengthFraction
  label: string
}

const allFractions: FractionOption[] = [
  { value: 0.33, label: '1/3' },
  { value: 0.5, label: '1/2' },
  { value: 0.66, label: '2/3' },
  { value: 1, label: 'הכל' },
]

const currentFraction = computed<LengthFraction | null>(() => {
  if (!props.segment.length_m || !props.rowLength) return null
  const ratio = props.segment.length_m / props.rowLength
  if (Math.abs(ratio - 1) < 0.05) return 1
  if (Math.abs(ratio - 0.66) < 0.05) return 0.66
  if (Math.abs(ratio - 0.5) < 0.05) return 0.5
  if (Math.abs(ratio - 0.33) < 0.05) return 0.33
  return null
})

const budgetPct = computed(() => {
  const own = currentFraction.value ? Math.round(currentFraction.value * 100) : 0
  return props.remainingPct + own
})

const availableFractions = computed(() => {
  return allFractions.filter((f) => Math.round(f.value * 100) <= budgetPct.value + 2)
})

function isFractionDisabled(fraction: LengthFraction) {
  return Math.round(fraction * 100) > budgetPct.value + 2
}

function update(field: keyof Segment, value: unknown) {
  emit('update:segment', { ...props.segment, [field]: value })
}

function toggleEmpty() {
  if (isEmpty.value) {
    emit('update:segment', { ...props.segment, vegetable: '' })
  } else {
    emit('update:segment', { ...props.segment, vegetable: EMPTY_VEGETABLE })
  }
}

function setFraction(fraction: LengthFraction) {
  if (props.readonly || isFractionDisabled(fraction)) return
  const meters = Math.round(props.rowLength * fraction * 10) / 10
  update('length_m', meters)
}
</script>

<template>
  <div
    class="card bg-base-100 border overflow-hidden transition-all duration-200"
    :class="[
      readonly ? 'opacity-70' : '',
      isEmpty ? 'border-base-200 bg-base-200/50' : 'border-base-300',
    ]"
  >
    <div class="h-1" :style="{ backgroundColor: accentColor + 'aa' }" />

    <!-- Compact header (always visible, tappable for accordion) -->
    <div
      class="flex items-center gap-2.5 px-4 py-3 cursor-pointer"
      @click="emit('toggle')"
    >
      <span v-if="vegIcon" class="text-lg leading-none shrink-0">{{ vegIcon }}</span>
      <span v-else class="w-5 h-5 rounded-full shrink-0" :style="{ backgroundColor: accentColor + 'aa' }" />
      <div class="flex-1 min-w-0">
        <span class="text-sm font-medium text-base-content truncate block">
          {{ isEmpty ? 'חלק ריק' : (segment.vegetable || `חלק ${index + 1}`) }}
        </span>
      </div>
      <div class="flex items-center gap-1.5 shrink-0">
        <span v-if="segment.is_planned && !isEmpty" class="badge badge-sm badge-info badge-outline">מתוכנן</span>
        <span v-if="fractionLabel" class="text-xs text-base-content/50">{{ fractionLabel }}</span>
        <span
          v-if="daysSincePlanting !== null && !segment.is_planned"
          class="badge badge-sm tabular-nums"
          :style="{ backgroundColor: accentColor + '14', color: accentColor + 'cc' }"
        >{{ daysSincePlanting }}d</span>
        <span
          v-if="expectedHarvest && !segment.is_planned"
          class="badge badge-sm tabular-nums"
          :class="expectedHarvest.daysLeft <= 0 ? 'badge-warning' : 'badge-success badge-outline'"
        >{{ expectedHarvest.daysLeft <= 0 ? 'מוכן!' : `קטיף ~${formattedHarvestDate}` }}</span>
        <svg
          class="w-4 h-4 text-base-content/30 transition-transform duration-200"
          :class="{ 'rotate-180': expanded }"
          fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
        </svg>
      </div>
    </div>

    <!-- Expanded content -->
    <div
      v-show="expanded"
      class="px-4 pb-4 space-y-3"
      :class="{ 'pointer-events-none': readonly }"
    >
      <!-- Vegetable selection -->
      <div>
        <div class="flex items-center gap-2 mb-2">
          <template v-if="!readonly">
            <button
              type="button"
              @click="toggleEmpty"
              class="badge badge-sm cursor-pointer"
              :class="isEmpty ? 'badge-neutral' : 'badge-ghost badge-outline'"
            >{{ isEmpty ? 'ריקה ✓' : 'סמן ריק' }}</button>
            <button
              v-if="!isEmpty"
              type="button"
              @click="update('is_planned', !segment.is_planned)"
              class="badge badge-sm cursor-pointer"
              :class="segment.is_planned ? 'badge-info' : 'badge-ghost badge-outline'"
            >{{ segment.is_planned ? 'מתוכנן ✓' : 'סמן כמתוכנן' }}</button>
          </template>
        </div>
        <template v-if="!isEmpty">
          <div class="flex items-stretch gap-2">
            <div class="flex-1 min-w-0">
              <VegetableSelect
                :model-value="segment.vegetable"
                @update:model-value="update('vegetable', $event)"
              />
            </div>
            <label class="btn btn-outline min-w-fit shrink-0 gap-1">
              <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <span>{{ formattedDate }}</span>
              <input
                type="date"
                class="sr-only"
                :value="segment.planted_at ?? ''"
                @input="update('planted_at', ($event.target as HTMLInputElement).value || null)"
                :disabled="readonly"
              />
            </label>
          </div>
          <p v-if="!segment.vegetable" class="text-xs text-error mt-1">חובה לבחור ירק</p>
          <!-- Planting estimate -->
          <div
            v-if="plantingEstimate && selectedVegetable"
            class="mt-2 flex items-center gap-2 text-xs bg-success/10 text-success rounded-lg px-3 py-2"
          >
            <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
            </svg>
            <template v-if="selectedVegetable.is_seeded">
              <span>זריעה · {{ LINE_LABELS[selectedVegetable.lines!] }}</span>
              <span v-if="plantingEstimate.dripInterval > 1">· כל טפטפת {{ plantingEstimate.dripInterval }}</span>
              <span v-else>· כל טפטפת</span>
            </template>
            <template v-else>
              <span class="font-semibold">~{{ plantingEstimate.totalPlants }} שתילים</span>
              <span class="text-success/70">{{ LINE_LABELS[selectedVegetable.lines!] }}</span>
              <span v-if="plantingEstimate.plantsPerDrip > 1" class="text-success/70">· {{ plantingEstimate.plantsPerDrip }} לכל טפטפת</span>
              <span v-else-if="plantingEstimate.dripInterval > 1" class="text-success/70">· כל טפטפת {{ plantingEstimate.dripInterval }}</span>
            </template>
          </div>
          <!-- Harvest ETA -->
          <div
            v-if="expectedHarvest && !segment.is_planned"
            class="mt-1 flex items-center gap-1.5 text-xs px-1"
            :class="expectedHarvest.daysLeft <= 0 ? 'text-warning' : 'text-base-content/60'"
          >
            <svg class="w-3.5 h-3.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <template v-if="expectedHarvest.daysLeft <= 0">
              <span class="font-medium">מוכן לקטיף!</span>
              <span>({{ expectedHarvest.date.toLocaleDateString('he-IL') }})</span>
            </template>
            <template v-else>
              <span>קטיף משוער: {{ expectedHarvest.date.toLocaleDateString('he-IL') }}</span>
              <span class="text-base-content/40">(עוד {{ expectedHarvest.daysLeft }} ימים)</span>
            </template>
          </div>
        </template>
      </div>

      <!-- Length fractions -->
      <div>
        <div class="join w-full">
          <button
            v-for="frac in availableFractions"
            :key="frac.value"
            type="button"
            @click="setFraction(frac.value)"
            :disabled="isFractionDisabled(frac.value)"
            class="btn join-item flex-1 btn-sm"
            :class="[
              isFractionDisabled(frac.value)
                ? 'btn-disabled'
                : currentFraction === frac.value
                  ? 'btn-primary'
                  : 'btn-outline'
            ]"
          >{{ frac.label }}</button>
        </div>
      </div>

      <!-- Notes (collapsed by default) -->
      <div>
        <button
          v-if="!showNotes && !readonly"
          type="button"
          @click="showNotes = true"
          class="btn btn-ghost btn-xs text-base-content/50 gap-1 px-0"
        >
          <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
          הוסף הערה
        </button>
        <textarea
          v-if="showNotes || segment.notes"
          :value="segment.notes ?? ''"
          @input="update('notes', ($event.target as HTMLTextAreaElement).value || null)"
          rows="2"
          class="textarea textarea-bordered w-full resize-none text-sm"
          placeholder="הערות..."
        />
      </div>

      <!-- Remove action -->
      <div v-if="!readonly" class="flex justify-end">
        <button
          type="button"
          @click="emit('remove')"
          class="btn btn-ghost btn-xs text-error gap-1"
        >
          <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
          הסר חלק
        </button>
      </div>
    </div>
  </div>
</template>
