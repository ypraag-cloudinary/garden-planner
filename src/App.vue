<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppLayout from './components/AppLayout.vue'
import AerialView from './components/AerialView.vue'
import GardenExport from './components/GardenExport.vue'
import GardenMiniMap from './components/GardenMiniMap.vue'
import PipeMap from './components/PipeMap.vue'
import NurseryOrder from './components/NurseryOrder.vue'
import { useRows } from './composables/useRows'
import { useAuth } from './composables/useAuth'

const showAerial = ref(false)
const showExport = ref(false)
const showPipeMap = ref(false)
const showNurseryOrder = ref(false)
const route = useRoute()
const router = useRouter()
const { rows } = useRows()
const { signOut } = useAuth()

async function handleLogout() {
  await signOut()
  router.replace('/login')
}

const isLogin = computed(() => route.name === 'login')

const activeRowId = computed(() => {
  if (route.name === 'row' && route.params.id) {
    return parseInt(route.params.id as string, 10)
  }
  return undefined
})
</script>

<template>
  <router-view v-if="isLogin" />
  <template v-else>
    <AppLayout>
      <template #header-right>
        <div class="dropdown dropdown-end">
          <div tabindex="0" role="button" class="btn btn-ghost btn-square btn-sm">
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 5v.01M12 12v.01M12 19v.01" />
            </svg>
          </div>
          <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-50 w-52 p-2 shadow-lg border border-base-300">
            <li><a @click="showExport = true">📤 ייצוא מפת גינה</a></li>
            <li><a @click="showAerial = true">📷 מבט אווירי</a></li>
            <li><a @click="showPipeMap = true">💧 מפת צנרת</a></li>
            <li><a @click="showNurseryOrder = true">🌱 הזמנה למשתלה</a></li>
            <li class="border-t border-base-200 mt-1 pt-1"><a @click="handleLogout">⏻ התנתק</a></li>
          </ul>
        </div>
      </template>
      <router-view />
    </AppLayout>
    <AerialView :open="showAerial" @close="showAerial = false" />
    <GardenExport :open="showExport" :rows="rows" @close="showExport = false" />
    <PipeMap :open="showPipeMap" @close="showPipeMap = false" />
    <NurseryOrder :open="showNurseryOrder" :rows="rows" @close="showNurseryOrder = false" />
    <GardenMiniMap v-if="rows.length > 0" :rows="rows" :active-row-id="activeRowId" />
  </template>
</template>
