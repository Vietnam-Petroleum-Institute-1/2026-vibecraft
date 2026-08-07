<script setup lang="ts">
withDefaults(defineProps<{ variant?: 'primary' | 'secondary' }>(), {
  variant: 'primary',
});
</script>

<template>
  <!-- Reusable UI ONLY — no business logic, no API calls. See AGENTS.md "Frontend specifics". -->
  <button
    class="rounded px-4 py-2 font-medium transition-colors"
    :class="
      variant === 'primary'
        ? 'bg-blue-600 text-white hover:bg-blue-700'
        : 'bg-gray-200 text-gray-900 hover:bg-gray-300'
    "
  >
    <slot />
  </button>
</template>
