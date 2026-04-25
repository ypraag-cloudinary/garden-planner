<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import type { GardenRow, Segment, SegmentHistory } from '../types/database'
import { useSegments } from '../composables/useSegments'
import { useRows } from '../composables/useRows'
import { useArchive } from '../composables/useArchive'
import SegmentEditor from './SegmentEditor.vue'
import SegmentBar from './SegmentBar.vue'

const props = defineProps<{
  rowId: number
}>()

const emit = defineEmits<{
  saved: []
}>()

const { fetchRows, rows, updateRow } = useRows()
const { saving, fetchSegments, saveAllSegments } = useSegments()
const { archiving, archiveRow, fetchHistory } = useArchive()

const segments = ref<Segment[]>([])
const history = ref<SegmentHistory[]>([])
const showHistory = ref(false)
const loading = ref(true)
const toast = ref<{ message: string; type: 'success' | 'error' } | null>(null)
const editingProps = ref(false)
const frozenRow = ref(false)

const row = computed(() => rows.value.find((r) => r.id === props.rowId))

const localRow = ref<Partial<GardenRow>>({})

const totalAllocatedPct = computed(() => {
  if (!row.value) return 0
  return segments.value.reduce((sum, s) => {
    if (!s.length_m) return sum
    return sum + Math.round((s.length_m / row.value!.length_m) * 100)
  }, 0)
})

const canAddSegment = computed(() => {
  if (frozenRow.value) return false
  if (segments.value.length >= 3) return false
  return totalAllocatedPct.value < 100
})

const allVegetablesSelected = computed(() => {
  return segments.value.length > 0 && segments.value.every((s) => s.vegetable.trim())
})

const canSave = computed(() => {
  if (segments.value.length === 0) return false
  if (!allVegetablesSelected.value) return false
  if (totalAllocatedPct.value < 98) return false
  return true
})

function remainingPctForSegment(index: number) {
  if (!row.value) return 100
  const otherSum = segments.value.reduce((sum, s, i) => {
    if (i === index || !s.length_m) return sum
    return sum + Math.round((s.length_m / row.value!.length_m) * 100)
  }, 0)
  return Math.max(0, 100 - otherSum)
}

const remainingFraction = computed(() => {
  if (!row.value) return 1
  const used = segments.value.reduce((sum, s) => sum + (s.length_m ?? 0), 0)
  return Math.max(0, row.value.length_m - used) / row.value.length_m
})

const groupedHistory = computed(() => {
  const groups = new Map<string, SegmentHistory[]>()
  for (const h of history.value) {
    const key = h.archived_at
    const list = groups.get(key) ?? []
    list.push(h)
    groups.set(key, list)
  }
  return [...groups.entries()].map(([date, items]) => ({ date, items }))
})

async function load() {
  loading.value = true
  try {
    if (rows.value.length === 0) await fetchRows()
    const data = await fetchSegments(props.rowId)
    segments.value = data
    frozenRow.value = data.length > 0 && data.every((s) => !!s.id)
    if (row.value) {
      localRow.value = {
        length_m: row.value.length_m,
        drip_spacing_cm: row.value.drip_spacing_cm,
        has_trellis: row.value.has_trellis,
        notes: row.value.notes,
      }
    }
  } finally {
    loading.value = false
  }
}

async function openHistory() {
  showHistory.value = true
  if (history.value.length === 0) {
    try {
      history.value = await fetchHistory(props.rowId)
    } catch {
      showToast('שגיאה בטעינת היסטוריה', 'error')
    }
  }
}

function addSegment() {
  if (!canAddSegment.value || !row.value) return
  const remainingM = Math.round(remainingFraction.value * row.value.length_m * 10) / 10
  const newSeg: Segment = {
    id: '',
    row_id: props.rowId,
    position: segments.value.length + 1,
    vegetable: '',
    planted_at: new Date().toISOString().split('T')[0],
    length_m: remainingM > 0 ? remainingM : null,
    notes: null,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  }
  segments.value.push(newSeg)
}

function removeSegment(index: number) {
  segments.value.splice(index, 1)
  segments.value.forEach((s, i) => { s.position = i + 1 })
}

