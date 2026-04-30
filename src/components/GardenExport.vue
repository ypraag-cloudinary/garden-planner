<script setup lang="ts">
import { ref, computed, watch, nextTick, onMounted } from 'vue'
import { toPng } from 'html-to-image'
import type { RowWithSegments } from '../types/database'
import { useVegetables } from '../composables/useVegetables'

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

function getVegetableNames(row: RowWithSegments): string {
  if (row.segments.length === 0) return 'ריקה'
  const planted = row.segments.filter((s) => s.vegetable !== EMPTY_VEGETABLE)
  if (planted.length === 0) return 'ריקה'
  return planted.map((s) => {
    const icon = getVegetableIcon(s.vegetable)
    return icon ? `${icon} ${s.vegetable}` : s.vegetable
  }).join(', ')
}

function getRowNotes(row: RowWithSegments): string {
  const parts: string[] = []
  if (row.notes?.trim()) parts.push(row.notes.trim())
  for (const seg of row.segments) {
    if (seg.notes?.trim()) parts.push(`${seg.vegetable}: ${seg.notes.trim()}`)
  }
  return parts.join(' · ')
}

async function generateImage() {
  if (!renderTarget.value) return
  generating.value = true
  try {
    await nextTick()
    const dataUrl = await toPng(renderTarget.value, {
      pixelRatio: 2,
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
        class="fixed inset-0 z-50 bg-soil-900/85 flex flex-col"
        @click.self="handleClose"
      >
        <div class="flex items-center justify-between px-4 py-3 bg-soil-900/60">
          <span class="text-white/90 font-medium text-sm">ייצוא מפת גינה</span>
          <div class="flex items-center gap-1.5">
            <button
              v-if="previewUrl && canShare"
              @click="shareImage"
              class="px-4 h-10 rounded-xl bg-white/15 text-white text-sm font-medium flex items-center justify-center gap-1.5 hover:bg-white/25 active:scale-95 cursor-pointer transition-all duration-150"
            >שיתוף</button>
            <button
              v-if="previewUrl"
              @click="downloadImage"
              class="px-4 h-10 rounded-xl bg-white/15 text-white text-sm font-medium flex items-center justify-center gap-1.5 hover:bg-white/25 active:scale-95 cursor-pointer transition-all duration-150"
            >הורדה</button>
            <button
              @click="handleClose"
              class="w-10 h-10 rounded-xl bg-white/15 text-white flex items-center justify-center hover:bg-white/25 active:scale-95 mr-1 cursor-pointer transition-all duration-150"
            >✕</button>
          </div>
        </div>

        <div class="flex-1 overflow-auto flex items-start justify-center p-4">
          <div v-if="generating" class="text-white/80 text-sm mt-20 animate-pulse">
            יוצר תמונה...
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
              width: 400px;
              padding: 24px;
              background: #f7faf7;
              font-family: Rubik, system-ui, sans-serif;
              color: #3d4a3d;
              line-height: 1.5;
            "
          >
            <div style="text-align: center; margin-bottom: 20px">
              <div style="font-size: 22px; font-weight: 600; color: #2d5a3d">
                🌱 גינה קהילתית
              </div>
              <div style="font-size: 13px; color: #8a9a8a; margin-top: 4px">
                {{ todayFormatted }}
              </div>
            </div>

            <div style="font-size: 14px; font-weight: 700; color: #2d5a3d; padding: 8px 0; margin-bottom: 8px; border-bottom: 2px solid #c8dcc8">
              ערוגות 1–13
            </div>
            <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 20px">
              <div
                v-for="row in sectionARows"
                :key="row.id"
                style="
                  display: flex;
                  align-items: flex-start;
                  gap: 10px;
                  background: white;
                  border: 1px solid #e0e8e0;
                  border-radius: 10px;
                  padding: 10px 12px;
                "
              >
                <div style="
                  width: 34px;
                  height: 34px;
                  border-radius: 8px;
                  background: #ddf0dd;
                  color: #2d5a3d;
                  font-weight: 700;
                  font-size: 15px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  flex-shrink: 0;
                ">{{ row.id }}</div>
                <div style="flex: 1; min-width: 0; overflow: hidden">
                  <div style="font-size: 15px; font-weight: 500; color: #3d4a3d; overflow-wrap: break-word; word-break: break-word; line-height: 1.6">
                    {{ getVegetableNames(row) }}
                    <span
                      v-if="row.has_trellis"
                      style="font-size: 11px; font-weight: 600; background: #fef3c7; color: #92400e; border: 1px solid #fcd34d; padding: 1px 5px; border-radius: 4px; margin-inline-start: 4px; vertical-align: middle"
                    >הדליה</span>
                  </div>
                  <div
                    v-if="formatPlantingInfo(row)"
                    style="font-size: 13px; color: #6a8a6a; margin-top: 4px; line-height: 1.4"
                  >
                    {{ formatPlantingInfo(row) }}
                  </div>
                  <div
                    v-if="getRowNotes(row)"
                    style="font-size: 12px; color: #a0a8a0; margin-top: 4px; overflow-wrap: break-word; word-break: break-word; line-height: 1.4"
                  >
                    {{ getRowNotes(row) }}
                  </div>
                </div>
              </div>
            </div>

            <div style="font-size: 14px; font-weight: 700; color: #2d5a3d; padding: 8px 0; margin-bottom: 8px; border-bottom: 2px solid #c8dcc8">
              ערוגות 14–27
            </div>
            <div style="display: flex; flex-direction: column; gap: 8px">
              <div
                v-for="row in sectionBRows"
                :key="row.id"
                style="
                  display: flex;
                  align-items: flex-start;
                  gap: 10px;
                  background: white;
                  border: 1px solid #e0e8e0;
                  border-radius: 10px;
                  padding: 10px 12px;
                "
              >
                <div style="
                  width: 34px;
                  height: 34px;
                  border-radius: 8px;
                  background: #ddf0dd;
                  color: #2d5a3d;
                  font-weight: 700;
                  font-size: 15px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  flex-shrink: 0;
                ">{{ row.id }}</div>
                <div style="flex: 1; min-width: 0; overflow: hidden">
                  <div style="font-size: 15px; font-weight: 500; color: #3d4a3d; overflow-wrap: break-word; word-break: break-word; line-height: 1.6">
                    {{ getVegetableNames(row) }}
                    <span
                      v-if="row.has_trellis"
                      style="font-size: 11px; font-weight: 600; background: #fef3c7; color: #92400e; border: 1px solid #fcd34d; padding: 1px 5px; border-radius: 4px; margin-inline-start: 4px; vertical-align: middle"
                    >הדליה</span>
                  </div>
                  <div
                    v-if="formatPlantingInfo(row)"
                    style="font-size: 13px; color: #6a8a6a; margin-top: 4px; line-height: 1.4"
                  >
                    {{ formatPlantingInfo(row) }}
                  </div>
                  <div
                    v-if="getRowNotes(row)"
                    style="font-size: 12px; color: #a0a8a0; margin-top: 4px; overflow-wrap: break-word; word-break: break-word; line-height: 1.4"
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
