<script setup lang="ts">
import { cva, type VariantProps } from 'class-variance-authority';

import { cn } from '@/utils/cn';

const textAreaVariants = cva(
  'flex w-full rounded-md border bg-background px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
  {
    variants: {
      status: {
        default: 'border-input focus-visible:ring-ring',
        error: 'border-destructive focus-visible:ring-destructive',
        warning: 'border-yellow-500 focus-visible:ring-yellow-500',
      },
    },
    defaultVariants: {
      status: 'default',
    },
  }
);

type TextAreaVariants = VariantProps<typeof textAreaVariants>;

export type TextAreaProps = {
  status?: TextAreaVariants['status'];
  className?: string;
  rows?: number;
  modelValue?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
withDefaults(defineProps<TextAreaProps>(), {
  rows: 4,
});
const emit = defineEmits<{
  'update:modelValue': [value: string];
}>();

function handleInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLTextAreaElement).value);
}
</script>

<template>
  <textarea :rows="rows" :value="modelValue" :class="cn(textAreaVariants({ status }), className)" @input="handleInput" />
</template>
