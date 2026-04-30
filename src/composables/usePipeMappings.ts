import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { PipeMapping } from '../types/database'

const pipeMappings = ref<PipeMapping[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

export function usePipeMappings() {
  async function fetchPipeMappings() {
    loading.value = true
    error.value = null
    try {
      const { data, error: err } = await supabase
        .from('pipe_mappings')
        .select('*')
        .order('pipe_number')
      if (err) throw err
      pipeMappings.value = data as PipeMapping[]
    } catch (e: unknown) {
      if (e instanceof Error) {
        error.value = e.message
      } else if (e && typeof e === 'object' && 'message' in e) {
        error.value = (e as { message: string }).message
      } else {
        error.value = 'שגיאה בטעינת מיפוי צנרת'
      }
    } finally {
      loading.value = false
    }
  }

  async function updatePipeMapping(pipeNumber: number, description: string) {
    const { error: err } = await supabase
      .from('pipe_mappings')
      .update({ description, updated_at: new Date().toISOString() })
      .eq('pipe_number', pipeNumber)
    if (err) throw err
    await fetchPipeMappings()
  }

  return { pipeMappings, loading, error, fetchPipeMappings, updatePipeMapping }
}
