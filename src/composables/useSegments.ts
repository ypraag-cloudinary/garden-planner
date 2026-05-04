import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { Segment } from '../types/database'

export function useSegments() {
  const saving = ref(false)

  async function fetchSegments(rowId: number): Promise<Segment[]> {
    const { data, error } = await supabase
      .from('segments')
      .select('*')
      .eq('row_id', rowId)
      .order('position')
    if (error) throw error
    return data as Segment[]
  }

  async function deleteSegment(id: string) {
    const { error } = await supabase
      .from('segments')
      .delete()
      .eq('id', id)
    if (error) throw error
  }

  async function saveAllSegments(rowId: number, segments: Segment[]) {
    saving.value = true
    try {
      const { error } = await supabase.rpc('save_segments', {
        p_row_id: rowId,
        p_segments: segments.map((seg) => ({
          position: seg.position,
          vegetable: seg.vegetable,
          planted_at: seg.planted_at,
          length_m: seg.length_m,
          notes: seg.notes,
          is_planned: seg.is_planned,
        })),
      })
      if (error) throw error
    } finally {
      saving.value = false
    }
  }

  return { saving, fetchSegments, deleteSegment, saveAllSegments }
}
