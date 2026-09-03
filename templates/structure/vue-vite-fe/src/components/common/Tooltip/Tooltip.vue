<script setup lang="ts">
import { TooltipArrow, TooltipContent, TooltipPortal, TooltipProvider, TooltipRoot, TooltipTrigger } from 'reka-ui';

import { cn } from '@/utils/cn';

type TooltipPlacement = 'top' | 'bottom' | 'left' | 'right';

type TooltipProps = {
  placement?: TooltipPlacement;
  disabled?: boolean;
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
const props = withDefaults(defineProps<TooltipProps>(), {
  placement: 'top',
  disabled: false,
  className: undefined,
});
</script>

<template>
  <slot v-if="props.disabled" />
  <TooltipProvider v-else :delay-duration="200">
    <TooltipRoot>
      <TooltipTrigger as-child>
        <slot />
      </TooltipTrigger>
      <TooltipPortal>
        <TooltipContent
          :side="props.placement"
          :side-offset="6"
          :class="
            cn(
              'z-50 overflow-hidden rounded-md bg-foreground px-3 py-1.5 text-xs text-background',
              'animate-in fade-in-0 zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95',
              props.className
            )
          "
        >
          <slot name="content" />
          <TooltipArrow class="fill-foreground" />
        </TooltipContent>
      </TooltipPortal>
    </TooltipRoot>
  </TooltipProvider>
</template>