function updateSegment(index: number, updated: Segment) {
  segments.value[index] = updated
}

function showToast(message: string, type: 'success' | 'error') {
  toast.value = { message, type }
  setTimeout(() => { toast.value = null }, 3000)
}

async function save() {
  if (!canSave.value) return
  try {
    const valid = segments.value.filter((s) => s.vegetable.trim())
    valid.forEach((s, i) => { s.position = i + 1 })

    if (editingProps.value && row.value) {
      await updateRow(props.rowId, {
        length_m: localRow.value.length_m,
        drip_spacing_cm: localRow.value.drip_spacing_cm,
        has_trellis: localRow.value.has_trellis,
        notes: localRow.value.notes,
      })
      editingProps.value = false
    }

    await saveAllSegments(props.rowId, valid)
    const freshSegments = await fetchSegments(props.rowId)
    segments.value = freshSegments
    frozenRow.value = freshSegments.length > 0 && freshSegments.every((s) => !!s.id)
    await fetchRows()
    showToast('נשמר בהצלחה', 'success')
    emit('saved')
  } catch (e) {
    console.error('SAVE ERROR:', e)
    showToast('שגיאה בשמירה', 'error')
  }
}

async function markEmpty() {
  if (segments.value.length === 0) return
  if (!confirm('פעולה זו תסיר את כל השתילות מהערוגה. להמשיך?')) return
  try {
    await saveAllSegments(props.rowId, [])
    segments.value = []
    frozenRow.value = false
    await fetchRows()
    showToast('הערוגה סומנה כריקה', 'success')
    emit('saved')
  } catch {
    showToast('שגיאה בעדכון', 'error')
  }
}

async function doArchive() {
  if (segments.value.length === 0) return
  if (!confirm('פעולה זו תאפס את כל השדות ותעביר את השתילה הנוכחית לארכיון. להמשיך?')) return
  try {
    await archiveRow(props.rowId)
    segments.value = []
    frozenRow.value = false
    history.value = await fetchHistory(props.rowId)
    showHistory.value = true
    await fetchRows()
    showToast('הועבר לארכיון', 'success')
  } catch {
    showToast('שגיאה בארכיון', 'error')
  }
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('he-IL')
}

defineExpose({
  doArchive,
  openHistory,
  markEmpty,
  segments,
  frozenRow,
  editingProps,
  archiving,
})

onMounted(load)

watch(() => props.rowId, load)
</script>

