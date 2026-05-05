<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import type { RowWithSegments } from '../types/database'
import { useVegetables } from '../composables/useVegetables'
import { estimatePlanting } from '../composables/usePlantingEstimate'
import VegIcon from './VegIcon.vue'
import { XMarkIcon, ClipboardIcon, CheckIcon } from '@heroicons/vue/24/outline'

const props = defineProps<{
  open: boolean
  rows: RowWithSegments[]
}>()

const emit = defineEmits<{
  close: []
}>()

const { vegetables, fetchVegetables } = useVegetables()
const copied = ref(false)

onMounted(fetchVegetables)

const EMPTY_VEGETABLE = 'ריקה'

interface RowBreakdown {
  rowId: number
  count: number
}

interface OrderLine {
  name: string
  icon: string | null
  total: number
  isSeeded: boolean
  rows: RowBreakdown[]
}

const orderLines = computed<OrderLine[]>(() => {
  const totals = new Map<string, { icon: string | null; total: number; isSeeded: boolean; rows: RowBreakdown[] }>()

  for (const row of props.rows) {
    for (const seg of row.segments) {
      if (!seg.is_planned) continue
      if (!seg.vegetable || seg.vegetable === EMPTY_VEGETABLE || !seg.length_m) continue

      const veg = vegetables.value.find((v) => v.name === seg.vegetable)
      if (!veg?.spacing_cm || !veg.lines) continue

      const est = estimatePlanting(seg.length_m, row.drip_spacing_cm, veg.spacing_cm, veg.lines)

      const existing = totals.get(seg.vegetable)
      if (existing) {
        existing.total += est.totalPlants
        existing.rows.push({ rowId: row.id, count: est.totalPlants })
      } else {
        totals.set(seg.vegetable, {
          icon: veg.icon,
          total: est.totalPlants,
          isSeeded: veg.is_seeded,
          rows: [{ rowId: row.id, count: est.totalPlants }],
        })
      }
    }
  }

  return [...totals.entries()]
    .map(([name, data]) => ({ name, ...data }))
    .sort((a, b) => {
      if (a.isSeeded !== b.isSeeded) return a.isSeeded ? 1 : -1
      return b.total - a.total
    })
})

const transplants = computed(() => orderLines.value.filter((l) => !l.isSeeded))
const seeded = computed(() => orderLines.value.filter((l) => l.isSeeded))

const todayFormatted = computed(() =>
  new Date().toLocaleDateString('he-IL', { year: 'numeric', month: 'long', day: 'numeric' }),
)

function formatRowBreakdown(rows: RowBreakdown[], isSeeded: boolean): string {
  if (isSeeded) return rows.map((r) => `ערוגה ${r.rowId}`).join(', ')
  return rows.map((r) => `${r.count} — ערוגה ${r.rowId}`).join(' | ')
}

function buildText(): string {
  const parts: string[] = ['הזמנה למשתלה', todayFormatted.value, '']

  if (transplants.value.length > 0) {
    for (const line of transplants.value) {
      parts.push(`${line.name} — ${line.total} שתילים`)
      if (line.rows.length > 1) {
        parts.push(`   ${formatRowBreakdown(line.rows, false)}`)
      } else if (line.rows.length === 1) {
        parts[parts.length - 1] += ` (ערוגה ${line.rows[0].rowId})`
      }
    }
  }

  if (seeded.value.length > 0) {
    parts.push('')
    parts.push('זריעה ישירה:')
    for (const line of seeded.value) {
      parts.push(`${line.name} — ${formatRowBreakdown(line.rows, true)}`)
    }
  }

  return parts.join('\n')
}

const canShare = typeof navigator !== 'undefined' && !!navigator.share

async function shareList() {
  const text = buildText()
  if (canShare) {
    try {
      await navigator.share({ text })
      return
    } catch {
      // fall through to copy
    }
  }
  await copyList()
}

async function copyList() {
  try {
    await navigator.clipboard.writeText(buildText())
    copied.value = true
    setTimeout(() => { copied.value = false }, 2000)
  } catch {
    // silent fail
  }
}
</script>

