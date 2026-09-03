<script setup lang="ts">
import { ToastProvider, ToastViewport } from 'reka-ui';

import { useNotificationStore } from '@/store/notification.store';

import NotificationToast from './NotificationToast.vue';

// Mount this once near the root of the app (see App.vue) so
// notification.success()/error()/warning()/info() can be called from
// anywhere. Reusable UI ONLY — no business logic beyond wiring the store's
// queue to reka-ui's toast primitives.
const notificationStore = useNotificationStore();
</script>

<template>
  <ToastProvider swipe-direction="right">
    <NotificationToast
      v-for="item in notificationStore.notifications"
      :key="item.id"
      :item="item"
      @close="notificationStore.close(item.id)"
    />
    <ToastViewport class="fixed right-0 top-0 z-[100] flex w-96 max-w-[100vw] flex-col gap-2 p-4" />
  </ToastProvider>
</template>
