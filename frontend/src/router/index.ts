import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/HomeView.vue')
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue')
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('@/views/DashboardView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/classrooms',
      name: 'classrooms',
      component: () => import('@/views/ClassroomsView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/classrooms/:id',
      name: 'classroom-detail',
      component: () => import('@/views/ClassroomDetailView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/assignments/:id',
      name: 'assignment-detail',
      component: () => import('@/views/AssignmentDetailView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/grading/:assignmentId',
      name: 'grading',
      component: () => import('@/views/GradingView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/auth/callback',
      name: 'auth-callback',
      component: () => import('@/views/AuthCallbackView.vue')
    }
  ]
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth && !authStore.user) {
    next({ name: 'login' })
  } else if (to.name === 'login' && authStore.user) {
    next({ name: 'dashboard' })
  } else {
    next()
  }
})

export default router
