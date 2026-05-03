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
    class="btn btn-outline w-full justify-start gap-2 font-normal"
  >
    <template v-if="modelValue">
      <span v-if="selectedVeg?.icon" class="text-base">{{ selectedVeg.icon }}</span>
      <span class="text-base-content">{{ modelValue }}</span>
    </template>
    <span v-else class="text-base-content/40">בחר ירק...</span>
    <svg class="w-4 h-4 text-base-content/40 mr-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
      <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
    </svg>
  </button>

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
              >✕</button>
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
                  <span class="text-xl leading-none shrink-0">{{ veg.icon || '🌱' }}</span>
                  <span class="text-sm">{{ veg.name }}</span>
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
