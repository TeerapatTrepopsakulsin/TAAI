<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const goToDashboard = () => {
  if (authStore.user) {
    router.push('/dashboard')
  } else {
    router.push('/login')
  }
}
</script>

<template>
  <div class="min-h-screen flex flex-col">
    <nav class="bg-white shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">TAAI</h1>
          </div>
          <div class="flex items-center">
            <button
              @click="goToDashboard"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 transition-colors"
            >
              {{ authStore.user ? 'Dashboard' : 'Sign In' }}
            </button>
          </div>
        </div>
      </div>
    </nav>

    <main class="flex-1 flex flex-col items-center justify-center px-4">
      <div class="text-center max-w-3xl">
        <h2 class="text-5xl font-bold text-gray-900 mb-6">
          AI-Powered Grading for Google Classroom
        </h2>
        <p class="text-xl text-gray-600 mb-8 leading-relaxed">
          Automate assignment grading with AI, integrate seamlessly with Google Classroom,
          and provide consistent, detailed feedback to your students.
        </p>
        <button
          @click="goToDashboard"
          class="px-8 py-4 text-lg font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors shadow-lg hover:shadow-xl"
        >
          Get Started
        </button>
      </div>

      <div class="mt-20 grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl">
        <div class="bg-white p-6 rounded-lg shadow-md">
          <h3 class="text-xl font-semibold text-gray-900 mb-3">Smart Grading</h3>
          <p class="text-gray-600">
            AI analyzes student submissions and applies customizable grading criteria automatically.
          </p>
        </div>
        <div class="bg-white p-6 rounded-lg shadow-md">
          <h3 class="text-xl font-semibold text-gray-900 mb-3">Google Classroom</h3>
          <p class="text-gray-600">
            Seamlessly sync assignments and grades with Google Classroom courses.
          </p>
        </div>
        <div class="bg-white p-6 rounded-lg shadow-md">
          <h3 class="text-xl font-semibold text-gray-900 mb-3">Multi-Instructor</h3>
          <p class="text-gray-600">
            Grade assignments from any instructor in your shared courses.
          </p>
        </div>
      </div>
    </main>

    <footer class="bg-white border-t border-gray-200 mt-20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <p class="text-center text-gray-500 text-sm">
          TAAI - The AI Grader © 2025
        </p>
      </div>
    </footer>
  </div>
</template>
