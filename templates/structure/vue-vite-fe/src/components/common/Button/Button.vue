<script setup lang="ts">
import { computed } from 'vue';
import { cva, type VariantProps } from 'class-variance-authority';
import { Loader2 } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      type: {
        primary: 'bg-primary text-primary-foreground hover:bg-primary/90',
        default: 'border border-input bg-background text-foreground hover:bg-accent',
        dashed: 'border border-dashed border-input bg-background text-foreground hover:bg-accent',
        text: 'text-foreground hover:bg-accent',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      danger: {
        true: '',
        false: '',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
      },
    },
    compoundVariants: [
      { type: 'primary', danger: true, class: 'bg-destructive text-destructive-foreground hover:bg-destructive/90' },
      { type: 'default', danger: true, class: 'border-destructive text-destructive hover:bg-destructive/10' },
      { type: 'dashed', danger: true, class: 'border-destructive text-destructive hover:bg-destructive/10' },
      { type: 'text', danger: true, class: 'text-destructive hover:bg-destructive/10' },
      { type: 'link', danger: true, class: 'text-destructive' },
    ],
    defaultVariants: {
      type: 'default',
      danger: false,
      size: 'md',
    },
  }
);

type ButtonVariants = VariantProps<typeof buttonVariants>;

export type ButtonProps = {
  type?: ButtonVariants['type'];
  danger?: ButtonVariants['danger'];
  size?: ButtonVariants['size'];
  /** Native HTML button type attribute (mirrors antd's `htmlType`, since `type` here is the visual variant). */
  htmlType?: 'button' | 'submit' | 'reset';
  loading?: boolean;
  disabled?: boolean;
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". Plain <button> — no forwardRef indirection needed
// in Vue; the template ref on the component root is exposed automatically.
const props = withDefaults(defineProps<ButtonProps>(), {
  htmlType: 'button',
  loading: false,
});

const isDisabled = computed(() => props.disabled || props.loading);
const classes = computed(() => cn(buttonVariants({ type: props.type, danger: props.danger, size: props.size }), props.className));
</script>

<template>
  <button :type="htmlType" :class="classes" :disabled="isDisabled">
    <Loader2 v-if="loading" class="h-4 w-4 animate-spin" aria-hidden="true" />
    <slot v-else name="icon" />
    <slot />
  </button>
</template>
