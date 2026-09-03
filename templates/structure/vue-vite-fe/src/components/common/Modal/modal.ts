import { type ModalConfig, useModalStore } from '@/store/modal.store';

type StaticModalConfig = Omit<ModalConfig, 'id' | 'type'>;

function openModal(type: ModalConfig['type'], config: StaticModalConfig) {
  return useModalStore().open({ showCancel: type === 'confirm', ...config, type });
}

// Purely imperative, like antd's `Modal.confirm/info/success/error/warning`
// — call from anywhere (including outside a component), pushes onto the
// modal store's queue. See ModalContainer.vue for how the queued config
// gets rendered. Kept as a plain object (not attached to the Modal.vue SFC
// default export, unlike React's `Object.assign(ModalBase, {...})`) because
// a Vue SFC's default export is a component definition, not a callable that
// static methods can hang off cleanly — this mirrors the notification.ts /
// NotificationContainer.vue split already used in this kit.
export const modal = {
  confirm: (config: StaticModalConfig) => openModal('confirm', config),
  info: (config: StaticModalConfig) => openModal('info', config),
  success: (config: StaticModalConfig) => openModal('success', config),
  error: (config: StaticModalConfig) => openModal('error', config),
  warning: (config: StaticModalConfig) => openModal('warning', config),
  close: (id: string) => useModalStore().close(id),
};
