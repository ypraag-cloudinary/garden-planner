<script setup lang="ts">
import { computed, watch, nextTick, ref } from 'vue'
import { useRouter } from 'vue-router'
import type { RowWithSegments } from '../types/database'

const props = defineProps<{
  rows: RowWithSegments[]
  activeRowId?: number
}>()

const router = useRouter()
const scrollContainer = ref<HTMLElement | null>(null)

const leftRows = computed(() => props.rows.filter((r) => r.section === 'left'))
const rightRows = computed(() => props.rows.filter((r) => r.section === 'right'))

function hasPlanting(rowId: number): boolean {
  const row = props.rows.find((r) => r.id === rowId)
  return (row?.segments.length ?? 0) > 0
}

function goToRow(id: number) {
  router.push({ name: 'row', params: { id } })
}

function scrollToActive() {
  if (!props.activeRowId || !scrollContainer.value) return
  const el = scrollContainer.value.querySelector(`[data-row-id="${props.activeRowId}"]`)
  if (el) {
    el.scrollIntoView({ block: 'center', behavior: 'smooth' })
  }
}

watch(() => props.activeRowId, () => {
  nextTick(scrollToActive)
}, { immediate: true })
</script>

<template>
  <div class="fixed bottom-4 left-4 z-20 bg-white/92 backdrop-blur-sm rounded-xl border border-soil-200 shadow-md p-1.5 max-h-[130px] overflow-y-auto" dir="ltr" ref="scrollContainer">
    <div class="flex gap-1">
      <div class="flex flex-col gap-px">
        <button
          v-for="row in leftRows"
          :key="row.id"
          :data-row-id="row.id"
          @click="goToRow(row.id)"
          class="w-6 h-5 rounded text-[8px] font-bold flex items-center justify-center transition-colors duration-150 cursor-pointer leading-none shrink-0 tabular-nums"
          :class="[
            row.id === activeRowId
              ? 'bg-garden-500 text-white ring-2 ring-garden-300 ring-offset-1'
              : hasPlanting(row.id)
                ? 'bg-garden-200 text-garden-800 hover:bg-garden-300'
                : 'bg-soil-200 text-soil-500 hover:bg-soil-300'
          ]"
        >{{ row.id }}</button>
      </div>
      <div class="flex flex-col gap-px">
        <button
          v-for="row in rightRows"
          :key="row.id"
          :data-row-id="row.id"
          @click="goToRow(row.id)"
          class="w-6 h-5 rounded text-[8px] font-bold flex items-center justify-center transition-colors duration-150 cursor-pointer leading-none shrink-0 tabular-nums"
          :class="[
            row.id === activeRowId
              ? 'bg-garden-500 text-white ring-2 ring-garden-300 ring-offset-1'
              : hasPlanting(row.id)
                ? 'bg-garden-200 text-garden-800 hover:bg-garden-300'
                : 'bg-soil-200 text-soil-500 hover:bg-soil-300'
          ]"
        >{{ row.id }}</button>
      </div>
    </div>
  </div>
</template>
