import { ref } from 'vue'
import type { User } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

const user = ref<User | null>(null)
const loading = ref(true)

supabase.auth.getSession().then(({ data: { session } }) => {
  user.value = session?.user ?? null
  loading.value = false
})

supabase.auth.onAuthStateChange((_event, session) => {
  user.value = session?.user ?? null
})

export function useAuth() {
  async function signIn(email: string, password: string) {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  async function signOut() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return { user, loading, signIn, signOut }
}
