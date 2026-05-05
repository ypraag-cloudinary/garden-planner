<script setup lang="ts">
import { ref, computed, watch, nextTick, onMounted } from 'vue'
import { toPng } from 'html-to-image'
import type { RowWithSegments, Segment } from '../types/database'
import { useVegetables } from '../composables/useVegetables'
import { estimatePlanting } from '../composables/usePlantingEstimate'
import VegIcon from './VegIcon.vue'
import { XMarkIcon } from '@heroicons/vue/24/outline'

const props = defineProps<{
  open: boolean
  rows: RowWithSegments[]
}>()

const { vegetables, fetchVegetables } = useVegetables()

onMounted(fetchVegetables)

const emit = defineEmits<{
  close: []
}>()

const renderTarget = ref<HTMLElement | null>(null)
const previewUrl = ref<string | null>(null)
const generating = ref(false)

const canShare = typeof navigator !== 'undefined' && !!navigator.share

const sectionARows = computed(() => props.rows.filter((r) => r.section === 'left'))
const sectionBRows = computed(() => props.rows.filter((r) => r.section === 'right'))

const todayFormatted = computed(() =>
  new Date().toLocaleDateString('he-IL', { year: 'numeric', month: 'long', day: 'numeric' })
)

function formatAge(days: number | null): string {
  if (days === null) return ''
  if (days === 0) return 'היום'
  if (days < 7) return `${days} ימים`
  if (days < 30) {
    const weeks = Math.round(days / 7)
    return `${weeks} ${weeks === 1 ? 'שבוע' : 'שבועות'}`
  }
  const months = Math.round(days / 30)
  return `${months} ${months === 1 ? 'חודש' : 'חודשים'}`
}

function getEarliestPlantingDate(row: RowWithSegments): Date | null {
  const dates = row.segments
    .filter((s) => s.planted_at)
    .map((s) => new Date(s.planted_at!))
  if (dates.length === 0) return null
  return new Date(Math.min(...dates.map((d) => d.getTime())))
}

function formatPlantingInfo(row: RowWithSegments): string | null {
  const earliest = getEarliestPlantingDate(row)
  if (!earliest) return null
  const days = Math.floor((Date.now() - earliest.getTime()) / (1000 * 60 * 60 * 24))
  const dd = String(earliest.getDate()).padStart(2, '0')
  const mm = String(earliest.getMonth() + 1).padStart(2, '0')
  const yyyy = earliest.getFullYear()
  return `נשתל ${dd}/${mm}/${yyyy} (${formatAge(days)})`
}

const EMPTY_VEGETABLE = 'ריקה'

function getVegetableIcon(name: string): string | null {
  return vegetables.value.find((v) => v.name === name)?.icon ?? null
}

interface SegmentDisplayLine {
  label: string
  icon: string | null
  isPlanned: boolean
  harvestHint: string | null
}

function getHarvestHint(seg: Segment): string | null {
  if (!seg.planted_at || seg.is_planned) return null
  const veg = vegetables.value.find((v) => v.name === seg.vegetable)
  if (!veg?.days_to_harvest) return null
  const planted = new Date(seg.planted_at)
  const harvestDate = new Date(planted.getTime() + veg.days_to_harvest * 86400000)
  const daysLeft = Math.ceil((harvestDate.getTime() - Date.now()) / 86400000)
  if (daysLeft <= 0) return 'מוכן לקטיף!'
  return `קטיף ~${harvestDate.getDate()}/${harvestDate.getMonth() + 1}`
}

function getSegmentLines(row: RowWithSegments): SegmentDisplayLine[] {
  const planted = row.segments.filter((s) => s.vegetable !== EMPTY_VEGETABLE)
  if (planted.length === 0) return [{ label: 'ריקה', icon: null, isPlanned: false, harvestHint: null }]
  return planted.map((s) => {
    const icon = getVegetableIcon(s.vegetable)
    return { label: s.vegetable, icon, isPlanned: s.is_planned, harvestHint: getHarvestHint(s) }
  })
}

