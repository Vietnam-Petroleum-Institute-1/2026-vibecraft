import type { VNode } from 'vue';
import { defineStore } from 'pinia';

export type ModalType = 'confirm' | 'info' | 'success' | 'error' | 'warning';

export type ModalConfig = {
  id: string;
  type: ModalType;
  title?: string | VNode;
  content?: string | VNode;
  okText?: string;
  cancelText?: string;
  danger?: boolean;
  showCancel?: boolean;
  onOk?: () => void | Promise<void>;
  onCancel?: () => void;
};

type ModalStoreState = {
  modals: ModalConfig[];
};

// Backs Modal's imperative API (Modal.confirm/info/success/error/warning) —
// a queue any code can push into (including outside a component's setup,
// e.g. a catch block), rendered once by <ModalContainer/> mounted in App.vue.
export const useModalStore = defineStore('modal', {
  state: (): ModalStoreState => ({
    modals: [],
  }),
  actions: {
    open(config: Omit<ModalConfig, 'id'>): string {
      const id = crypto.randomUUID();
      this.modals.push({ ...config, id });
      return id;
    },
    close(id: string): void {
      this.modals = this.modals.filter((modal) => modal.id !== id);
    },
  },
});
