<script setup lang="ts">
import { ref } from 'vue';

import { Button } from '@/components/common/Button';
import { Popover } from '@/components/common/Popover';

type PopconfirmPlacement = 'top' | 'bottom' | 'left' | 'right';

type PopconfirmProps = {
  title: string;
  description?: string;
  onConfirm?: () => void;
  onCancel?: () => void;
  okText?: string;
  cancelText?: string;
  danger?: boolean;
  disabled?: boolean;
  placement?: PopconfirmPlacement;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
const props = withDefaults(defineProps<PopconfirmProps>(), {
  description: undefined,
  onConfirm: undefined,
  onCancel: undefined,
  okText: 'OK',
  cancelText: 'Cancel',
  danger: false,
  disabled: false,
  placement: 'top',
});

const open = ref(false);

function handleCancel() {
  open.value = false;
  props.onCancel?.();
}

function handleConfirm() {
  open.value = false;
  props.onConfirm?.();
}
</script>

<template>
  <slot v-if="props.disabled" />
  <Popover v-else v-model:open="open" :placement="props.placement">
    <template #trigger>
      <slot />
    </template>
    <div class="flex flex-col gap-2">
      <div class="text-sm font-medium text-foreground">{{ props.title }}</div>
      <div v-if="props.description" class="text-sm text-muted-foreground">{{ props.description }}</div>
      <div class="mt-1 flex justify-end gap-2">
        <Button size="sm" @click="handleCancel">{{ props.cancelText }}</Button>
        <Button type="primary" :danger="props.danger" size="sm" @click="handleConfirm">{{ props.okText }}</Button>
      </div>
    </div>
  </Popover>
</template>