<template>
  <Teleport to="body">
    <Transition name="sheet">
      <div
        v-if="open"
        class="modal modal-open modal-bottom sm:modal-middle"
        @click.self="emit('close')"
      >
        <div class="modal-box max-h-[85vh] flex flex-col">
          <div class="flex items-center justify-between mb-1">
            <h3 class="font-semibold text-base-content text-lg flex items-center gap-2"><svg class="w-5 h-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21c0-4-2-7-5-9 3-1 5 1 5 4m0 5c0-4 2-7 5-9-3-1-5 1-5 4m0-12v8" /></svg> הזמנה למשתלה</h3>
            <button
              @click="emit('close')"
              class="btn btn-ghost btn-circle btn-sm"
            ><XMarkIcon class="w-5 h-5" /></button>
          </div>
          <p class="text-xs text-base-content/40 mb-4">{{ todayFormatted }}</p>

          <div class="flex-1 overflow-y-auto">
            <div v-if="orderLines.length === 0" class="p-8 text-center text-base-content/40 text-sm">
              <div class="mb-1">אין ירקות מתוכננים</div>
              <div class="text-xs">סמן חלקים כ״מתוכנן״ בערוגות כדי ליצור הזמנה</div>
            </div>
            <template v-else>
              <!-- Transplants -->
              <div v-if="transplants.length > 0" class="space-y-1.5 mb-4">
                <div
                  v-for="line in transplants"
                  :key="line.name"
                  class="bg-base-200/50 rounded-lg px-3 py-2.5"
                >
                  <div class="flex items-center gap-3">
                    <VegIcon v-if="line.icon" :name="line.icon" size="1.25rem" />
                    <span class="flex-1 text-sm text-base-content">{{ line.name }}</span>
                    <span class="font-semibold text-sm tabular-nums text-primary">{{ line.total }}</span>
                    <span class="text-xs text-base-content/40">שתילים</span>
                  </div>
                  <div class="text-xs text-base-content/50 mt-1 pr-7">
                    <span
                      v-for="(r, i) in line.rows"
                      :key="r.rowId"
                    ><template v-if="i > 0"> | </template>{{ r.count }} — ערוגה {{ r.rowId }}</span>
                  </div>
                </div>
              </div>

              <!-- Seeded -->
              <div v-if="seeded.length > 0">
                <div class="text-xs text-base-content/40 font-medium mb-2 px-1">זריעה ישירה (ללא שתילים)</div>
                <div class="space-y-1.5">
                  <div
                    v-for="line in seeded"
                    :key="line.name"
                    class="flex items-center gap-2 px-1"
                  >
                    <span class="badge badge-neutral badge-outline gap-1">
                      <VegIcon v-if="line.icon" :name="line.icon" size="0.875rem" />
                      {{ line.name }}
                    </span>
                    <span class="text-xs text-base-content/40">{{ line.rows.map(r => `ערוגה ${r.rowId}`).join(', ') }}</span>
                  </div>
                </div>
              </div>
            </template>
          </div>

          <div v-if="orderLines.length > 0" class="modal-action">
            <button
              @click="copyList"
              class="btn flex-1"
              :class="copied ? 'btn-success' : 'btn-outline'"
            ><component :is="copied ? CheckIcon : ClipboardIcon" class="w-4 h-4" /> {{ copied ? 'הועתק' : 'העתק' }}</button>
            <button
              v-if="canShare"
              @click="shareList"
              class="btn btn-primary flex-1"
            >שיתוף</button>
          </div>
        </div>
        <div class="modal-backdrop" @click="emit('close')"></div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.sheet-enter-active {
  transition: opacity 0.2s ease;
}
.sheet-enter-active > div {
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}
.sheet-leave-active {
  transition: opacity 0.15s ease;
}
.sheet-leave-active > div {
  transition: transform 0.15s ease;
}
.sheet-enter-from {
  opacity: 0;
}
.sheet-enter-from > div {
  transform: translateY(100%);
}
.sheet-leave-to {
  opacity: 0;
}
.sheet-leave-to > div {
  transform: translateY(100%);
}
</style>
