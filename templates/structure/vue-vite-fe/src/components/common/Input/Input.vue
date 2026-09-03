<script setup lang="ts">
import { computed } from 'vue';
import { cva, type VariantProps } from 'class-variance-authority';

import { cn } from '@/utils/cn';

const inputVariants = cva(
  'flex w-full rounded-md border bg-background text-sm text-foreground placeholder:text-muted-foreground transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
  {
    variants: {
      status: {
        default: 'border-input focus-visible:ring-ring',
        error: 'border-destructive focus-visible:ring-destructive',
        warning: 'border-yellow-500 focus-visible:ring-yellow-500',
      },
      size: {
        sm: 'h-8 px-2.5 text-sm',
        md: 'h-10 px-3 text-sm',
        lg: 'h-12 px-4 text-base',
      },
    },
    defaultVariants: {
      status: 'default',
      size: 'md',
    },
  }
);

type InputVariants = VariantProps<typeof inputVariants>;

export type InputProps = {
  status?: InputVariants['status'];
  size?: InputVariants['size'];
  className?: string;
  disabled?: boolean;
  type?: string;
  modelValue?: string | number;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". React's `value`/`onChange` pair becomes a Vue
// `v-model` (`modelValue` prop + `update:modelValue` emit) — Password.vue
// and consumers use `v-model` the same way React consumers used
// `value`/`onChange`. `prefix`/`suffix` (React ReactNode props) become
// named slots since Vue slots are the idiomatic way to pass markup.
defineProps<InputProps>();
const emit = defineEmits<{
  'update:modelValue': [value: string];
}>();

function handleInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLInputElement).value);
}
</script>

<template>
  <input
    v-if="!$slots.prefix && !$slots.suffix"
    :type="type ?? 'text'"
    :disabled="disabled"
    :value="modelValue"
    :class="cn(inputVariants({ status, size }), className)"
    @input="handleInput"
  />
  <div
    v-else
    :class="
      cn(
        inputVariants({ status, size }),
        'flex items-center gap-2 px-3',
        disabled && 'cursor-not-allowed opacity-50',
        className
      )
    "
  >
    <span v-if="$slots.prefix" class="flex items-center text-muted-foreground">
      <slot name="prefix" />
    </span>
    <input
      :type="type ?? 'text'"
      :disabled="disabled"
      :value="modelValue"
      class="w-full border-none bg-transparent p-0 text-sm text-foreground outline-none placeholder:text-muted-foreground disabled:cursor-not-allowed"
      @input="handleInput"
    />
    <span v-if="$slots.suffix" class="flex items-center text-muted-foreground">
      <slot name="suffix" />
    </span>
  </div>
</template>
