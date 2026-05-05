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
  <div class="min-h-screen bg-base-200 flex flex-col items-center justify-center px-4" dir="rtl">
    <form
      @submit.prevent="handleSubmit"
      class="card bg-base-100 shadow-lg w-full max-w-xs"
    >
      <div class="card-body gap-5">
        <div class="text-center">
          <svg class="w-12 h-12 mx-auto text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21c0-4-2-7-5-9 3-1 5 1 5 4m0 5c0-4 2-7 5-9-3-1-5 1-5 4m0-12v8" /></svg>
          <h1 class="text-xl font-semibold text-primary mt-2">גינה קהילתית</h1>
        </div>

        <label class="flex flex-col gap-1.5">
          <span class="text-sm font-medium text-base-content/70">אימייל</span>
          <input
            v-model="email"
            type="email"
            required
            autocomplete="email"
            dir="ltr"
            class="input input-bordered w-full"
          />
        </label>

        <label class="flex flex-col gap-1.5">
          <span class="text-sm font-medium text-base-content/70">סיסמה</span>
          <input
            v-model="password"
            type="password"
            required
            autocomplete="current-password"
            dir="ltr"
            class="input input-bordered w-full"
          />
        </label>

        <p v-if="error" class="text-sm text-error text-center">{{ error }}</p>

        <button
          type="submit"
          :disabled="submitting"
          class="btn btn-primary w-full"
        >
          {{ submitting ? '...' : 'התחברות' }}
        </button>
      </div>
    </form>
    <p class="mt-6 text-[10px] text-base-content/30" dir="ltr">
      <a href="https://www.flaticon.com/free-icons/vegetable" target="_blank" rel="noopener" class="hover:underline">Vegetable icons created by Freepik - Flaticon</a>
    </p>
  </div>
</template>
