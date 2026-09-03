<script setup lang="ts">
import { ref, watch } from 'vue';
import { Loader2, Trash2, Upload } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

import { Button } from '@/components/common/Button';
import { Modal } from '@/components/common/Modal';
import { Popconfirm } from '@/components/common/Popconfirm';

const DEFAULT_FALLBACK = '/images/image-placeholder.svg';

type ImgStatus = 'loading' | 'loaded' | 'error';

export type ImageProps = {
  src?: string | null;
  alt: string;
  fallback?: string;
  width?: number | string;
  height?: number | string;
  className?: string;
  preview?: boolean;
  disabled?: boolean;
  onUpload?: (file: File) => void | Promise<void>;
  onRemove?: () => void | Promise<void>;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". `onUpload`/`onRemove` are caller-supplied handlers
// (backed by a services/*.service.ts) — this component never calls an API.
// React's useState/useEffect (status/previewOpen/uploading/removing) become
// Vue refs + a `watch` on `src`.
const props = withDefaults(defineProps<ImageProps>(), {
  fallback: DEFAULT_FALLBACK,
  preview: true,
  disabled: false,
});

const status = ref<ImgStatus>(props.src ? 'loading' : 'error');
const previewOpen = ref(false);
const uploading = ref(false);
const removing = ref(false);
const fileInputRef = ref<HTMLInputElement | null>(null);

watch(
  () => props.src,
  (src) => {
    status.value = src ? 'loading' : 'error';
  }
);

const displaySrc = () => (status.value === 'error' || !props.src ? props.fallback : props.src);
const busy = () => uploading.value || removing.value;
const canPreview = () => props.preview && !props.disabled && status.value !== 'error';

async function handleFileChange(event: Event) {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  target.value = '';
  if (!file || !props.onUpload) return;

  try {
    uploading.value = true;
    await props.onUpload(file);
  } finally {
    uploading.value = false;
  }
}

async function handleRemove() {
  if (!props.onRemove) return;
  try {
    removing.value = true;
    await props.onRemove();
  } finally {
    removing.value = false;
  }
}
</script>

<template>
  <div
    :class="cn('group relative overflow-hidden rounded-md border border-border bg-muted', className)"
    :style="{ width, height }"
  >
    <div v-if="status === 'loading'" class="absolute inset-0 flex items-center justify-center bg-muted">
      <Loader2 class="h-5 w-5 animate-spin text-muted-foreground" aria-hidden="true" />
    </div>

    <button
      v-if="canPreview()"
      type="button"
      class="block h-full w-full cursor-pointer p-0"
      :aria-label="`Preview ${alt}`"
      @click="previewOpen = true"
    >
      <img
        :src="displaySrc()"
        :alt="alt"
        :class="cn('h-full w-full object-cover', status === 'loading' && 'opacity-0')"
        @load="status = 'loaded'"
        @error="status = 'error'"
      />
    </button>
    <img
      v-else
      :src="displaySrc()"
      :alt="alt"
      :class="cn('h-full w-full object-cover', status === 'loading' && 'opacity-0')"
      @load="status = 'loaded'"
      @error="status = 'error'"
    />

    <div v-if="busy()" class="absolute inset-0 flex items-center justify-center bg-black/40">
      <Loader2 class="h-5 w-5 animate-spin text-white" aria-hidden="true" />
    </div>

    <div
      v-if="!disabled && (onUpload || onRemove) && !busy()"
      class="absolute inset-x-0 bottom-0 flex items-center justify-center gap-2 bg-black/50 py-1.5 opacity-0 transition-opacity group-hover:opacity-100"
    >
      <template v-if="onUpload">
        <Button
          type="text"
          size="sm"
          class="h-7 w-7 p-0 text-white hover:bg-white/20 hover:text-white"
          aria-label="Upload image"
          @click="fileInputRef?.click()"
        >
          <template #icon><Upload class="h-4 w-4" aria-hidden="true" /></template>
        </Button>
        <input ref="fileInputRef" type="file" accept="image/*" class="hidden" @change="handleFileChange" />
      </template>
      <Popconfirm v-if="onRemove" title="Remove this image?" danger ok-text="Remove" @confirm="handleRemove">
        <Button
          type="text"
          size="sm"
          danger
          class="h-7 w-7 p-0 text-white hover:bg-white/20 hover:text-white"
          aria-label="Remove image"
        >
          <template #icon><Trash2 class="h-4 w-4" aria-hidden="true" /></template>
        </Button>
      </Popconfirm>
    </div>

    <Modal v-if="canPreview()" v-model:open="previewOpen" hide-footer width="auto">
      <img :src="displaySrc()" :alt="alt" class="max-h-[80vh] max-w-[80vw] object-contain" />
    </Modal>
  </div>
</template>
