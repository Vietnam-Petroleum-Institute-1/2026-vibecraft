<script setup lang="ts">
import { cn } from '@/utils/cn';

export type CardProps = {
  title?: string;
  bordered?: boolean;
  hoverable?: boolean;
  size?: 'default' | 'small';
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
// Note: React's `title`/`extra` props accept ReactNode; Vue exposes them as
// `title`/`extra` named slots instead so arbitrary markup can still be
// passed, while `title` remains available as a plain-string prop for the
// simple case.
withDefaults(defineProps<CardProps>(), {
  bordered: true,
  hoverable: false,
  size: 'default',
});
</script>

<template>
  <div
    :class="
      cn(
        'rounded-lg bg-card text-card-foreground',
        bordered && 'border border-border',
        hoverable && 'transition-shadow hover:shadow-md',
        className
      )
    "
  >
    <div
      v-if="$slots.title || $slots.extra || title"
      :class="cn('flex items-center justify-between border-b border-border', size === 'small' ? 'px-3 py-2' : 'px-4 py-3')"
    >
      <div v-if="$slots.title || title" class="font-medium text-foreground">
        <slot name="title">{{ title }}</slot>
      </div>
      <div v-if="$slots.extra" class="cursor-pointer text-muted-foreground hover:text-foreground">
        <slot name="extra" />
      </div>
    </div>
    <div :class="size === 'small' ? 'p-3' : 'p-4'">
      <slot />
    </div>
    <ul v-if="$slots.actions" class="flex divide-x divide-border border-t border-border">
      <li
        v-for="(action, index) in $slots.actions()"
        :key="index"
        class="flex flex-1 cursor-pointer items-center justify-center py-2 text-muted-foreground hover:text-foreground"
      >
        <component :is="action" />
      </li>
    </ul>
  </div>
</template>
