import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { GardenShift } from '../types/database'

const shifts = ref<GardenShift[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

export function useShifts() {
  async function fetchShifts({ silent = false }: { silent?: boolean } = {}) {
    if (!silent) loading.value = true
    error.value = null
    try {
      const { data, error: err } = await supabase
        .from('garden_shifts')
        .select('*')
        .order('shift_date')
      if (err) throw err
      shifts.value = data as GardenShift[]
    } catch (e: unknown) {
      if (e instanceof Error) {
        error.value = e.message
      } else if (e && typeof e === 'object' && 'message' in e) {
        error.value = (e as { message: string }).message
      } else {
        error.value = 'שגיאה בטעינת שיבוצים'
      }
    } finally {
      if (!silent) loading.value = false
    }
  }

  async function addShift(shiftDate: string) {
    const { error: err } = await supabase
      .from('garden_shifts')
      .insert({ shift_date: shiftDate, person: '' })
    if (err) throw err
    await fetchShifts({ silent: true })
  }

  async function updateShiftPerson(id: string, person: string) {
    const { error: err } = await supabase
      .from('garden_shifts')
      .update({ person })
      .eq('id', id)
    if (err) throw err
    await fetchShifts({ silent: true })
  }

  async function deleteShift(id: string) {
    const { error: err } = await supabase
      .from('garden_shifts')
      .delete()
      .eq('id', id)
    if (err) throw err
    await fetchShifts({ silent: true })
  }

  return { shifts, loading, error, fetchShifts, addShift, updateShiftPerson, deleteShift }
}

// Formats an ISO date ('2026-06-15') to organizer-style label: "15.06 (יום שני)".
export function formatShiftLabel(isoDate: string): string {
  const d = new Date(isoDate + 'T00:00:00')
  const day = String(d.getDate()).padStart(2, '0')
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const weekday = d.toLocaleDateString('he-IL', { weekday: 'long' })
  return `${day}.${month} (${weekday})`
}
