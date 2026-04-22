import { ref } from 'vue'
import { supabase } from '../lib/supabase'
import type { Vegetable } from '../types/database'

const vegetables = ref<Vegetable[]>([])
const loaded = ref(false)

export function useVegetables() {
  async function fetchVegetables() {
    if (loaded.value && vegetables.value.length > 0) return
    const { data, error } = await supabase
      .from('vegetables')
      .select('*')
      .order('name')
    if (error) throw error
    vegetables.value = data as Vegetable[]
    loaded.value = true
  }

  async function addVegetable(name: string): Promise<Vegetable> {
    const { data, error } = await supabase
      .from('vegetables')
      .insert({ name })
      .select()
      .single()
    if (error) throw error
    const veg = data as Vegetable
    vegetables.value.push(veg)
    vegetables.value.sort((a, b) => a.name.localeCompare(b.name, 'he'))
    return veg
  }

  function getVegetableColor(name: string): string {
    const palette = [
      '#4a7c59', '#8b6914', '#c17817', '#2d6a4f', '#6b8e23',
      '#a0522d', '#d4a017', '#228b6e', '#7b8a56', '#b5651d',
      '#3a7d44', '#c4956a', '#5f8575', '#9caf88', '#8fbc8f',
    ]
    let hash = 0
    for (let i = 0; i < name.length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }
    return palette[Math.abs(hash) % palette.length]
  }

  return { vegetables, fetchVegetables, addVegetable, getVegetableColor }
}
