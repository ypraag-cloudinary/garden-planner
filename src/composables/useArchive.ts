import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { SegmentHistory } from '../types/database'

export function useArchive() {
  const archiving = ref(false)

  async function archiveRow(rowId: number) {
    archiving.value = true
    try {
      const { data: segments, error: fetchErr } = await supabase
        .from('segments')
        .select('*')
        .eq('row_id', rowId)
      if (fetchErr) throw fetchErr
      if (!segments || segments.length === 0) return

      const historyEntries = segments.map((s) => ({
        row_id: s.row_id,
        position: s.position,
        vegetable: s.vegetable,
        planted_at: s.planted_at,
        length_m: s.length_m,
        notes: s.notes,
        is_planned: s.is_planned,
      }))

      const { error: insertErr } = await supabase
        .from('segment_history')
        .insert(historyEntries)
      if (insertErr) throw insertErr

      const { error: deleteErr } = await supabase
        .from('segments')
        .delete()
        .eq('row_id', rowId)
      if (deleteErr) throw deleteErr
    } finally {
      archiving.value = false
    }
  }

  async function fetchHistory(rowId: number): Promise<SegmentHistory[]> {
    const { data, error } = await supabase
      .from('segment_history')
      .select('*')
      .eq('row_id', rowId)
      .order('archived_at', { ascending: false })
      .order('position')
    if (error) throw error
    return data as SegmentHistory[]
  }

  return { archiving, archiveRow, fetchHistory }
}
