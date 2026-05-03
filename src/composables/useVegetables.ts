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
      '#7ca88a', '#b89e5c', '#c9a46a', '#6a9e82', '#9aad6e',
      '#b8937a', '#c4ac5e', '#6aab96', '#9ba37a', '#c0996e',
      '#79a678', '#cbb492', '#88a898', '#afc09e', '#a5c8a5',
    ]
    let hash = 0
    for (let i = 0; i < name.length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }
    return palette[Math.abs(hash) % palette.length]
  }

  return { vegetables, fetchVegetables, addVegetable, getVegetableColor }
}
