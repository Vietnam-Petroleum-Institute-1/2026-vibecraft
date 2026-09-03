<script setup lang="ts">
import type { VNode } from 'vue';
import { DialogClose, DialogContent, DialogOverlay, DialogPortal, DialogRoot, DialogTitle } from 'reka-ui';
import { X } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

type ModalProps = {
  open: boolean;
  title?: string | VNode;
  closable?: boolean;
  width?: number | string;
  className?: string;
  /** Pass null to hide the footer row entirely (matches React's footer={null}). */
  hideFooter?: boolean;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". Controlled usage: <Modal v-model:open="open">...
// Imperative usage: openModal/confirmModal/... (see modal.ts) — see
// ModalContainer for how the queued config gets rendered.
const props = withDefaults(defineProps<ModalProps>(), {
  title: undefined,
  closable: true,
  width: 480,
  className: undefined,
  hideFooter: false,
});

const emit = defineEmits<{ 'update:open': [open: boolean] }>();

function handleOpenChange(next: boolean) {
  emit('update:open', next);
}
</script>

<template>
  <DialogRoot :open="props.open" @update:open="handleOpenChange">
    <DialogPortal>
      <DialogOverlay
        :class="
          cn(
            'fixed inset-0 z-50 bg-black/50',
            'data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:duration-200 data-[state=open]:ease-out',
            'data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:duration-150 data-[state=closed]:ease-in'
          )
        "
      />
      <DialogContent
        :style="{ width: typeof props.width === 'number' ? `${props.width}px` : props.width }"
        :class="
          cn(
            'fixed left-1/2 top-1/2 z-50 flex max-h-[85vh] max-w-[90vw] -translate-x-1/2 -translate-y-1/2 flex-col rounded-lg border border-border bg-background p-6 shadow-lg',
            'data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 data-[state=open]:slide-in-from-top-2 data-[state=open]:duration-200 data-[state=open]:ease-out',
            'data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=closed]:slide-out-to-top-2 data-[state=closed]:duration-150 data-[state=closed]:ease-in',
            props.className
          )
        "
      >
        <DialogTitle v-if="props.title" class="mb-4 shrink-0 pr-6 text-lg font-semibold text-foreground">
          <template v-if="typeof props.title === 'string'">{{ props.title }}</template>
          <component :is="() => props.title" v-else />
        </DialogTitle>
        <DialogTitle v-else class="sr-only">Dialog</DialogTitle>
        <!-- min-h-0 lets this shrink inside the flex column instead of forcing the dialog past the viewport — without it a tall form (e.g. AppFormModal) renders with its bottom fields unreachable, no scroll. -->
        <div class="min-h-0 overflow-y-auto text-sm text-foreground">
          <slot />
        </div>
        <div v-if="!props.hideFooter" class="mt-6 flex shrink-0 justify-end gap-2">
          <slot name="footer" />
        </div>
        <DialogClose
          v-if="props.closable"
          aria-label="Close"
          class="absolute right-4 top-4 rounded-sm text-muted-foreground opacity-70 hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring"
        >
          <X class="h-4 w-4" aria-hidden="true" />
        </DialogClose>
      </DialogContent>
    </DialogPortal>
  </DialogRoot>
</template>
