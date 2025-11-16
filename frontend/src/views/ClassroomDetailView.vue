<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/services/supabase'

const route = useRoute()
const router = useRouter()

const classroom = ref<any>(null)
const assignments = ref<any[]>([])
const loading = ref(true)

const loadClassroom = async () => {
  try {
    const { data, error } = await supabase
      .from('google_classrooms')
      .select('*')
      .eq('id', route.params.id)
      .maybeSingle()

    if (error) throw error
    classroom.value = data

    const { data: assignmentsData, error: assignmentsError } = await supabase
      .from('assignments')
      .select('*')
      .eq('classroom_id', route.params.id)
      .order('created_at', { ascending: false })

    if (assignmentsError) throw assignmentsError
    assignments.value = assignmentsData || []
  } catch (error) {
    console.error('Error loading classroom:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadClassroom()
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
            <router-link to="/classrooms" class="text-sm text-gray-600 hover:text-gray-900">
              Classrooms
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-500">Loading...</p>
      </div>

      <div v-else-if="classroom">
        <div class="mb-8">
          <h2 class="text-3xl font-bold text-gray-900 mb-2">{{ classroom.name }}</h2>
          <p v-if="classroom.section" class="text-gray-600">{{ classroom.section }}</p>
          <p v-if="classroom.description" class="text-gray-500 mt-2">{{ classroom.description }}</p>
        </div>

        <div class="bg-white rounded-lg shadow">
          <div class="p-6 border-b border-gray-200">
            <h3 class="text-xl font-semibold text-gray-900">Assignments</h3>
          </div>

          <div v-if="assignments.length === 0" class="p-6">
            <p class="text-gray-500 text-center">No assignments found</p>
          </div>

          <div v-else class="divide-y divide-gray-200">
            <div
              v-for="assignment in assignments"
              :key="assignment.id"
              class="p-6 hover:bg-gray-50 cursor-pointer transition-colors"
              @click="router.push(`/assignments/${assignment.id}`)"
            >
              <h4 class="text-lg font-medium text-gray-900">{{ assignment.title }}</h4>
              <p v-if="assignment.description" class="text-sm text-gray-500 mt-1">{{ assignment.description }}</p>
              <div class="flex items-center mt-2 text-sm text-gray-600">
                <span>Max Points: {{ assignment.max_points }}</span>
                <span v-if="assignment.due_date" class="ml-4">
                  Due: {{ new Date(assignment.due_date).toLocaleDateString() }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-12">
        <p class="text-gray-500">Classroom not found</p>
      </div>
    </main>
  </div>
</template>
