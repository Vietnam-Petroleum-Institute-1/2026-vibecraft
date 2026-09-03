import type { VNode } from 'vue';
import { defineStore } from 'pinia';

export type NotificationType = 'success' | 'error' | 'warning' | 'info';

export type NotificationConfig = {
  id: string;
  type: NotificationType;
  message: string | VNode;
  description?: string | VNode;
  duration?: number;
};

type NotificationStoreState = {
  notifications: NotificationConfig[];
};

// Backs notification's imperative API (notification.success/error/warning/info)
// — a queue any code can push into, rendered once by
// <NotificationContainer/> mounted in App.vue.
export const useNotificationStore = defineStore('notification', {
  state: (): NotificationStoreState => ({
    notifications: [],
  }),
  actions: {
    open(config: Omit<NotificationConfig, 'id'>): string {
      const id = crypto.randomUUID();
      this.notifications.push({ ...config, id });
      return id;
    },
    close(id: string): void {
      this.notifications = this.notifications.filter((notification) => notification.id !== id);
    },
  },
});
