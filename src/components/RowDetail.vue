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

const confirmDialog = ref<{ message: string; onConfirm: () => void } | null>(null)

function requestConfirm(message: string): Promise<boolean> {
  return new Promise((resolve) => {
    confirmDialog.value = {
      message,
      onConfirm: () => {
        confirmDialog.value = null
        resolve(true)
      },
    }
    watch(confirmDialog, (v) => {
      if (!v) resolve(false)
    }, { once: true })
  })
}

function dismissConfirm() {
  confirmDialog.value = null
}

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

async function cancelEdit() {
  frozenRow.value = true
  editingProps.value = false
  const data = await fetchSegments(props.rowId)
  segments.value = data
  if (row.value) {
    localRow.value = {
      length_m: row.value.length_m,
      drip_spacing_cm: row.value.drip_spacing_cm,
      has_trellis: row.value.has_trellis,
      notes: row.value.notes,
    }
  }
}

async function markEmpty() {
  if (segments.value.length === 0) return
  if (!(await requestConfirm('פעולה זו תסיר את כל השתילות מהערוגה. להמשיך?'))) return
  try {
    await archiveRow(props.rowId)
    segments.value = []
    frozenRow.value = false
    history.value = await fetchHistory(props.rowId)
    await fetchRows()
    showToast('הערוגה סומנה כריקה', 'success')
    emit('saved')
  } catch {
    showToast('שגיאה בעדכון', 'error')
  }
}

async function doArchive() {
  if (segments.value.length === 0) return
  if (!(await requestConfirm('פעולה זו תאפס את כל השדות ותעביר את השתילה הנוכחית לארכיון. להמשיך?'))) return
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
  requestConfirm,
  dismissConfirm,
})

onMounted(load)

watch(() => props.rowId, load)
</script>

