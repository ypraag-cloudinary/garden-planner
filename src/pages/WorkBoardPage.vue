<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useTasks } from '../composables/useTasks'
import { useShifts, formatShiftLabel } from '../composables/useShifts'
import { TrashIcon, PlusIcon } from '@heroicons/vue/24/outline'

const {
  tasks,
  loading: tasksLoading,
  error: tasksError,
  fetchTasks,
  addTask,
  toggleTask,
  deleteTask,
} = useTasks()

const {
  shifts,
  fetchShifts,
  addShift,
  updateShiftPerson,
  deleteShift,
} = useShifts()

const loading = computed(() => tasksLoading.value)
const error = computed(() => tasksError.value)

const newTaskText = ref('')
const newShiftDate = ref('')
const addingTask = ref(false)
const addingShift = ref(false)

onMounted(() => {
  fetchTasks()
  fetchShifts()
})

function reload() {
  fetchTasks()
  fetchShifts()
}

async function submitTask() {
  const text = newTaskText.value.trim()
  if (!text || addingTask.value) return
  addingTask.value = true
  try {
    await addTask(text)
    newTaskText.value = ''
  } finally {
    addingTask.value = false
  }
}

async function submitShift() {
  if (!newShiftDate.value || addingShift.value) return
  addingShift.value = true
  try {
    await addShift(newShiftDate.value)
    newShiftDate.value = ''
  } finally {
    addingShift.value = false
  }
}

// A shift is "upcoming" if it falls between today and 3 days from now (inclusive).
function isUpcoming(isoDate: string): boolean {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const shift = new Date(isoDate + 'T00:00:00')
  const diffDays = Math.round((shift.getTime() - today.getTime()) / 86_400_000)
  return diffDays >= 0 && diffDays <= 3
}
</script>