function getRowNotes(row: RowWithSegments): string {
  const parts: string[] = []
  if (row.notes?.trim()) parts.push(row.notes.trim())
  for (const seg of row.segments) {
    if (seg.notes?.trim()) parts.push(`${seg.vegetable}: ${seg.notes.trim()}`)
  }
  return parts.join(' · ')
}

const LINE_LABELS: Record<string, string> = {
  all: 'כל הקווים',
  sides: 'שמאל + ימין',
  middle: 'אמצע בלבד',
}

function hasPlannedSegments(row: RowWithSegments): boolean {
  return row.segments.some((s) => s.is_planned && s.vegetable !== EMPTY_VEGETABLE)
}

interface PlannedSegmentInfo {
  vegetable: string
  icon: string | null
  description: string
}

function getPlannedSegmentInfos(row: RowWithSegments): PlannedSegmentInfo[] {
  return row.segments
    .filter((s): s is Segment & { length_m: number } =>
      s.is_planned && s.vegetable !== EMPTY_VEGETABLE && !!s.length_m)
    .map((seg) => {
      const veg = vegetables.value.find((v) => v.name === seg.vegetable)
      const icon = veg?.icon ?? null
      if (!veg?.spacing_cm || !veg.lines) {
        return { vegetable: seg.vegetable, icon, description: 'מתוכנן' }
      }
      const est = estimatePlanting(seg.length_m, row.drip_spacing_cm, veg.spacing_cm, veg.lines)
      const parts: string[] = []
      if (!veg.is_seeded) {
        parts.push(`~${est.totalPlants} שתילים`)
      } else {
        parts.push('זריעה')
      }
      if (est.plantsPerDrip > 1) {
        parts.push(`${est.plantsPerDrip} לכל טפטפת`)
      } else if (est.dripInterval > 1) {
        parts.push(`כל טפטפת ${est.dripInterval}`)
      } else {
        parts.push('כל טפטפת')
      }
      parts.push(LINE_LABELS[veg.lines])
      return { vegetable: seg.vegetable, icon, description: parts.join(' · ') }
    })
}

async function generateImage() {
  if (!renderTarget.value) return
  generating.value = true
  try {
    await nextTick()
    const dataUrl = await toPng(renderTarget.value, {
      pixelRatio: 3,
      skipFonts: true,
    })
    previewUrl.value = dataUrl
  } catch (e) {
    console.error('Export failed:', e)
  } finally {
    generating.value = false
  }
}

function downloadImage() {
  if (!previewUrl.value) return
  const link = document.createElement('a')
  link.download = `גינה-קהילתית-${new Date().toISOString().slice(0, 10)}.png`
  link.href = previewUrl.value
  link.click()
}

async function shareImage() {
  if (!previewUrl.value) return
  try {
    const res = await fetch(previewUrl.value)
    const blob = await res.blob()
    const file = new File([blob], 'garden-summary.png', { type: 'image/png' })
    if (navigator.canShare?.({ files: [file] })) {
      await navigator.share({ files: [file] })
      return
    }
  } catch {
    // fall through to download
  }
  downloadImage()
}

function handleClose() {
  previewUrl.value = null
  emit('close')
}

watch(() => props.open, async (isOpen) => {
  if (isOpen) {
    previewUrl.value = null
    await nextTick()
    generateImage()
  }
})
</script>

