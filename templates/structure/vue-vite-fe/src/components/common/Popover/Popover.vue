<script setup lang="ts">
import { PopoverArrow, PopoverContent, PopoverPortal, PopoverRoot, PopoverTrigger } from 'reka-ui';

import { cn } from '@/utils/cn';

type PopoverPlacement = 'top' | 'bottom' | 'left' | 'right';

type PopoverProps = {
  open?: boolean;
  defaultOpen?: boolean;
  placement?: PopoverPlacement;
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
const props = withDefaults(defineProps<PopoverProps>(), {
  open: undefined,
  defaultOpen: undefined,
  placement: 'bottom',
  className: undefined,
});

const emit = defineEmits<{ 'update:open': [open: boolean] }>();
</script>

<template>
  <PopoverRoot :open="props.open" :default-open="props.defaultOpen" @update:open="emit('update:open', $event)">
    <PopoverTrigger as-child>
      <slot name="trigger" />
    </PopoverTrigger>
    <PopoverPortal>
      <PopoverContent
        :side="props.placement"
        :side-offset="6"
        :class="
          cn(
            'z-50 w-72 rounded-md border border-border bg-popover p-4 text-popover-foreground shadow-md outline-none',
            'animate-in fade-in-0 zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95',
            props.className
          )
        "
      >
        <slot />
        <PopoverArrow class="fill-popover" />
      </PopoverContent>
    </PopoverPortal>
  </PopoverRoot>
</template>
