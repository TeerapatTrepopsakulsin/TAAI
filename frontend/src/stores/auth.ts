import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/services/supabase'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const loading = ref(true)

  const initialize = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession()
      user.value = session?.user ?? null
    } catch (error) {
      console.error('Error initializing auth:', error)
    } finally {
      loading.value = false
    }
  }

  const signInWithGoogle = async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        scopes: 'https://www.googleapis.com/auth/classroom.courses.readonly https://www.googleapis.com/auth/classroom.coursework.students',
        redirectTo: `${window.location.origin}/auth/callback`,
      }
    })

    if (error) {
      throw error
    }

    return data
  }

  const signOut = async () => {
    await supabase.auth.signOut()
    user.value = null
  }

  supabase.auth.onAuthStateChange((event, session) => {
    (async () => {
      user.value = session?.user ?? null
    })()
  })

  return {
    user,
    loading,
    initialize,
    signInWithGoogle,
    signOut
  }
})
