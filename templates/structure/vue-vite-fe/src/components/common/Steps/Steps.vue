<script setup lang="ts">
import { getCurrentInstance, type Component, type VNode } from 'vue';
import { Check, X } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

export type StepStatus = 'wait' | 'process' | 'finish' | 'error';

export type StepItemConfig = {
  title: string | VNode;
  description?: string | VNode;
  icon?: Component;
  // Overrides the status this step would otherwise get from its position
  // relative to `current` — for a step that failed independently of where
  // the process currently is (e.g. import row 3 errored while step 4 runs).
  status?: StepStatus;
  disabled?: boolean;
};

type StepsProps = {
  items: StepItemConfig[];
  current?: number;
  direction?: 'horizontal' | 'vertical';
  size?: 'default' | 'small';
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". Mirrors antd's Steps: an ordered list of stages in a
// process, each auto-classified wait/process/finish relative to `current`
// unless a step's own `status` overrides it (e.g. a step that failed). Pure
// presentational — no reka-ui primitive needed, matches this kit's leaf
// components (Card, Empty).
const props = withDefaults(defineProps<StepsProps>(), {
  current: 0,
  direction: 'horizontal',
  size: 'default',
  className: undefined,
});

const emit = defineEmits<{ change: [index: number] }>();

// Vue strips a declared emit's handler out of $attrs, so the only way to
// tell whether the parent actually passed @change (mirrors React's
// `!!onChange`) is to read it off the raw vnode props directly.
const instance = getCurrentInstance();
const hasChangeListener = !!(instance?.vnode.props as Record<string, unknown> | null)?.onChange;

function resolveStatus(item: StepItemConfig, index: number): StepStatus {
  if (item.status) return item.status;
  if (index < props.current) return 'finish';
  if (index === props.current) return 'process';
  return 'wait';
}

function isClickable(item: StepItemConfig): boolean {
  return hasChangeListener && !item.disabled;
}
</script>

<template>
  <div :class="cn(direction === 'horizontal' ? 'flex w-full' : 'flex flex-col gap-6', className)">
    <div
      v-for="(item, index) in items"
      :key="index"
      :class="cn(direction === 'horizontal' ? 'flex flex-1 items-start' : 'flex items-start')"
    >
      <component
        :is="isClickable(item) ? 'button' : 'div'"
        :type="isClickable(item) ? 'button' : undefined"
        :class="cn('flex items-start', isClickable(item) && 'text-left', direction === 'horizontal' && 'flex-1')"
        @click="isClickable(item) && emit('change', index)"
      >
        <div class="flex flex-col items-center">
          <span
            v-if="item.icon"
            :class="
              cn(
                'flex shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary',
                size === 'small' ? 'h-6 w-6 text-xs' : 'h-8 w-8 text-sm'
              )
            "
          >
            <component :is="item.icon" :class="size === 'small' ? 'h-3 w-3' : 'h-3.5 w-3.5'" aria-hidden="true" />
          </span>
          <span
            v-else-if="resolveStatus(item, index) === 'finish'"
            :class="
              cn(
                'flex shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground',
                size === 'small' ? 'h-6 w-6 text-xs' : 'h-8 w-8 text-sm'
              )
            "
          >
            <Check :class="size === 'small' ? 'h-3 w-3' : 'h-3.5 w-3.5'" aria-hidden="true" />
          </span>
          <span
            v-else-if="resolveStatus(item, index) === 'error'"
            :class="
              cn(
                'flex shrink-0 items-center justify-center rounded-full bg-destructive text-destructive-foreground',
                size === 'small' ? 'h-6 w-6 text-xs' : 'h-8 w-8 text-sm'
              )
            "
          >
            <X :class="size === 'small' ? 'h-3 w-3' : 'h-3.5 w-3.5'" aria-hidden="true" />
          </span>
          <span
            v-else
            :class="
              cn(
                'flex shrink-0 items-center justify-center rounded-full border font-semibold',
                size === 'small' ? 'h-6 w-6 text-xs' : 'h-8 w-8 text-sm',
                resolveStatus(item, index) === 'process' ? 'border-primary text-primary' : 'border-border text-muted-foreground'
              )
            "
          >
            {{ index + 1 }}
          </span>
          <span v-if="direction === 'vertical' && index < items.length - 1" class="mt-2 w-px flex-1 bg-border" />
        </div>
        <span :class="cn('flex min-w-0 items-center', direction === 'horizontal' ? 'ml-3' : 'ml-3 pb-6')">
          <span class="flex min-w-0 flex-col">
            <span
              :class="
                cn(
                  'truncate text-sm',
                  resolveStatus(item, index) === 'wait' ? 'text-muted-foreground' : 'font-medium text-foreground',
                  resolveStatus(item, index) === 'error' && 'text-destructive'
                )
              "
            >
              <template v-if="typeof item.title === 'string'">{{ item.title }}</template>
              <component :is="() => item.title" v-else />
            </span>
            <span v-if="item.description" class="truncate text-xs text-muted-foreground">
              <template v-if="typeof item.description === 'string'">{{ item.description }}</template>
              <component :is="() => item.description" v-else />
            </span>
          </span>
        </span>
      </component>
      <span
        v-if="direction === 'horizontal' && index < items.length - 1"
        :class="cn('mx-3 mt-4 h-px flex-1', resolveStatus(item, index) === 'finish' ? 'bg-primary' : 'bg-border')"
      />
    </div>
  </div>
</template>