<template>
  <div v-if="loading" class="p-8 text-center text-base-content/50">
    <span class="loading loading-dots loading-lg text-primary"></span>
    <div class="text-sm font-medium mt-2">טוען...</div>
  </div>
  <div v-else-if="row" class="space-y-4">
    <Teleport to="body">
      <Transition name="toast">
        <div v-if="toast" class="toast toast-top toast-center z-50">
          <div class="alert" :class="toast.type === 'success' ? 'alert-success' : 'alert-error'">
            <span>{{ toast.message }}</span>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- Row Properties -->
    <div class="card bg-base-100 border border-base-300">
      <div class="card-body p-4">
        <div class="flex items-center justify-between mb-3">
          <h3 class="font-semibold text-base-content">פרטי ערוגה</h3>
          <button
            type="button"
            @click="editingProps = !editingProps"
            class="btn btn-ghost btn-xs text-primary"
          >
            {{ editingProps ? 'סגור' : 'ערוך' }}
          </button>
        </div>

        <div v-if="!editingProps" class="flex flex-wrap gap-2 text-sm">
          <span class="badge badge-neutral badge-outline">{{ row.length_m }} מ׳</span>
          <span class="badge badge-neutral badge-outline">טפטוף כל {{ row.drip_spacing_cm }} ס״מ</span>
          <span v-if="row.has_trellis" class="badge badge-warning badge-outline">קיימת הדליה</span>
        </div>

        <div v-else class="space-y-4">
          <div>
            <label class="label text-xs font-medium">אורך ערוגה</label>
            <div class="join w-full">
              <button
                type="button"
                @click="localRow.length_m = 5"
                class="btn join-item flex-1"
                :class="localRow.length_m === 5 ? 'btn-primary' : 'btn-outline'"
              >5 מ׳</button>
              <button
                type="button"
                @click="localRow.length_m = 10"
                class="btn join-item flex-1"
                :class="localRow.length_m === 10 ? 'btn-primary' : 'btn-outline'"
              >10 מ׳</button>
            </div>
          </div>

          <div>
            <label class="label text-xs font-medium">מרחק טפטוף</label>
            <div class="join w-full">
              <button
                type="button"
                @click="localRow.drip_spacing_cm = 20"
                class="btn join-item flex-1"
                :class="localRow.drip_spacing_cm === 20 ? 'btn-primary' : 'btn-outline'"
              >20 ס״מ</button>
              <button
                type="button"
                @click="localRow.drip_spacing_cm = 30"
                class="btn join-item flex-1"
                :class="localRow.drip_spacing_cm === 30 ? 'btn-primary' : 'btn-outline'"
              >30 ס״מ</button>
            </div>
          </div>

          <div>
            <label class="flex items-center gap-2.5 cursor-pointer py-1">
              <input
                type="checkbox"
                :checked="localRow.has_trellis"
                @change="localRow.has_trellis = ($event.target as HTMLInputElement).checked"
                class="checkbox checkbox-primary checkbox-sm"
              />
              <span class="text-sm text-base-content/80">עמודי הדליה</span>
            </label>
          </div>

          <div>
            <label class="label text-xs font-medium">הערות ערוגה</label>
            <textarea
              v-model="localRow.notes"
              rows="2"
              class="textarea textarea-bordered w-full resize-none"
              placeholder="הערות..."
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Quick actions -->
    <div v-if="segments.length > 0" class="flex items-center justify-end gap-2">
      <template v-if="frozenRow">
        <button
          @click="frozenRow = false"
          class="btn btn-outline btn-primary btn-sm gap-1.5"
        >
          <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
          </svg>
          עריכה
        </button>
      </template>
      <template v-else>
        <button
          @click="cancelEdit"
          class="btn btn-ghost btn-sm"
        >
          ביטול
        </button>
        <button
          @click="save"
          :disabled="saving || !canSave"
          class="btn btn-primary btn-sm"
        >
          {{ saving ? 'שומר...' : 'שמור שינויים' }}
        </button>
      </template>
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
      class="btn btn-outline btn-block border-dashed"
      :class="canAddSegment ? 'btn-primary' : 'btn-disabled'"
    >
      + הוסף חלק
    </button>

    <div v-if="segments.length === 0" class="text-center py-10 text-base-content/40">
      <div class="text-3xl mb-2">🌱</div>
      <div class="text-sm">הערוגה ריקה — הוסף חלק כדי להתחיל לשתול</div>
    </div>


    <!-- History modal -->
    <Teleport to="body">
      <Transition name="sheet">
        <div
          v-if="showHistory"
          class="modal modal-open modal-bottom sm:modal-middle"
          @click.self="showHistory = false"
        >
          <div class="modal-box max-h-[85vh] flex flex-col">
            <div class="flex items-center justify-between mb-4">
              <h3 class="font-semibold text-base-content text-lg">היסטוריית שתילה</h3>
              <button
                @click="showHistory = false"
                class="btn btn-ghost btn-circle btn-sm"
              >✕</button>
            </div>
            <div class="flex-1 overflow-y-auto">
              <div v-if="groupedHistory.length === 0" class="p-8 text-center text-base-content/40 text-sm">
                אין היסטוריה לערוגה זו
              </div>
              <div v-else class="divide-y divide-base-200">
                <div v-for="group in groupedHistory" :key="group.date" class="py-4">
                  <div class="text-xs text-base-content/40 mb-2">ארכיון מ־{{ formatDate(group.date) }}</div>
                  <div class="flex flex-wrap gap-2">
                    <div
                      v-for="item in group.items"
                      :key="item.id"
                      class="badge badge-lg badge-neutral badge-outline gap-1"
                    >
                      <span class="font-medium">{{ item.vegetable }}</span>
                      <span v-if="item.planted_at" class="text-xs opacity-60">
                        ({{ formatDate(item.planted_at) }})
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-backdrop" @click="showHistory = false"></div>
        </div>
      </Transition>
    </Teleport>

    <!-- Confirm dialog -->
    <Teleport to="body">
      <Transition name="sheet">
        <div
          v-if="confirmDialog"
          class="modal modal-open modal-bottom sm:modal-middle"
          @click.self="dismissConfirm"
        >
          <div class="modal-box max-w-sm">
            <p class="text-sm text-base-content/80 text-center leading-relaxed">{{ confirmDialog.message }}</p>
            <div class="modal-action justify-center">
              <button
                @click="dismissConfirm"
                class="btn btn-ghost flex-1"
              >ביטול</button>
              <button
                @click="confirmDialog.onConfirm()"
                class="btn btn-error flex-1"
              >אישור</button>
            </div>
          </div>
          <div class="modal-backdrop" @click="dismissConfirm"></div>
        </div>
      </Transition>
    </Teleport>

    <!-- Allocation warning -->
    <p
      v-if="segments.length > 0 && totalAllocatedPct < 98 && !frozenRow"
      class="text-xs text-error text-center"
    >
      יש לחלק את כל אורך הערוגה לפני שמירה
    </p>
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
