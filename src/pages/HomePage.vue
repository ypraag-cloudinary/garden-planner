<script setup lang="ts">
import { onMounted } from 'vue'
import { useRows } from '../composables/useRows'
import RowList from '../components/RowList.vue'

const { rows, loading, error, fetchRows } = useRows()

onMounted(fetchRows)
</script>

<template>
  <div class="pb-8">
    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="text-center text-soil-400">
        <div class="text-3xl mb-3 animate-pulse">🌱</div>
        <div class="text-sm font-medium">טוען ערוגות...</div>
      </div>
    </div>

    <div v-else-if="error" class="p-6 text-center">
      <div class="bg-danger-50 border border-danger-100 rounded-xl p-4 text-danger-600 text-sm">
        {{ error }}
      </div>
      <button
        @click="fetchRows"
        class="mt-3 px-5 py-2.5 rounded-lg bg-danger-100 text-danger-600 text-sm font-medium hover:bg-danger-50 transition-colors duration-150 cursor-pointer"
      >
        נסה שוב
      </button>
    </div>

    <div v-else class="pt-5">
      <RowList :rows="rows" />
    </div>
  </div>
</template>
