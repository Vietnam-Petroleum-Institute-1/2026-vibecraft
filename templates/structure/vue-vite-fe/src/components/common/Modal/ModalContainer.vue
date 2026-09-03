<script setup lang="ts">
import type { Component } from 'vue';
import { AlertTriangle, CheckCircle2, HelpCircle, Info, XCircle } from 'lucide-vue-next';

import { cn } from '@/utils/cn';
import { Button } from '@/components/common/Button';
import { type ModalConfig, type ModalType, useModalStore } from '@/store/modal.store';

import Modal from './Modal.vue';

const iconByType: Record<ModalType, Component> = {
  confirm: HelpCircle,
  info: Info,
  success: CheckCircle2,
  error: XCircle,
  warning: AlertTriangle,
};

const iconClassByType: Record<ModalType, string> = {
  confirm: 'text-primary',
  info: 'text-primary',
  success: 'text-green-500',
  error: 'text-destructive',
  warning: 'text-yellow-500',
};

// Mount this once near the root of the app (see App.vue) so
// modal.confirm()/info()/success()/error()/warning() can be called from
// anywhere. Reusable UI ONLY — no business logic beyond wiring the store's
// queue to the presentational Modal.
const modalStore = useModalStore();

function handleOpenChange(modal: ModalConfig, next: boolean) {
  if (!next) {
    modalStore.close(modal.id);
    modal.onCancel?.();
  }
}

function handleCancel(modal: ModalConfig) {
  modalStore.close(modal.id);
  modal.onCancel?.();
}

async function handleOk(modal: ModalConfig) {
  await modal.onOk?.();
  modalStore.close(modal.id);
}
</script>

<template>
  <Modal
    v-for="item in modalStore.modals"
    :key="item.id"
    :open="true"
    :closable="false"
    :title="item.title"
    @update:open="handleOpenChange(item, $event)"
  >
    <div class="flex gap-3">
      <component :is="iconByType[item.type]" :class="cn('h-6 w-6 shrink-0', iconClassByType[item.type])" aria-hidden="true" />
      <div class="flex-1 pt-0.5">
        <template v-if="typeof item.content === 'string'">{{ item.content }}</template>
        <component :is="() => item.content" v-else-if="item.content" />
      </div>
    </div>
    <template #footer>
      <Button v-if="item.showCancel" @click="handleCancel(item)">{{ item.cancelText ?? 'Cancel' }}</Button>
      <Button type="primary" :danger="item.danger" @click="handleOk(item)">{{ item.okText ?? 'OK' }}</Button>
    </template>
  </Modal>
</template>
