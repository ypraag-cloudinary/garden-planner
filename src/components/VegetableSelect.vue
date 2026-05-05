<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from 'vue'
import { useVegetables } from '../composables/useVegetables'
import VegIcon from './VegIcon.vue'
import { XMarkIcon } from '@heroicons/vue/24/outline'

const props = defineProps<{
  modelValue: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const { vegetables, fetchVegetables } = useVegetables()

const isOpen = ref(false)
const search = ref('')
const searchInput = ref<HTMLInputElement | null>(null)

const EMPTY_VEGETABLE = 'ריקה'
const RECENT_KEY = 'gina-recent-vegetables'
const MAX_RECENT = 5

const recentNames = ref<string[]>(loadRecent())

function loadRecent(): string[] {
  try {
    const stored = localStorage.getItem(RECENT_KEY)
    return stored ? JSON.parse(stored) : []
  } catch {
    return []
  }
}

function saveRecent(name: string) {
  const list = [name, ...recentNames.value.filter((n) => n !== name)].slice(0, MAX_RECENT)
  recentNames.value = list
  try { localStorage.setItem(RECENT_KEY, JSON.stringify(list)) } catch {}
}

const selectable = computed(() =>
  vegetables.value.filter((v) => v.name !== EMPTY_VEGETABLE)
)

const recentVegetables = computed(() =>
  recentNames.value
    .map((name) => vegetables.value.find((v) => v.name === name))
    .filter((v): v is NonNullable<typeof v> => !!v && v.name !== EMPTY_VEGETABLE)
)

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return selectable.value
  return selectable.value.filter((v) => v.name.toLowerCase().includes(q))
})

const selectedVeg = computed(() =>
  vegetables.value.find((v) => v.name === props.modelValue)
)

async function open() {
  search.value = ''
  isOpen.value = true
  await nextTick()
  searchInput.value?.focus()
}

function select(name: string) {
  saveRecent(name)
  emit('update:modelValue', name)
  isOpen.value = false
}

function quickSelect(name: string) {
  saveRecent(name)
  emit('update:modelValue', name)
}

onMounted(fetchVegetables)
</script>

<template>
  <div class="space-y-2">
    <button
      type="button"
      @click="open"
      class="btn btn-outline w-full justify-start gap-2 font-normal"
    >
      <template v-if="modelValue">
        <VegIcon v-if="selectedVeg?.icon" :name="selectedVeg.icon" size="1.25rem" />
        <span class="text-base-content">{{ modelValue }}</span>
      </template>
      <span v-else class="text-base-content/40">בחר ירק...</span>
      <svg class="w-4 h-4 text-base-content/40 mr-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    <!-- Quick picks (recent vegetables) -->
    <div v-if="recentVegetables.length > 0 && !modelValue" class="flex flex-wrap gap-1.5">
      <button
        v-for="veg in recentVegetables"
        :key="veg.id"
        type="button"
        @click="quickSelect(veg.name)"
        class="badge badge-outline badge-sm gap-1 cursor-pointer hover:badge-primary transition-colors py-2.5"
      >
        <VegIcon v-if="veg.icon" :name="veg.icon" size="0.875rem" />
        <span>{{ veg.name }}</span>
      </button>
    </div>
  </div>

  <Teleport to="body">
    <Transition name="sheet">
      <div
        v-if="isOpen"
        class="modal modal-open modal-bottom sm:modal-middle"
        @click.self="isOpen = false"
      >
        <div class="modal-box max-h-[85vh] flex flex-col p-0">
          <div class="px-4 pt-4 pb-3 border-b border-base-200">
            <div class="flex items-center justify-between mb-3">
              <h3 class="font-semibold text-base-content text-lg">בחירת ירק</h3>
              <button
                @click="isOpen = false"
                class="btn btn-ghost btn-circle btn-sm"
              ><XMarkIcon class="w-5 h-5" /></button>
            </div>
            <input
              ref="searchInput"
              v-model="search"
              type="text"
              placeholder="חיפוש..."
              class="input input-bordered w-full"
            />
          </div>

          <div class="flex-1 overflow-y-auto p-3">
            <div class="menu menu-lg p-0">
              <li v-for="veg in filtered" :key="veg.id">
                <button
                  type="button"
                  @click="select(veg.name)"
                  class="flex items-center gap-2.5 text-right"
                  :class="modelValue === veg.name ? 'active' : ''"
                >
                  <VegIcon :name="veg.icon" size="1.5rem" />
                  <div class="flex flex-col items-start">
                    <span class="text-sm">{{ veg.name }}</span>
                    <span v-if="veg.days_to_harvest" class="text-[11px] text-base-content/40">
                      {{ veg.days_to_harvest }} ימים לקטיף
                    </span>
                  </div>
                </button>
              </li>
            </div>
            <div v-if="filtered.length === 0" class="text-center py-10 text-base-content/40 text-sm">
              לא נמצאו ירקות
            </div>
          </div>
        </div>
        <div class="modal-backdrop" @click="isOpen = false"></div>
      </div>
    </Transition>
  </Teleport>
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
