<script setup lang="ts">
import Button from './components/common/Button.vue';
import { useHealth } from './composables/useHealth';

// Sample page demonstrating the required call chain: component → composable
// → service → api.client (never fetch() directly in a component — see
// AGENTS.md "Frontend specifics").
const { health, error, check } = useHealth();
</script>

<template>
  <main class="flex min-h-screen flex-col items-center justify-center gap-4 p-24">
    <h1 class="text-2xl font-bold">[PROJECT_NAME]</h1>
    <p v-if="error" class="text-red-600">Backend unreachable: {{ error }}</p>
    <pre v-if="health" class="rounded bg-gray-100 p-4">{{ JSON.stringify(health, null, 2) }}</pre>
    <Button @click="check">Re-check backend health</Button>
  </main>
</template>