<template>
  <div v-if="loading" class="p-8 text-center text-soil-400">
    <div class="text-2xl mb-2 animate-pulse">🌱</div>
    <div class="text-sm font-medium">טוען...</div>
  </div>
  <div v-else-if="row" class="space-y-4">
    <Teleport to="body">
      <Transition name="toast">
        <div
          v-if="toast"
          class="fixed top-4 left-1/2 -translate-x-1/2 z-50 px-5 py-2.5 rounded-xl text-sm font-medium shadow-lg"
          :class="toast.type === 'success' ? 'bg-garden-600 text-white' : 'bg-danger-600 text-white'"
        >
          {{ toast.message }}
        </div>
      </Transition>
    </Teleport>

    <!-- Row Properties -->
    <div class="bg-white rounded-xl border border-soil-200 p-4">
      <div class="flex items-center justify-between mb-3">
        <h3 class="font-semibold text-soil-800">פרטי ערוגה</h3>
        <button
          type="button"
          @click="editingProps = !editingProps"
          class="text-xs font-medium text-garden-600 hover:text-garden-700 cursor-pointer py-1 px-2 rounded-lg hover:bg-garden-50 transition-colors duration-150"
        >
          {{ editingProps ? 'סגור' : 'ערוך' }}
        </button>
      </div>

      <div v-if="!editingProps" class="flex flex-wrap gap-2 text-sm text-soil-600">
        <span class="bg-soil-100 px-2.5 py-1 rounded-lg">{{ row.length_m }} מ׳</span>
        <span class="bg-soil-100 px-2.5 py-1 rounded-lg">טפטוף כל {{ row.drip_spacing_cm }} ס״מ</span>
        <span v-if="row.has_trellis" class="bg-harvest-50 text-harvest-700 border border-harvest-200 px-2.5 py-1 rounded-lg">קיימת הדליה</span>
      </div>

      <div v-else class="space-y-4">
        <div>
          <label class="block text-xs font-medium text-soil-500 mb-2">אורך ערוגה</label>
          <div class="flex gap-2">
            <button
              type="button"
              @click="localRow.length_m = 5"
              class="flex-1 py-2.5 rounded-lg text-sm font-medium border transition-all duration-150 cursor-pointer"
              :class="localRow.length_m === 5
                ? 'border-garden-500 bg-garden-50 text-garden-700'
                : 'border-soil-200 bg-white text-soil-600 hover:border-soil-300 hover:bg-soil-50'"
            >5 מ׳</button>
            <button
              type="button"
              @click="localRow.length_m = 10"
              class="flex-1 py-2.5 rounded-lg text-sm font-medium border transition-all duration-150 cursor-pointer"
              :class="localRow.length_m === 10
                ? 'border-garden-500 bg-garden-50 text-garden-700'
                : 'border-soil-200 bg-white text-soil-600 hover:border-soil-300 hover:bg-soil-50'"
            >10 מ׳</button>
          </div>
        </div>

        <div>
          <label class="block text-xs font-medium text-soil-500 mb-2">מרחק טפטוף</label>
          <div class="flex gap-2">
            <button
              type="button"
              @click="localRow.drip_spacing_cm = 20"
              class="flex-1 py-2.5 rounded-lg text-sm font-medium border transition-all duration-150 cursor-pointer"
              :class="localRow.drip_spacing_cm === 20
                ? 'border-garden-500 bg-garden-50 text-garden-700'
                : 'border-soil-200 bg-white text-soil-600 hover:border-soil-300 hover:bg-soil-50'"
            >20 ס״מ</button>
            <button
              type="button"
              @click="localRow.drip_spacing_cm = 30"
              class="flex-1 py-2.5 rounded-lg text-sm font-medium border transition-all duration-150 cursor-pointer"
              :class="localRow.drip_spacing_cm === 30
                ? 'border-garden-500 bg-garden-50 text-garden-700'
                : 'border-soil-200 bg-white text-soil-600 hover:border-soil-300 hover:bg-soil-50'"
            >30 ס״מ</button>
          </div>
        </div>

        <div>
          <label class="flex items-center gap-2.5 cursor-pointer py-1">
            <input
              type="checkbox"
              :checked="localRow.has_trellis"
              @change="localRow.has_trellis = ($event.target as HTMLInputElement).checked"
              class="w-4.5 h-4.5 rounded border-soil-300 text-garden-600 focus:ring-garden-500"
            />
            <span class="text-sm text-soil-700">עמודי הדליה</span>
          </label>
        </div>

        <div>
          <label class="block text-xs font-medium text-soil-500 mb-1.5">הערות ערוגה</label>
          <textarea
            v-model="localRow.notes"
            rows="2"
            class="w-full rounded-lg border border-soil-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-garden-500 focus:border-garden-500 resize-none placeholder:text-soil-300"
            placeholder="הערות..."
          />
        </div>
      </div>
    </div>

    <!-- Segment bar overview -->
    <div class="px-1">
      <SegmentBar :segments="segments" :row-length="row.length_m" />
    </div>

    <!-- Segments -->
    <div class="space-y-3">
      <SegmentEditor
        v-for="(seg, i) in segments"
        :key="seg.id || `new-${i}`"
        :segment="seg"
        :index="i"
        :row-length="row.length_m"
        :remaining-pct="remainingPctForSegment(i)"
        :readonly="frozenRow"
        @update:segment="updateSegment(i, $event)"
        @remove="removeSegment(i)"
      />
    </div>

    <!-- Add segment -->
    <button
      v-if="segments.length < 3 && !frozenRow"
      type="button"
      @click="addSegment"
      :disabled="!canAddSegment"
      class="w-full py-3.5 rounded-xl border border-dashed text-sm font-medium transition-all duration-150 cursor-pointer"
      :class="canAddSegment
        ? 'border-soil-300 text-soil-500 hover:border-garden-400 hover:text-garden-600 hover:bg-garden-50/50'
        : 'border-soil-200 text-soil-300 cursor-not-allowed'"
    >
      + הוסף חלק
    </button>

    <div v-if="segments.length === 0" class="text-center py-10 text-soil-400">
      <div class="text-3xl mb-2">🌱</div>
      <div class="text-sm">הערוגה ריקה — הוסף חלק כדי להתחיל לשתול</div>
    </div>

    <!-- Unfreeze button (inline, when frozen) -->
    <button
      v-if="frozenRow && segments.length > 0"
      @click="frozenRow = false"
      class="w-full py-2.5 rounded-xl border border-garden-200 bg-garden-50 text-garden-700 text-sm font-medium hover:bg-garden-100 transition-colors duration-150 cursor-pointer flex items-center justify-center gap-2"
    >
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
      </svg>
      ערוך שתילה
    </button>

    <!-- Mark row as empty -->
    <button
      v-if="segments.length > 0"
      @click="markEmpty"
      class="w-full py-2.5 rounded-xl border border-soil-300 bg-soil-50 text-soil-600 text-sm font-medium hover:bg-soil-100 transition-colors duration-150 cursor-pointer flex items-center justify-center gap-2"
    >
      <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
      </svg>
      סמן כריקה
    </button>

    <!-- History modal -->
    <Teleport to="body">
      <Transition name="sheet">
        <div
          v-if="showHistory"
          class="fixed inset-0 z-50 bg-black/40 flex items-end sm:items-center justify-center"
          @click.self="showHistory = false"
        >
          <div class="bg-white w-full max-w-lg rounded-t-2xl sm:rounded-2xl max-h-[85vh] flex flex-col overflow-hidden">
            <div class="px-4 pt-4 pb-3 border-b border-soil-100 flex items-center justify-between">
              <h3 class="font-semibold text-soil-800">היסטוריית שתילה</h3>
              <button
                @click="showHistory = false"
                class="w-9 h-9 rounded-full hover:bg-soil-100 flex items-center justify-center text-soil-500 cursor-pointer transition-colors duration-150"
              >✕</button>
            </div>
            <div class="flex-1 overflow-y-auto">
              <div v-if="groupedHistory.length === 0" class="p-8 text-center text-soil-400 text-sm">
                אין היסטוריה לערוגה זו
              </div>
              <div v-else class="divide-y divide-soil-100">
                <div v-for="group in groupedHistory" :key="group.date" class="p-4">
                  <div class="text-xs text-soil-400 mb-2">ארכיון מ־{{ formatDate(group.date) }}</div>
                  <div class="flex flex-wrap gap-2">
                    <div
                      v-for="item in group.items"
                      :key="item.id"
                      class="bg-soil-50 rounded-lg px-3 py-1.5 text-sm"
                    >
                      <span class="font-medium text-soil-700">{{ item.vegetable }}</span>
                      <span v-if="item.planted_at" class="text-soil-400 text-xs mr-1">
                        ({{ formatDate(item.planted_at) }})
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- Save button -->
    <div class="sticky bottom-0 bg-soil-50/95 backdrop-blur-sm py-3 -mx-4 px-4 border-t border-soil-200">
      <p
        v-if="segments.length > 0 && totalAllocatedPct < 98 && !frozenRow"
        class="text-xs text-danger-500 mb-2 text-center"
      >
        יש לחלק את כל אורך הערוגה לפני שמירה
      </p>
      <button
        v-if="!frozenRow"
        @click="save"
        :disabled="saving || !canSave"
        class="w-full py-3.5 rounded-xl bg-garden-600 text-white font-medium hover:bg-garden-700 active:scale-[0.99] disabled:opacity-50 transition-all duration-150 text-sm cursor-pointer"
      >
        {{ saving ? 'שומר...' : 'שמור שינויים' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}
.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translate(-50%, -0.75rem);
}
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
