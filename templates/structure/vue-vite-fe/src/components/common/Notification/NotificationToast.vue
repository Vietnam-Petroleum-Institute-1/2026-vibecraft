<script setup lang="ts">
import { ref, type Component } from 'vue';
import { ToastClose, ToastDescription, ToastRoot, ToastTitle } from 'reka-ui';
import { AlertTriangle, CheckCircle2, Info, X, XCircle } from 'lucide-vue-next';

import { cn } from '@/utils/cn';
import { type NotificationConfig, type NotificationType } from '@/store/notification.store';

const DEFAULT_DURATION_MS = 4500;

const iconByType: Record<NotificationType, Component> = {
  success: CheckCircle2,
  error: XCircle,
  warning: AlertTriangle,
  info: Info,
};

const iconClassByType: Record<NotificationType, string> = {
  success: 'text-green-500',
  error: 'text-destructive',
  warning: 'text-yellow-500',
  info: 'text-primary',
};

const barColorByType: Record<NotificationType, string> = {
  success: 'bg-green-500',
  error: 'bg-destructive',
  warning: 'bg-yellow-500',
  info: 'bg-primary',
};

// Internal per-toast renderer for NotificationContainer's queue. Not part of
// the public API — imported only by NotificationContainer.vue. Split out so
// each toast owns its own "is the pointer hovering it" state — reka-ui's
// ToastRoot `pause`/`resume` events already drive the real dismiss timer
// (built into the primitive), this just mirrors that into the countdown
// bar's CSS animation so both stay in sync without re-implementing the timer
// itself.
defineProps<{ item: NotificationConfig }>();
const emit = defineEmits<{ close: [] }>();

const paused = ref(false);

function handleOpenChange(open: boolean) {
  if (!open) {
    emit('close');
  }
}
</script>

<template>
  <ToastRoot
    :duration="item.duration ?? DEFAULT_DURATION_MS"
    @update:open="handleOpenChange"
    @pause="paused = true"
    @resume="paused = false"
    :class="
      cn(
        'relative grid grid-cols-[auto_1fr_auto] items-start gap-3 overflow-hidden rounded-md border border-border bg-background p-4 shadow-lg',
        'data-[state=open]:animate-in data-[state=open]:slide-in-from-right-full data-[state=closed]:animate-out data-[state=closed]:fade-out-80'
      )
    "
  >
    <component :is="iconByType[item.type]" :class="cn('h-5 w-5 shrink-0', iconClassByType[item.type])" aria-hidden="true" />
    <div class="grid gap-1">
      <ToastTitle class="text-sm font-medium text-foreground">
        <template v-if="typeof item.message === 'string'">{{ item.message }}</template>
        <component :is="() => item.message" v-else />
      </ToastTitle>
      <ToastDescription v-if="item.description" class="text-sm text-muted-foreground">
        <template v-if="typeof item.description === 'string'">{{ item.description }}</template>
        <component :is="() => item.description" v-else />
      </ToastDescription>
    </div>
    <ToastClose aria-label="Close" class="text-muted-foreground hover:text-foreground">
      <X class="h-4 w-4" aria-hidden="true" />
    </ToastClose>
    <!-- Right edge recedes toward the fixed left edge — empty means time's
         up. No numbers by design, purely visual. -->
    <div
      aria-hidden="true"
      data-testid="notification-countdown-bar"
      :class="cn('absolute inset-x-0 bottom-0 h-1 origin-left opacity-90', barColorByType[item.type])"
      :style="{
        animationName: 'toast-countdown',
        animationDuration: `${item.duration ?? DEFAULT_DURATION_MS}ms`,
        animationTimingFunction: 'linear',
        animationFillMode: 'forwards',
        animationPlayState: paused ? 'paused' : 'running',
      }"
    />
  </ToastRoot>
</template>
