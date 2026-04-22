import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../pages/HomePage.vue'
import RowPage from '../pages/RowPage.vue'
import LoginPage from '../pages/LoginPage.vue'
import { useAuth } from '../composables/useAuth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'home', component: HomePage },
    { path: '/row/:id', name: 'row', component: RowPage, props: true },
    { path: '/login', name: 'login', component: LoginPage },
  ],
})

router.beforeEach((to) => {
  const { user, loading } = useAuth()

  if (loading.value) {
    return new Promise<void>((resolve) => {
      const stop = setInterval(() => {
        if (!loading.value) {
          clearInterval(stop)
          resolve()
        }
      }, 50)
    }).then(() => {
      if (!user.value && to.name !== 'login') return { name: 'login' }
      if (user.value && to.name === 'login') return { name: 'home' }
    })
  }

  if (!user.value && to.name !== 'login') return { name: 'login' }
  if (user.value && to.name === 'login') return { name: 'home' }
})

export default router
