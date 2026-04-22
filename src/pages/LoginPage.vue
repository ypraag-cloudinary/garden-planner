<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const email = ref('')
const password = ref('')
const error = ref('')
const submitting = ref(false)
const router = useRouter()
const { signIn } = useAuth()

async function handleSubmit() {
  error.value = ''
  submitting.value = true
  try {
    await signIn(email.value, password.value)
    router.replace('/')
  } catch (e: any) {
    error.value = e?.message ?? 'שגיאה בהתחברות'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-soil-50 flex items-center justify-center px-4" dir="rtl">
    <form
      @submit.prevent="handleSubmit"
      class="w-full max-w-xs bg-white rounded-2xl shadow-lg p-8 flex flex-col gap-5"
    >
      <div class="text-center">
        <span class="text-4xl">🌱</span>
        <h1 class="text-xl font-semibold text-garden-700 mt-2">גינה קהילתית</h1>
      </div>

      <label class="flex flex-col gap-1.5">
        <span class="text-sm font-medium text-soil-600">אימייל</span>
        <input
          v-model="email"
          type="email"
          required
          autocomplete="email"
          dir="ltr"
          class="h-11 rounded-lg border border-soil-200 px-3 text-sm bg-soil-50 focus:outline-none focus:ring-2 focus:ring-garden-300 transition"
        />
      </label>

      <label class="flex flex-col gap-1.5">
        <span class="text-sm font-medium text-soil-600">סיסמה</span>
        <input
          v-model="password"
          type="password"
          required
          autocomplete="current-password"
          dir="ltr"
          class="h-11 rounded-lg border border-soil-200 px-3 text-sm bg-soil-50 focus:outline-none focus:ring-2 focus:ring-garden-300 transition"
        />
      </label>

      <p v-if="error" class="text-sm text-danger-600 text-center">{{ error }}</p>

      <button
        type="submit"
        :disabled="submitting"
        class="h-11 rounded-lg bg-garden-600 text-white font-medium text-sm hover:bg-garden-700 active:scale-[0.98] transition-all duration-150 disabled:opacity-50 cursor-pointer"
      >
        {{ submitting ? '...' : 'התחברות' }}
      </button>
    </form>
  </div>
</template>
