import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { GardenRow, RowWithSegments, Segment } from '../types/database'

const rows = ref<RowWithSegments[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

export function useRows() {
  async function fetchRows() {
    loading.value = true
    error.value = null
    try {
      const { data: rowData, error: rowErr } = await supabase
        .from('rows')
        .select('*')
        .order('id')
      if (rowErr) throw rowErr

      const { data: segData, error: segErr } = await supabase
        .from('segments')
        .select('*')
        .order('position')
      if (segErr) throw segErr

      const segmentsByRow = new Map<number, Segment[]>()
      for (const seg of segData as Segment[]) {
        const list = segmentsByRow.get(seg.row_id) ?? []
        list.push(seg)
        segmentsByRow.set(seg.row_id, list)
      }

      rows.value = (rowData as GardenRow[]).map((row) => ({
        ...row,
        segments: segmentsByRow.get(row.id) ?? [],
      }))
    } catch (e: unknown) {
      if (e instanceof Error) {
        error.value = e.message
      } else if (e && typeof e === 'object' && 'message' in e) {
        error.value = (e as { message: string }).message
      } else {
        error.value = 'שגיאה בטעינת ערוגות'
      }
    } finally {
      loading.value = false
    }
  }

  async function updateRow(id: number, updates: Partial<GardenRow>) {
    const { error: err } = await supabase
      .from('rows')
      .update(updates)
      .eq('id', id)
    if (err) throw err
    await fetchRows()
  }

  return { rows, loading, error, fetchRows, updateRow }
}
