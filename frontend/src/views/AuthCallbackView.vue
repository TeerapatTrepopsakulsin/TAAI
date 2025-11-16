<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

onMounted(async () => {
  setTimeout(() => {
    router.push('/dashboard')
  }, 1000)
})
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="text-center">
      <h2 class="text-2xl font-semibold text-gray-900 mb-4">Signing you in...</h2>
      <p class="text-gray-600">Please wait while we complete authentication</p>
    </div>
  </div>
</template>
