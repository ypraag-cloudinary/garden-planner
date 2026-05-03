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
      <div class="text-center text-base-content/50">
        <span class="loading loading-dots loading-lg text-primary"></span>
        <div class="text-sm font-medium mt-2">טוען ערוגות...</div>
      </div>
    </div>

    <div v-else-if="error" class="p-6 text-center">
      <div role="alert" class="alert alert-error">
        <span>{{ error }}</span>
      </div>
      <button
        @click="fetchRows"
        class="btn btn-error btn-outline btn-sm mt-3"
      >
        נסה שוב
      </button>
    </div>

    <div v-else class="pt-5">
      <RowList :rows="rows" />
    </div>
  </div>
</template>
