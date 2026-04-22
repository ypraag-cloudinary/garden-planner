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

  async function upsertSegment(segment: Partial<Segment> & { row_id: number; position: number; vegetable: string }) {
    saving.value = true
    try {
      if (segment.id) {
        const { error } = await supabase
          .from('segments')
          .update({
            vegetable: segment.vegetable,
            planted_at: segment.planted_at,
            length_m: segment.length_m,
            notes: segment.notes,
          })
          .eq('id', segment.id)
        if (error) throw error
      } else {
        const { error } = await supabase
          .from('segments')
          .insert({
            row_id: segment.row_id,
            position: segment.position,
            vegetable: segment.vegetable,
            planted_at: segment.planted_at,
            length_m: segment.length_m,
            notes: segment.notes,
          })
        if (error) throw error
      }
    } finally {
      saving.value = false
    }
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
      const { data: existing } = await supabase
        .from('segments')
        .select('id')
        .eq('row_id', rowId)

      const existingIds = new Set((existing ?? []).map((s: { id: string }) => s.id))
      const currentIds = new Set(segments.filter((s) => s.id).map((s) => s.id))

      const toDelete = [...existingIds].filter((id) => !currentIds.has(id))
      if (toDelete.length > 0) {
        const { error } = await supabase
          .from('segments')
          .delete()
          .in('id', toDelete)
        if (error) throw error
      }

      for (const seg of segments) {
        await upsertSegment(seg)
      }
    } finally {
      saving.value = false
    }
  }

  return { saving, fetchSegments, upsertSegment, deleteSegment, saveAllSegments }
}
