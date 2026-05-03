<script setup lang="ts">
import type { Segment } from '../types/database'
import VegetableSelect from './VegetableSelect.vue'
import { useVegetables } from '../composables/useVegetables'
import { computed, ref } from 'vue'

const props = withDefaults(defineProps<{
  segment: Segment
  index: number
  rowLength: number
  remainingPct: number
  readonly: boolean
}>(), {
  remainingPct: 100,
  readonly: false,
})

const emit = defineEmits<{
  'update:segment': [segment: Segment]
  remove: []
}>()

const { getVegetableColor } = useVegetables()

const EMPTY_VEGETABLE = 'ריקה'

const editingDate = ref(false)

const isEmpty = computed(() => props.segment.vegetable === EMPTY_VEGETABLE)

const accentColor = computed(() => {
  if (isEmpty.value) return '#d4d0c8'
  return props.segment.vegetable ? getVegetableColor(props.segment.vegetable) : '#c5c0b8'
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

function toggleEmpty(checked: boolean) {
  if (checked) {
    emit('update:segment', { ...props.segment, vegetable: EMPTY_VEGETABLE })
  } else {
    emit('update:segment', { ...props.segment, vegetable: '' })
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
    class="card bg-base-100 border overflow-hidden"
    :class="[
      readonly ? 'opacity-70' : '',
      isEmpty ? 'border-base-200 bg-base-200/50' : 'border-base-300',
    ]"
  >
    <div class="h-1" :style="{ backgroundColor: accentColor }" />
    <div class="card-body p-4 gap-3.5" :class="{ 'pointer-events-none': readonly }">
      <div class="flex items-center justify-between">
        <span class="text-sm font-semibold" :class="isEmpty ? 'text-base-content/40' : 'text-base-content/70'">
          {{ isEmpty ? 'חלק ריק' : `חלק ${index + 1}` }}
        </span>
        <div class="flex items-center gap-2">
          <span
            v-if="daysSincePlanting !== null"
            class="badge badge-sm tabular-nums"
            :style="{ backgroundColor: accentColor + '18', color: accentColor }"
          >
            {{ daysSincePlanting }} ימים
          </span>
          <button
            v-if="!readonly"
            type="button"
            @click="emit('remove')"
            class="btn btn-ghost btn-xs text-error gap-1"
          >
            <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            הסר
          </button>
        </div>
      </div>

      <div>
        <label v-if="!readonly" class="flex items-center gap-2 mb-2 cursor-pointer">
          <input
            type="checkbox"
            :checked="isEmpty"
            @change="toggleEmpty(($event.target as HTMLInputElement).checked)"
            class="checkbox checkbox-sm"
          />
          <span class="text-xs font-medium text-base-content/60">חלק ריק</span>
        </label>
        <template v-if="!isEmpty">
          <label class="label text-xs font-medium">ירק <span class="text-error">*</span></label>
          <VegetableSelect
            :model-value="segment.vegetable"
            @update:model-value="update('vegetable', $event)"
          />
          <p v-if="!segment.vegetable" class="text-xs text-error mt-1">חובה לבחור ירק</p>
        </template>
      </div>

      <div v-if="!isEmpty">
        <label class="label text-xs font-medium">תאריך שתילה</label>
        <div class="flex items-center gap-2">
          <span class="text-sm text-base-content">{{ formattedDate }}</span>
          <button
            v-if="!editingDate && !readonly"
            type="button"
            @click="editingDate = true"
            class="btn btn-ghost btn-xs btn-circle text-primary"
            title="שנה תאריך"
          >
            <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
            </svg>
          </button>
          <template v-if="editingDate && !readonly">
            <input
              type="date"
              :value="segment.planted_at ?? ''"
              @input="update('planted_at', ($event.target as HTMLInputElement).value || null); editingDate = false"
              class="input input-bordered input-sm"
            />
            <button
              type="button"
              @click="editingDate = false"
              class="btn btn-ghost btn-xs"
            >ביטול</button>
          </template>
        </div>
      </div>

      <div>
        <label class="label text-xs font-medium">אורך</label>
        <div class="join w-full">
          <button
            v-for="frac in availableFractions"
            :key="frac.value"
            type="button"
            @click="setFraction(frac.value)"
            :disabled="isFractionDisabled(frac.value)"
            class="btn join-item flex-1"
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

      <div>
        <label class="label text-xs font-medium">הערות</label>
        <textarea
          :value="segment.notes ?? ''"
          @input="update('notes', ($event.target as HTMLTextAreaElement).value || null)"
          rows="2"
          class="textarea textarea-bordered w-full resize-none"
          placeholder="הערות..."
        />
      </div>
    </div>
  </div>
</template>