<template>
  <Teleport to="body">
    <Transition name="export">
      <div
        v-if="open"
        class="fixed inset-0 z-50 bg-neutral/85 flex flex-col"
        @click.self="handleClose"
      >
        <div class="flex items-center justify-between px-4 py-3 bg-neutral/60">
          <span class="text-neutral-content/90 font-medium text-sm">ייצוא מפת גינה</span>
          <div class="flex items-center gap-1.5">
            <button
              v-if="previewUrl && canShare"
              @click="shareImage"
              class="btn btn-ghost btn-sm text-neutral-content"
            >שיתוף</button>
            <button
              v-if="previewUrl"
              @click="downloadImage"
              class="btn btn-ghost btn-sm text-neutral-content"
            >הורדה</button>
            <button
              @click="handleClose"
              class="btn btn-ghost btn-square btn-sm text-neutral-content mr-1"
            ><XMarkIcon class="w-5 h-5" /></button>
          </div>
        </div>

        <div class="flex-1 overflow-auto flex items-start justify-center p-4">
          <div v-if="generating" class="text-neutral-content/80 text-sm mt-20">
            <span class="loading loading-dots loading-md"></span>
            <div>יוצר תמונה...</div>
          </div>

          <img
            v-else-if="previewUrl"
            :src="previewUrl"
            alt="מפת גינה"
            class="max-w-full rounded-lg shadow-2xl"
          />
        </div>

        <!-- Off-screen render target -->
        <div class="fixed" style="left: -9999px; top: 0">
          <div
            ref="renderTarget"
            dir="rtl"
            style="
              width: 600px;
              padding: 32px;
              background: #f7faf7;
              font-family: Rubik, system-ui, sans-serif;
              color: #3d4a3d;
              line-height: 1.5;
            "
          >
            <div style="text-align: center; margin-bottom: 28px">
              <div style="font-size: 30px; font-weight: 600; color: #2d5a3d">
                גינה קהילתית
              </div>
              <div style="font-size: 18px; color: #8a9a8a; margin-top: 6px">
                {{ todayFormatted }}
              </div>
            </div>

            <div style="font-size: 20px; font-weight: 700; color: #2d5a3d; padding: 10px 0; margin-bottom: 10px; border-bottom: 2px solid #c8dcc8">
              ערוגות 1–13
            </div>
            <div style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 28px">
              <div
                v-for="row in sectionARows"
                :key="row.id"
                style="
                  display: flex;
                  align-items: flex-start;
                  gap: 12px;
                  background: white;
                  border: 1px solid #e0e8e0;
                  border-radius: 12px;
                  padding: 14px 16px;
                "
              >
                <div style="
                  width: 42px;
                  height: 42px;
                  border-radius: 10px;
                  background: #ddf0dd;
                  color: #2d5a3d;
                  font-weight: 700;
                  font-size: 20px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  flex-shrink: 0;
                ">{{ row.id }}</div>
                <div style="flex: 1; min-width: 0">
                  <div
                    v-if="row.has_trellis || hasPlannedSegments(row)"
                    style="margin-bottom: 3px"
                  >
                    <span
                      v-if="row.has_trellis"
                      style="font-size: 14px; font-weight: 600; background: #fef3c7; color: #92400e; border: 1px solid #fcd34d; padding: 2px 7px; border-radius: 5px; margin-inline-end: 5px"
                    >הדליה</span>
                    <span
                      v-if="hasPlannedSegments(row)"
                      style="font-size: 14px; font-weight: 600; background: #dbeafe; color: #1e40af; border: 1px solid #93c5fd; padding: 2px 7px; border-radius: 5px"
                    >מתוכנן</span>
                  </div>
                  <div
                    v-for="(seg, si) in getSegmentLines(row)"
                    :key="si"
                    style="font-size: 20px; font-weight: 500; color: #3d4a3d; display: flex; align-items: center; gap: 6px"
                  ><VegIcon v-if="seg.icon" :name="seg.icon" size="1.25rem" />{{ seg.label }}<span
                      v-if="seg.harvestHint"
                      :style="{ fontSize: '14px', fontWeight: 400, marginInlineStart: '8px', color: seg.harvestHint === 'מוכן לקטיף!' ? '#d97706' : '#6a8a6a' }"
                    >{{ seg.harvestHint }}</span></div>
                  <div
                    v-for="info in getPlannedSegmentInfos(row)"
                    :key="info.vegetable"
                    style="font-size: 16px; color: #1e40af; margin-top: 3px"
                  >
                    {{ info.description }}
                  </div>
                  <div
                    v-if="formatPlantingInfo(row)"
                    style="font-size: 17px; color: #6a8a6a; margin-top: 5px"
                  >
                    {{ formatPlantingInfo(row) }}
                  </div>
                  <div
                    v-if="getRowNotes(row)"
                    style="font-size: 16px; color: #a0a8a0; margin-top: 5px; overflow-wrap: break-word; word-break: break-word"
                  >
                    {{ getRowNotes(row) }}
                  </div>
                </div>
              </div>
            </div>

            <div style="font-size: 20px; font-weight: 700; color: #2d5a3d; padding: 10px 0; margin-bottom: 10px; border-bottom: 2px solid #c8dcc8">
              ערוגות 14–27
            </div>
            <div style="display: flex; flex-direction: column; gap: 10px">
              <div
                v-for="row in sectionBRows"
                :key="row.id"
                style="
                  display: flex;
                  align-items: flex-start;
                  gap: 12px;
                  background: white;
                  border: 1px solid #e0e8e0;
                  border-radius: 12px;
                  padding: 14px 16px;
                "
              >
                <div style="
                  width: 42px;
                  height: 42px;
                  border-radius: 10px;
                  background: #ddf0dd;
                  color: #2d5a3d;
                  font-weight: 700;
                  font-size: 20px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  flex-shrink: 0;
                ">{{ row.id }}</div>
                <div style="flex: 1; min-width: 0">
                  <div
                    v-if="row.has_trellis || hasPlannedSegments(row)"
                    style="margin-bottom: 3px"
                  >
                    <span
                      v-if="row.has_trellis"
                      style="font-size: 14px; font-weight: 600; background: #fef3c7; color: #92400e; border: 1px solid #fcd34d; padding: 2px 7px; border-radius: 5px; margin-inline-end: 5px"
                    >הדליה</span>
                    <span
                      v-if="hasPlannedSegments(row)"
                      style="font-size: 14px; font-weight: 600; background: #dbeafe; color: #1e40af; border: 1px solid #93c5fd; padding: 2px 7px; border-radius: 5px"
                    >מתוכנן</span>
                  </div>
                  <div
                    v-for="(seg, si) in getSegmentLines(row)"
                    :key="si"
                    style="font-size: 20px; font-weight: 500; color: #3d4a3d; display: flex; align-items: center; gap: 6px"
                  ><VegIcon v-if="seg.icon" :name="seg.icon" size="1.25rem" />{{ seg.label }}<span
                      v-if="seg.harvestHint"
                      :style="{ fontSize: '14px', fontWeight: 400, marginInlineStart: '8px', color: seg.harvestHint === 'מוכן לקטיף!' ? '#d97706' : '#6a8a6a' }"
                    >{{ seg.harvestHint }}</span></div>
                  <div
                    v-for="info in getPlannedSegmentInfos(row)"
                    :key="info.vegetable"
                    style="font-size: 16px; color: #1e40af; margin-top: 3px"
                  >
                    {{ info.description }}
                  </div>
                  <div
                    v-if="formatPlantingInfo(row)"
                    style="font-size: 17px; color: #6a8a6a; margin-top: 5px"
                  >
                    {{ formatPlantingInfo(row) }}
                  </div>
                  <div
                    v-if="getRowNotes(row)"
                    style="font-size: 16px; color: #a0a8a0; margin-top: 5px; overflow-wrap: break-word; word-break: break-word"
                  >
                    {{ getRowNotes(row) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.export-enter-active {
  transition: opacity 0.2s ease;
}
.export-leave-active {
  transition: opacity 0.15s ease;
}
.export-enter-from,
.export-leave-to {
  opacity: 0;
}
</style>
