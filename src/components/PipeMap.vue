<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { usePipeMappings } from '../composables/usePipeMappings'

defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  close: []
}>()

const { pipeMappings, loading, fetchPipeMappings, updatePipeMapping } = usePipeMappings()

const editing = ref(false)
const saving = ref(false)
const editValues = ref<Record<number, string>>({})

onMounted(fetchPipeMappings)

watch(() => editing.value, (isEditing) => {
  if (isEditing) {
    editValues.value = Object.fromEntries(
      pipeMappings.value.map((p) => [p.pipe_number, p.description])
    )
  }
})

async function save() {
  saving.value = true
  try {
    for (const pipe of pipeMappings.value) {
      const newDesc = editValues.value[pipe.pipe_number] ?? ''
      if (newDesc !== pipe.description) {
        await updatePipeMapping(pipe.pipe_number, newDesc)
      }
    }
    editing.value = false
  } catch (e) {
    console.error('Failed to save pipe mappings:', e)
  } finally {
    saving.value = false
  }
}

function cancelEdit() {
  editing.value = false
  editValues.value = {}
}
</script>

<template>
  <Teleport to="body">
    <Transition name="pipemap">
      <div
        v-if="open"
        class="fixed inset-0 z-50 bg-neutral/85 flex flex-col"
        @click.self="emit('close')"
      >
        <div class="flex items-center justify-between px-4 py-3 bg-neutral/60">
          <span class="text-neutral-content/90 font-medium text-sm">מפת צנרת</span>
          <div class="flex items-center gap-1.5">
            <template v-if="editing">
              <button
                @click="save"
                :disabled="saving"
                class="btn btn-primary btn-sm"
              >{{ saving ? 'שומר...' : 'שמור' }}</button>
              <button
                @click="cancelEdit"
                :disabled="saving"
                class="btn btn-ghost btn-sm text-neutral-content"
              >ביטול</button>
            </template>
            <button
              v-else
              @click="editing = true"
              class="btn btn-ghost btn-sm text-neutral-content"
              title="עריכה"
            >✏️ עריכה</button>
            <button
              @click="emit('close')"
              class="btn btn-ghost btn-square btn-sm text-neutral-content mr-1"
            >✕</button>
          </div>
        </div>

        <div class="flex-1 overflow-auto flex justify-center p-4" dir="rtl">
          <div v-if="loading" class="text-neutral-content/80 text-sm mt-20">
            <span class="loading loading-dots loading-md"></span>
            <div>טוען מיפוי צנרת...</div>
          </div>

          <div v-else class="w-full max-w-md space-y-3 pt-2">
            <div
              v-for="pipe in pipeMappings"
              :key="pipe.pipe_number"
              class="bg-white/10 backdrop-blur-sm rounded-xl border border-white/10 p-4 flex items-start gap-4"
            >
              <div class="w-12 h-12 rounded-xl bg-sky-500/20 text-sky-300 font-bold text-lg flex items-center justify-center flex-shrink-0">
                {{ pipe.pipe_number }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="text-white/50 text-xs font-medium mb-1">צינור {{ pipe.pipe_number }}</div>
                <template v-if="editing">
                  <input
                    v-model="editValues[pipe.pipe_number]"
                    type="text"
                    class="input input-bordered input-sm w-full bg-white/10 border-white/20 text-white placeholder-white/30"
                    placeholder="תיאור אזור..."
                    dir="rtl"
                  />
                </template>
                <template v-else>
                  <div
                    class="text-sm"
                    :class="pipe.description ? 'text-white/90 font-medium' : 'text-white/30 italic'"
                  >
                    {{ pipe.description || 'טרם מופה' }}
                  </div>
                </template>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.pipemap-enter-active {
  transition: opacity 0.2s ease;
}
.pipemap-leave-active {
  transition: opacity 0.15s ease;
}
.pipemap-enter-from,
.pipemap-leave-to {
  opacity: 0;
}
</style>
