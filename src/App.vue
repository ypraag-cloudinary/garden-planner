<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import AppLayout from './components/AppLayout.vue'
import AerialView from './components/AerialView.vue'
import GardenMiniMap from './components/GardenMiniMap.vue'
import { useRows } from './composables/useRows'

const showAerial = ref(false)
const route = useRoute()
const { rows } = useRows()

const activeRowId = computed(() => {
  if (route.name === 'row' && route.params.id) {
    return parseInt(route.params.id as string, 10)
  }
  return undefined
})
</script>

<template>
  <AppLayout>
    <template #header-right>
      <button
        @click="showAerial = true"
        class="w-10 h-10 rounded-lg bg-garden-50 text-garden-700 flex items-center justify-center hover:bg-garden-100 active:scale-[0.97] transition-all duration-150 cursor-pointer text-base"
        title="מבט אווירי"
      >
        📷
      </button>
    </template>
    <router-view />
  </AppLayout>
  <AerialView :open="showAerial" @close="showAerial = false" />
  <GardenMiniMap v-if="rows.length > 0" :rows="rows" :active-row-id="activeRowId" />
</template>
