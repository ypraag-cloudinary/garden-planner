import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { GardenTask } from '../types/database'

const tasks = ref<GardenTask[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

export function useTasks() {
  async function fetchTasks({ silent = false }: { silent?: boolean } = {}) {
    if (!silent) loading.value = true
    error.value = null
    try {
      const { data, error: err } = await supabase
        .from('garden_tasks')
        .select('*')
        .order('position')
      if (err) throw err
      tasks.value = data as GardenTask[]
    } catch (e: unknown) {
      if (e instanceof Error) {
        error.value = e.message
      } else if (e && typeof e === 'object' && 'message' in e) {
        error.value = (e as { message: string }).message
      } else {
        error.value = 'שגיאה בטעינת משימות'
      }
    } finally {
      if (!silent) loading.value = false
    }
  }

  async function addTask(text: string) {
    const maxPosition = tasks.value.reduce((max, t) => Math.max(max, t.position), 0)
    const { error: err } = await supabase
      .from('garden_tasks')
      .insert({ text, position: maxPosition + 1 })
    if (err) throw err
    await fetchTasks({ silent: true })
  }

  async function toggleTask(id: string, completed: boolean) {
    const { error: err } = await supabase
      .from('garden_tasks')
      .update({ completed })
      .eq('id', id)
    if (err) throw err
    await fetchTasks({ silent: true })
  }

  async function deleteTask(id: string) {
    const { error: err } = await supabase
      .from('garden_tasks')
      .delete()
      .eq('id', id)
    if (err) throw err
    await fetchTasks({ silent: true })
  }

  return { tasks, loading, error, fetchTasks, addTask, toggleTask, deleteTask }
}
