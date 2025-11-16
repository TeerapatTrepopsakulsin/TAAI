<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/services/supabase'

const route = useRoute()
const router = useRouter()

const assignment = ref<any>(null)
const loading = ref(true)

const loadAssignment = async () => {
  try {
    const { data, error } = await supabase
      .from('assignments')
      .select('*, google_classrooms(*)')
      .eq('id', route.params.id)
      .maybeSingle()

    if (error) throw error
    assignment.value = data
  } catch (error) {
    console.error('Error loading assignment:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadAssignment()
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
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-500">Loading...</p>
      </div>

      <div v-else-if="assignment">
        <div class="mb-8">
          <h2 class="text-3xl font-bold text-gray-900 mb-2">{{ assignment.title }}</h2>
          <p v-if="assignment.description" class="text-gray-600">{{ assignment.description }}</p>
          <div class="flex items-center mt-4 text-sm text-gray-600">
            <span>Max Points: {{ assignment.max_points }}</span>
            <span v-if="assignment.due_date" class="ml-4">
              Due: {{ new Date(assignment.due_date).toLocaleDateString() }}
            </span>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Grading Criteria</h3>
            <p class="text-gray-500">No criteria defined yet</p>
          </div>

          <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Submissions</h3>
            <p class="text-gray-500">No submissions yet</p>
            <button
              @click="router.push(`/grading/${assignment.id}`)"
              class="mt-4 px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 transition-colors"
            >
              Start Grading
            </button>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-12">
        <p class="text-gray-500">Assignment not found</p>
      </div>
    </main>
  </div>
</template>
