<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '@/services/supabase'

const route = useRoute()

const assignment = ref<any>(null)
const submissions = ref<any[]>([])
const loading = ref(true)

const loadData = async () => {
  try {
    const { data: assignmentData, error: assignmentError } = await supabase
      .from('assignments')
      .select('*')
      .eq('id', route.params.assignmentId)
      .maybeSingle()

    if (assignmentError) throw assignmentError
    assignment.value = assignmentData

    const { data: submissionsData, error: submissionsError } = await supabase
      .from('submissions')
      .select('*, users(*)')
      .eq('assignment_id', route.params.assignmentId)

    if (submissionsError) throw submissionsError
    submissions.value = submissionsData || []
  } catch (error) {
    console.error('Error loading data:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
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
          <h2 class="text-3xl font-bold text-gray-900 mb-2">Grade Submissions</h2>
          <p class="text-gray-600">{{ assignment.title }}</p>
        </div>

        <div class="bg-white rounded-lg shadow">
          <div class="p-6 border-b border-gray-200">
            <h3 class="text-xl font-semibold text-gray-900">Submissions ({{ submissions.length }})</h3>
          </div>

          <div v-if="submissions.length === 0" class="p-6">
            <p class="text-gray-500 text-center">No submissions to grade</p>
          </div>

          <div v-else class="divide-y divide-gray-200">
            <div
              v-for="submission in submissions"
              :key="submission.id"
              class="p-6 hover:bg-gray-50 transition-colors"
            >
              <div class="flex justify-between items-start">
                <div>
                  <h4 class="text-lg font-medium text-gray-900">
                    {{ submission.users?.name || 'Student' }}
                  </h4>
                  <p class="text-sm text-gray-600">
                    Submitted: {{ new Date(submission.submitted_at).toLocaleString() }}
                  </p>
                  <span
                    v-if="submission.is_late"
                    class="inline-block mt-2 px-2 py-1 text-xs font-medium text-red-700 bg-red-100 rounded"
                  >
                    Late
                  </span>
                </div>
                <button
                  class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 transition-colors"
                >
                  Grade
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
