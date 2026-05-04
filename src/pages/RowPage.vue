<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import RowDetail from '../components/RowDetail.vue'
import { useRows } from '../composables/useRows'

const props = defineProps<{
  id: string
}>()

const router = useRouter()
const { rows } = useRows()
const rowId = computed(() => parseInt(props.id, 10))
const detailRef = ref<InstanceType<typeof RowDetail> | null>(null)
const showOverflow = ref(false)

const sortedRowIds = computed(() => rows.value.map((r) => r.id).sort((a, b) => a - b))

const prevRowId = computed(() => {
  const ids = sortedRowIds.value
  const idx = ids.indexOf(rowId.value)
  if (idx <= 0) return ids[ids.length - 1]
  return ids[idx - 1]
})

const nextRowId = computed(() => {
  const ids = sortedRowIds.value
  const idx = ids.indexOf(rowId.value)
  if (idx < 0 || idx >= ids.length - 1) return ids[0]
  return ids[idx + 1]
})

function onSaved() {
  // Stay on page — toast handles feedback
}

function checkUnsavedChanges(): boolean {
  const detail = detailRef.value
  if (!detail) return false
  if (detail.editingProps) return true
  return !detail.frozenRow && (detail.segments?.length ?? 0) > 0
}

async function goBack() {
  if (checkUnsavedChanges()) {
    if (!(await detailRef.value!.requestConfirm('יש שינויים שלא נשמרו. לצאת בכל זאת?'))) return
  }
  router.push({ name: 'home' })
}

async function goToRow(id: number) {
  if (checkUnsavedChanges()) {
    if (!(await detailRef.value!.requestConfirm('יש שינויים שלא נשמרו. לצאת בכל זאת?'))) return
  }
  router.push({ name: 'row', params: { id } })
}

function handleArchive() {
  showOverflow.value = false
  detailRef.value?.doArchive()
}

function handleHistory() {
  showOverflow.value = false
  detailRef.value?.openHistory()
}

function handleMarkEmpty() {
  showOverflow.value = false
  detailRef.value?.markEmpty()
}

function handleRowSettings() {
  showOverflow.value = false
  detailRef.value?.openRowSettings()
}

const hasSegments = computed(() => (detailRef.value?.segments?.length ?? 0) > 0)
</script>

<template>
  <div class="min-h-screen">
    <div class="sticky top-14 z-20 bg-base-200/95 backdrop-blur-sm border-b border-base-300 px-4 py-3 flex items-center justify-between">
      <button
        @click="goBack"
        class="btn btn-ghost btn-sm gap-1.5 text-primary"
      >
        <svg class="w-4 h-4 rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
        </svg>
        חזרה
      </button>
      <div class="flex items-center gap-1">
        <button
          @click="goToRow(prevRowId)"
          class="btn btn-ghost btn-square btn-sm"
          title="ערוגה קודמת"
        >
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </button>
        <h1 class="text-base font-semibold text-base-content min-w-[4.5rem] text-center">ערוגה {{ rowId }}</h1>
        <button
          @click="goToRow(nextRowId)"
          class="btn btn-ghost btn-square btn-sm"
          title="ערוגה הבאה"
        >
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
      </div>
      <button
        @click="showOverflow = true"
        class="btn btn-ghost btn-square btn-sm"
        title="אפשרויות נוספות"
      >
        <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4" />
        </svg>
      </button>
    </div>

    <div class="p-4">
      <RowDetail ref="detailRef" :row-id="rowId" @saved="onSaved" />
    </div>

    <!-- Overflow bottom-sheet menu -->
    <Teleport to="body">
      <Transition name="sheet">
        <div
          v-if="showOverflow"
          class="modal modal-open modal-bottom sm:modal-middle"
          @click.self="showOverflow = false"
        >
          <div class="modal-box max-w-sm p-0">
            <div class="px-4 pt-4 pb-2 flex items-center justify-between">
              <h3 class="font-semibold text-base-content text-sm">אפשרויות</h3>
              <button
                @click="showOverflow = false"
                class="btn btn-ghost btn-circle btn-sm"
              >✕</button>
            </div>
            <ul class="menu w-full px-2 pb-3">
              <li>
                <button @click="handleHistory" class="flex items-center gap-3 py-3">
                  <svg class="w-5 h-5 text-base-content/60" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span>היסטוריית שתילה</span>
                </button>
              </li>
              <li>
                <button @click="handleRowSettings" class="flex items-center gap-3 py-3">
                  <svg class="w-5 h-5 text-base-content/60" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span>הגדרות ערוגה</span>
                </button>
              </li>
              <li v-if="hasSegments" class="border-t border-base-200 mt-1 pt-1">
                <button @click="handleArchive" class="flex items-center gap-3 py-3 text-secondary">
                  <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
                  </svg>
                  <span>העבר לארכיון</span>
                </button>
              </li>
              <li v-if="hasSegments">
                <button @click="handleMarkEmpty" class="flex items-center gap-3 py-3 text-error">
                  <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                  <span>סמן כריקה</span>
                </button>
              </li>
            </ul>
          </div>
          <div class="modal-backdrop" @click="showOverflow = false"></div>
        </div>
      </Transition>
    </Teleport>
  </div>
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