<template>
  <div class="pb-8" dir="rtl">
    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="text-center text-base-content/50">
        <span class="loading loading-dots loading-lg text-primary"></span>
        <div class="text-sm font-medium mt-2">טוען לוח עבודה...</div>
      </div>
    </div>

    <div v-else-if="error" class="p-6 text-center">
      <div role="alert" class="alert alert-error">
        <span>{{ error }}</span>
      </div>
      <button @click="reload" class="btn btn-error btn-outline btn-sm mt-3">
        נסה שוב
      </button>
    </div>

    <div v-else class="pt-5 px-4 space-y-5 md:grid md:grid-cols-12 md:gap-5 md:space-y-0">
      <!-- Right column: recurring activities, shifts, events -->
      <div class="md:col-span-5 space-y-5">
        <!-- Recurring activities (static) -->
        <div class="card bg-base-100 border border-base-300">
          <div class="card-body p-5">
            <h2 class="font-semibold text-base-content">פעילויות קבועות</h2>
            <div class="space-y-3 mt-1">
              <div>
                <h3 class="text-sm font-medium text-base-content">ימי פעילות שבועיים</h3>
                <p class="text-xs text-base-content/60 mt-0.5">כל יום שני בשעות אחר הצהריים.</p>
              </div>
              <div class="pt-3 border-t border-base-200">
                <h3 class="text-sm font-medium text-base-content">פעילות קבועה - דואון א׳-ב׳</h3>
                <p class="text-xs text-base-content/60 mt-0.5">כל יום חמישי, החל מ-02.07 ועד 20.08.</p>
                <p class="text-xs text-primary font-medium mt-1 bg-primary/10 px-2 py-1 rounded inline-block">
                  מלווה: יותם
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Upcoming events (static) -->
        <div class="card bg-base-100 border border-base-300">
          <div class="card-body p-5">
            <h2 class="font-semibold text-base-content">לוח אירועים קרובים</h2>
            <div class="space-y-3 mt-1 text-sm">
              <div class="pb-3 border-b border-base-200">
                <span class="text-xs font-semibold text-primary bg-primary/10 px-2 py-0.5 rounded">14.06 (ראשון)</span>
                <h4 class="font-medium text-base-content mt-1">אירוע שינשינים עם רענן</h4>
                <p class="text-xs text-base-content/60 mt-1 font-medium">מלווה: לירן</p>
              </div>
              <div class="pb-3 border-b border-base-200">
                <span class="text-xs font-semibold text-primary bg-primary/10 px-2 py-0.5 rounded">19.06 (שישי)</span>
                <h4 class="font-medium text-base-content mt-1">קבלת שבת עם מורן והדס</h4>
                <p class="text-xs text-base-content/70 mt-1 bg-base-200 p-2 rounded">
                  משימות הכנה: לדבר עם דורה על חלות 🍞 ולפרסם בקיבוץ.
                </p>
              </div>
              <div class="pb-3 border-b border-base-200">
                <span class="text-xs font-semibold text-primary bg-primary/10 px-2 py-0.5 rounded">19.07 (ראשון) | 10:00 - 12:00</span>
                <h4 class="font-medium text-base-content mt-1">יום ענף דואון א׳-ב׳</h4>
                <p class="text-xs text-base-content/60 mt-1 font-medium">מלווה: טל</p>
              </div>
              <div>
                <span class="text-xs font-semibold text-primary bg-primary/10 px-2 py-0.5 rounded">02.08 (חמישי) | 09:30 - 12:00</span>
                <h4 class="font-medium text-base-content mt-1">יום ענף דואון ג׳-ד׳</h4>
                <p class="text-xs text-base-content/60 mt-1 font-medium">מלווה: לירן</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Shift assignments (dynamic) -->
        <div class="card bg-base-100 border border-base-300">
          <div class="card-body p-5">
            <h2 class="font-semibold text-base-content">שיבוץ מלווים</h2>
            <p class="text-xs text-base-content/60">הקלידו את שם האחראי/ת ליד התאריך המתאים.</p>

            <div class="space-y-2 mt-2">
              <p v-if="shifts.length === 0" class="text-xs text-base-content/50 py-2">
                אין תאריכים ברשימה.
              </p>
              <div
                v-for="shift in shifts"
                :key="shift.id"
                class="flex items-center gap-2 py-1.5 border-b border-base-200 last:border-b-0"
              >
                <span class="text-xs font-medium text-base-content/70 shrink-0 w-28 flex flex-col gap-0.5">
                  <span>{{ formatShiftLabel(shift.shift_date) }}</span>
                  <span
                    v-if="isUpcoming(shift.shift_date)"
                    class="badge badge-xs badge-warning gap-1 font-semibold"
                  >
                    🔔 קרוב
                  </span>
                </span>
                <input
                  type="text"
                  :value="shift.person"
                  placeholder="שם האחראי/ת..."
                  @change="updateShiftPerson(shift.id, ($event.target as HTMLInputElement).value)"
                  class="input input-sm input-bordered flex-grow text-xs"
                />
                <button
                  @click="deleteShift(shift.id)"
                  class="btn btn-ghost btn-square btn-xs text-base-content/40 hover:text-error"
                  title="מחיקת תאריך"
                >
                  <TrashIcon class="w-4 h-4" />
                </button>
              </div>
            </div>

            <div class="flex gap-2 mt-3 pt-3 border-t border-base-200">
              <input
                v-model="newShiftDate"
                type="date"
                :readonly="addingShift"
                class="input input-sm input-bordered flex-grow text-xs"
              />
              <button
                @click="submitShift"
                class="btn btn-sm btn-neutral gap-1 shrink-0"
                :disabled="addingShift"
              >
                <span v-if="addingShift" class="loading loading-spinner loading-xs"></span>
                <PlusIcon v-else class="w-4 h-4" /> הוספת תאריך
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Left column: task checklist (dynamic) -->
      <div class="md:col-span-7">
        <div class="card bg-base-100 border border-base-300">
          <div class="card-body p-5">
            <h2 class="font-semibold text-base-content">דברים לביצוע בגינה</h2>

            <div class="mt-2">
              <p v-if="tasks.length === 0" class="text-center py-6 text-base-content/50 text-sm">
                אין משימות פתוחות כרגע. סחתיין! 🎉
              </p>
              <div
                v-for="task in tasks"
                :key="task.id"
                class="flex items-start justify-between gap-3 py-2.5 border-b border-base-200 last:border-b-0"
              >
                <label class="flex items-start gap-3 cursor-pointer flex-grow select-none">
                  <input
                    type="checkbox"
                    :checked="task.completed"
                    @change="toggleTask(task.id, ($event.target as HTMLInputElement).checked)"
                    class="checkbox checkbox-sm checkbox-primary mt-0.5"
                  />
                  <span
                    class="text-sm leading-relaxed"
                    :class="task.completed ? 'line-through text-base-content/40' : 'text-base-content'"
                  >
                    {{ task.text }}
                  </span>
                </label>
                <button
                  @click="deleteTask(task.id)"
                  class="btn btn-ghost btn-square btn-xs text-base-content/40 hover:text-error shrink-0"
                  title="מחיקת משימה"
                >
                  <TrashIcon class="w-4 h-4" />
                </button>
              </div>
            </div>

            <form @submit.prevent="submitTask" class="flex gap-2 mt-4 pt-4 border-t border-base-200">
              <input
                v-model="newTaskText"
                type="text"
                placeholder="הוספת משימה חדשה שעלתה..."
                :readonly="addingTask"
                class="input input-sm input-bordered flex-grow"
              />
              <button type="submit" class="btn btn-sm btn-neutral shrink-0" :disabled="addingTask">
                <span v-if="addingTask" class="loading loading-spinner loading-xs"></span>
                הוספה
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
