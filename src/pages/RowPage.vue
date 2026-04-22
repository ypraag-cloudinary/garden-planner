<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import RowDetail from '../components/RowDetail.vue'

const props = defineProps<{
  id: string
}>()

const router = useRouter()
const rowId = computed(() => parseInt(props.id, 10))
const detailRef = ref<InstanceType<typeof RowDetail> | null>(null)

function onSaved() {
  // Stay on page — toast handles feedback
}

function goBack() {
  router.push({ name: 'home' })
}

function handleArchive() {
  detailRef.value?.doArchive()
}

function handleHistory() {
  detailRef.value?.openHistory()
}

const hasSegments = computed(() => (detailRef.value?.segments?.length ?? 0) > 0)
</script>

<template>
  <div class="min-h-screen">
    <div class="sticky top-14 z-20 bg-soil-50/95 backdrop-blur-sm border-b border-soil-200 px-4 py-3 flex items-center justify-between">
      <button
        @click="goBack"
        class="flex items-center gap-1.5 text-garden-600 hover:text-garden-700 text-sm font-medium cursor-pointer py-1 -my-1 transition-colors duration-150"
      >
        <svg class="w-4 h-4 rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
        </svg>
        חזרה
      </button>
      <h1 class="text-base font-semibold text-soil-800">ערוגה {{ rowId }}</h1>
      <div class="flex items-center gap-1">
        <button
          v-if="hasSegments"
          @click="handleArchive"
          class="w-9 h-9 rounded-lg text-harvest-600 hover:bg-harvest-50 flex items-center justify-center transition-colors duration-150 cursor-pointer"
          title="העבר לארכיון"
        >
          <svg class="w-4.5 h-4.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
          </svg>
        </button>
        <button
          @click="handleHistory"
          class="w-9 h-9 rounded-lg text-soil-500 hover:bg-soil-100 flex items-center justify-center transition-colors duration-150 cursor-pointer"
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
