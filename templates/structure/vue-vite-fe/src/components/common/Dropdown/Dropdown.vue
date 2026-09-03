<script setup lang="ts">
import { computed, type Component } from 'vue';
import { DropdownMenuContent, DropdownMenuPortal, DropdownMenuRoot, DropdownMenuTrigger } from 'reka-ui';

import { cn } from '@/utils/cn';

import DropdownMenuItems from './DropdownMenuItems.vue';

export type DropdownMenuItemConfig =
  | {
      type: 'divider';
      key: string;
    }
  | {
      type?: 'item';
      key: string;
      label: string;
      icon?: Component;
      disabled?: boolean;
      danger?: boolean;
      onClick?: () => void;
      children?: DropdownMenuItemConfig[];
    };

type DropdownPlacement = 'bottom-start' | 'bottom-end' | 'top-start' | 'top-end';

type DropdownProps = {
  menu: { items: DropdownMenuItemConfig[] };
  placement?: DropdownPlacement;
  disabled?: boolean;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
const props = withDefaults(defineProps<DropdownProps>(), {
  placement: 'bottom-start',
  disabled: false,
});

const contentSideAlign = computed(() => {
  switch (props.placement) {
    case 'bottom-end':
      return { side: 'bottom' as const, align: 'end' as const };
    case 'top-start':
      return { side: 'top' as const, align: 'start' as const };
    case 'top-end':
      return { side: 'top' as const, align: 'end' as const };
    case 'bottom-start':
    default:
      return { side: 'bottom' as const, align: 'start' as const };
  }
});
</script>

<template>
  <DropdownMenuRoot>
    <DropdownMenuTrigger as-child :disabled="props.disabled">
      <slot />
    </DropdownMenuTrigger>
    <DropdownMenuPortal>
      <DropdownMenuContent
        :side="contentSideAlign.side"
        :align="contentSideAlign.align"
        :side-offset="6"
        :class="
          cn(
            'z-50 min-w-[8rem] overflow-hidden rounded-md border border-border bg-popover p-1 text-popover-foreground shadow-md',
            'animate-in fade-in-0 zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95'
          )
        "
      >
        <DropdownMenuItems :items="props.menu.items" />
      </DropdownMenuContent>
    </DropdownMenuPortal>
  </DropdownMenuRoot>
</template>
