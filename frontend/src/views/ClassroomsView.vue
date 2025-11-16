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
            <router-link to="/dashboard" class="text-2xl font-bold text-gray-900">TAAI</router-link>
          </div>
          <div class="flex items-center space-x-4">
            <router-link
              to="/dashboard"
              class="text-sm text-gray-600 hover:text-gray-900"
            >
              Dashboard
            </router-link>
            <span class="text-sm text-gray-600">{{ authStore.user?.email }}</span>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8">
        <h2 class="text-3xl font-bold text-gray-900 mb-2">Classrooms</h2>
        <p class="text-gray-600">Manage your Google Classroom courses</p>
      </div>

      <div v-if="loading" class="bg-white rounded-lg shadow p-8">
        <p class="text-gray-500 text-center">Loading classrooms...</p>
      </div>

      <div v-else-if="classrooms.length === 0" class="bg-white rounded-lg shadow p-8">
        <p class="text-gray-500 text-center">No classrooms found. Connect your Google Classroom account to get started.</p>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="classroom in classrooms"
          :key="classroom.id"
          class="bg-white rounded-lg shadow hover:shadow-lg transition-shadow cursor-pointer"
          @click="router.push(`/classrooms/${classroom.id}`)"
        >
          <div class="p-6">
            <h3 class="text-xl font-semibold text-gray-900 mb-2">{{ classroom.name }}</h3>
            <p v-if="classroom.section" class="text-sm text-gray-600 mb-1">{{ classroom.section }}</p>
            <p v-if="classroom.description" class="text-sm text-gray-500 line-clamp-2">{{ classroom.description }}</p>
            <div class="mt-4 pt-4 border-t border-gray-200">
              <span class="text-xs text-gray-500">
                Created {{ new Date(classroom.created_at).toLocaleDateString() }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
