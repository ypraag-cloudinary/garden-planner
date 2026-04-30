<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from 'vue'
import { useVegetables } from '../composables/useVegetables'

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

const selectable = computed(() =>
  vegetables.value.filter((v) => v.name !== EMPTY_VEGETABLE)
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
  emit('update:modelValue', name)
  isOpen.value = false
}

onMounted(fetchVegetables)
</script>

<template>
  <button
    type="button"
    @click="open"
    class="w-full rounded-lg border border-soil-300 px-3 py-2.5 text-sm text-right flex items-center gap-2 hover:border-garden-400 transition-colors duration-150 cursor-pointer bg-white"
  >
    <template v-if="modelValue">
      <span v-if="selectedVeg?.icon" class="text-base">{{ selectedVeg.icon }}</span>
      <span class="text-soil-800">{{ modelValue }}</span>
    </template>
    <span v-else class="text-soil-400">בחר ירק...</span>
    <svg class="w-4 h-4 text-soil-400 mr-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
      <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
    </svg>
  </button>

  <Teleport to="body">
    <Transition name="sheet">
      <div
        v-if="isOpen"
        class="fixed inset-0 z-50 bg-black/40 flex items-end sm:items-center justify-center"
        @click.self="isOpen = false"
      >
        <div class="bg-white w-full max-w-lg rounded-t-2xl sm:rounded-2xl max-h-[85vh] flex flex-col overflow-hidden">
          <div class="px-4 pt-4 pb-3 border-b border-soil-100">
            <div class="flex items-center justify-between mb-3">
              <h3 class="font-semibold text-soil-800">בחירת ירק</h3>
              <button
                @click="isOpen = false"
                class="w-9 h-9 rounded-full hover:bg-soil-100 flex items-center justify-center text-soil-500 cursor-pointer transition-colors duration-150"
              >✕</button>
            </div>
            <input
              ref="searchInput"
              v-model="search"
              type="text"
              placeholder="חיפוש..."
              class="w-full rounded-lg border border-soil-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-garden-500 focus:border-garden-500 bg-soil-50 placeholder:text-soil-300"
            />
          </div>

          <div class="flex-1 overflow-y-auto p-3">
            <div class="flex flex-col gap-1">
              <button
                v-for="veg in filtered"
                :key="veg.id"
                type="button"
                @click="select(veg.name)"
                class="flex items-center gap-2.5 px-3 py-2.5 rounded-xl hover:bg-garden-50 active:scale-[0.99] transition-all duration-150 cursor-pointer text-right"
                :class="modelValue === veg.name ? 'bg-garden-100 ring-2 ring-garden-500' : ''"
              >
                <span class="text-xl leading-none shrink-0">{{ veg.icon || '🌱' }}</span>
                <span class="text-sm text-soil-700">{{ veg.name }}</span>
              </button>
            </div>
            <div v-if="filtered.length === 0" class="text-center py-10 text-soil-400 text-sm">
              לא נמצאו ירקות
            </div>
          </div>
        </div>
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
