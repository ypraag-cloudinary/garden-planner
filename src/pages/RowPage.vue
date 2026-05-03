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
  detailRef.value?.doArchive()
}

function handleHistory() {
  detailRef.value?.openHistory()
}

function handleMarkEmpty() {
  detailRef.value?.markEmpty()
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
      <div class="flex items-center gap-1">
        <button
          v-if="hasSegments"
          @click="handleMarkEmpty"
          class="btn btn-ghost btn-square btn-sm text-error"
          title="סמן כריקה"
        >
          <svg class="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
        </button>
        <button
          v-if="hasSegments"
          @click="handleArchive"
          class="btn btn-ghost btn-square btn-sm text-secondary"
          title="העבר לארכיון"
        >
          <svg class="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
          </svg>
        </button>
        <button
          @click="handleHistory"
          class="btn btn-ghost btn-square btn-sm"
          title="היסטוריה"
        >
          <svg class="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </button>
      </div>
    </div>

    <div class="p-4">
      <RowDetail ref="detailRef" :row-id="rowId" @saved="onSaved" />
    </div>
  </div>
</template>
