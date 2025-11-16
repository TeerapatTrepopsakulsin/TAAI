<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/services/supabase'

const router = useRouter()
const authStore = useAuthStore()

const classrooms = ref<any[]>([])
const loading = ref(true)

const loadClassrooms = async () => {
  try {
    const { data, error } = await supabase
      .from('google_classrooms')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    classrooms.value = data || []
  } catch (error) {
    console.error('Error loading classrooms:', error)
  } finally {
    loading.value = false
  }
}

const handleSignOut = async () => {
  await authStore.signOut()
  router.push('/login')
}

onMounted(() => {
  loadClassrooms()
})
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">TAAI</h1>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-600">{{ authStore.user?.email }}</span>
            <button
              @click="handleSignOut"
              class="px-4 py-2 text-sm font-medium text-gray-700 hover:text-gray-900"
            >
              Sign Out
            </button>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8">
        <h2 class="text-3xl font-bold text-gray-900 mb-2">Dashboard</h2>
        <p class="text-gray-600">Manage your classrooms and assignments</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Total Classrooms</h3>
          <p class="text-3xl font-bold text-blue-600">{{ classrooms.length }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Assignments</h3>
          <p class="text-3xl font-bold text-green-600">0</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Graded Submissions</h3>
          <p class="text-3xl font-bold text-orange-600">0</p>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow">
        <div class="p-6 border-b border-gray-200">
          <div class="flex justify-between items-center">
            <h3 class="text-xl font-semibold text-gray-900">Your Classrooms</h3>
            <router-link
              to="/classrooms"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 transition-colors"
            >
              View All
            </router-link>
          </div>
        </div>

        <div v-if="loading" class="p-6">
          <p class="text-gray-500 text-center">Loading classrooms...</p>
        </div>

        <div v-else-if="classrooms.length === 0" class="p-6">
          <p class="text-gray-500 text-center">No classrooms found. Connect your Google Classroom account to get started.</p>
        </div>

        <div v-else class="divide-y divide-gray-200">
          <div
            v-for="classroom in classrooms.slice(0, 5)"
            :key="classroom.id"
            class="p-6 hover:bg-gray-50 cursor-pointer transition-colors"
            @click="router.push(`/classrooms/${classroom.id}`)"
          >
            <h4 class="text-lg font-medium text-gray-900">{{ classroom.name }}</h4>
            <p v-if="classroom.section" class="text-sm text-gray-600">{{ classroom.section }}</p>
            <p v-if="classroom.description" class="text-sm text-gray-500 mt-1">{{ classroom.description }}</p>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
