<script setup lang="ts">
import { ref } from 'vue';
import { Upload as UploadIcon } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

type DraggerProps = {
  accept?: string;
  disabled?: boolean;
  title?: string;
  hint?: string;
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". Single-file drag-and-drop zone (click-to-browse
// fallback included) — caller owns what happens with the selected file.
const props = withDefaults(defineProps<DraggerProps>(), {
  accept: undefined,
  disabled: false,
  title: 'Kéo thả file vào đây, hoặc bấm để chọn',
  hint: undefined,
  className: undefined,
});

const emit = defineEmits<{ fileSelect: [file: File] }>();

const inputRef = ref<HTMLInputElement | null>(null);
const isDragOver = ref(false);

function openBrowser() {
  if (!props.disabled) {
    inputRef.value?.click();
  }
}

function handleInputChange(event: Event) {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (file) {
    emit('fileSelect', file);
  }
  target.value = '';
}

function handleDrop(event: DragEvent) {
  event.preventDefault();
  isDragOver.value = false;
  if (props.disabled) return;
  const file = event.dataTransfer?.files?.[0];
  if (file) {
    emit('fileSelect', file);
  }
}

function handleDragOver(event: DragEvent) {
  event.preventDefault();
  if (!props.disabled) {
    isDragOver.value = true;
  }
}

function handleDragLeave(event: DragEvent) {
  event.preventDefault();
  isDragOver.value = false;
}

function handleKeydown(event: KeyboardEvent) {
  if (event.key === 'Enter' || event.key === ' ') {
    event.preventDefault();
    openBrowser();
  }
}
</script>

<template>
  <div
    role="button"
    :tabindex="disabled ? -1 : 0"
    :aria-disabled="disabled"
    :class="
      cn(
        'flex cursor-pointer flex-col items-center gap-2 rounded-md border-2 border-dashed border-border p-8 text-center transition-colors',
        'hover:border-primary/50 hover:bg-accent/50',
        isDragOver && 'border-primary bg-accent/50',
        disabled && 'cursor-not-allowed opacity-50 hover:border-border hover:bg-transparent',
        className
      )
    "
    @click="openBrowser"
    @keydown="handleKeydown"
    @drop="handleDrop"
    @dragover="handleDragOver"
    @dragleave="handleDragLeave"
  >
    <UploadIcon class="h-8 w-8 text-muted-foreground" aria-hidden="true" />
    <p class="text-sm font-medium text-foreground">{{ title }}</p>
    <p v-if="hint" class="text-xs text-muted-foreground">{{ hint }}</p>
    <input
      ref="inputRef"
      type="file"
      :accept="accept"
      :disabled="disabled"
      class="hidden"
      @change="handleInputChange"
    />
  </div>
</template>
