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

  const vegetableColors: Record<string, string> = {
    // Tomatoes — muted warm red
    'עגבניות שרי עגולה': '#c45a5a',
    'עגבניות שרי תמר': '#c45a5a',
    'עגבניות שרי שחור': '#8b4a5a',
    'עגבניה תמר': '#bf5e50',
    'עגבניה עגולה': '#bf5e50',
    // Eggplants — dusty purple
    'חציל בלאדי': '#8a6aaa',
    'חציל קלאסי': '#7a5a9a',
    // Peppers — warm amber/ochre
    'פלפל גמבה': '#c4a040',
    'פלפל שושקה': '#c4a040',
    'פלפלים חריפים': '#c06848',
    // Cucumbers & zucchini — fresh green
    'מלפפונים': '#6a9e60',
    'קישוא בהיר': '#8aaa68',
    'קישוא עגול כהה': '#4a7a48',
    'זוקיני': '#5a8a50',
    // Melons & squash — warm gold/tan
    'מלון': '#c4a868',
    'אבטיח': '#b8706a',
    'דלעת יפנית': '#4a7850',
    'דלעת ערמונים': '#9a8058',
    'דלעת ספגטי': '#c8b450',
    'דלורית האני נאט': '#c49048',
    'דלעת': '#c08a48',
    // Root vegetables — earthy tones
    'גזר': '#cc8a40',
    'גזר לבן': '#c8b080',
    'בצל': '#bfa058',
    'שום': '#b8a890',
    'צנון': '#c46a50',
    'צנונית': '#c47a60',
    'תפוח אדמה': '#b09868',
    'בטטה': '#b07050',
    'סלק אדום': '#a04858',
    'סלק צהוב': '#c4a048',
    'לפת': '#c8b888',
    'שאלוט': '#b09068',
    'קולרבי': '#7a9a6a',
    // Leafy greens — varied greens
    'חסה ערבית': '#6aaa58',
    'חסה לליק': '#5a9a4a',
    'תרד טורקי': '#3a7a38',
    'תרד ניוזילנדי': '#4a8a48',
    'רוקט': '#4a8040',
    'קייל': '#3a6a40',
    'מנגולד': '#5a8a50',
    'כרוב לבן': '#7aaa70',
    'כרוב סגול': '#7a5a8a',
    'כרוב ניצנים': '#6a9a60',
    'בק צ׳וי': '#5a9a58',
    'ברוקולי': '#4a8a48',
    'כרובית': '#a0a888',
    // Herbs — bright greens
    'פטרוזיליה': '#58a050',
    'כוסברה': '#50a048',
    'נענע': '#48a068',
    'שמיר': '#78a850',
    'כרישה': '#6a9a58',
    'בזיליקום לימוני': '#78aa48',
    'בזיליקום תאילנדי': '#4a7a48',
    'סלרי': '#6aa058',
    // Legumes — warm brown/green
    'שעועית': '#9a8050',
    'שעועית ירוקה': '#58a050',
    'אפונה': '#68a058',
    // Other
    'תירס': '#c8a838',
    'במיה': '#6a9a50',
    'אספרגוס': '#5a8a48',
  }

  function getVegetableColor(name: string): string {
    if (vegetableColors[name]) return vegetableColors[name]
    // Fallback: hash-based for unknown vegetables
    const palette = [
      '#7ca88a', '#b89e5c', '#c9a46a', '#6a9e82', '#9aad6e',
      '#b8937a', '#c4ac5e', '#6aab96', '#9ba37a', '#c0996e',
    ]
    let hash = 0
    for (let i = 0; i < name.length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }
    return palette[Math.abs(hash) % palette.length]
  }

  return { vegetables, fetchVegetables, addVegetable, getVegetableColor }
}
