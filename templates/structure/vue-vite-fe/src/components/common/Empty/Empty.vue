<script setup lang="ts">
import { cn } from '@/utils/cn';

export type EmptyProps = {
  description?: string;
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
withDefaults(defineProps<EmptyProps>(), {
  description: 'No data',
});
</script>

<template>
  <div :class="cn('flex flex-col items-center justify-center gap-3 py-10', className)">
    <slot name="image">
      <svg class="h-16 w-16 text-muted-foreground" viewBox="0 0 64 41" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <path
          d="M55.5 12.5L44.5 1H19.5L8.5 12.5"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
        <rect x="0.75" y="12.75" width="62.5" height="27.5" rx="3.25" stroke="currentColor" stroke-width="1.5" />
        <path
          d="M0.75 25H19a3 3 0 0 1 2.83 2H41.17a3 3 0 0 1 2.83-2h18.25"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-linecap="round"
        />
      </svg>
    </slot>
    <div v-if="description" class="text-sm text-muted-foreground">{{ description }}</div>
    <slot />
  </div>
</template>
