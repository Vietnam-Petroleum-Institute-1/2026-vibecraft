<script setup lang="ts">
import { ref, watch } from 'vue';
import { ChevronDown } from 'lucide-vue-next';

import { Input } from '@/components/common/Input';
import { Popover } from '@/components/common/Popover';
import { hexToHsv, hsvToHex, hueToHex, isValidHex, type HSV } from '@/utils/color';
import { cn } from '@/utils/cn';

export type ColorPickerProps = {
  presets?: string[];
  disabled?: boolean;
  className?: string;
};

defineProps<ColorPickerProps>();

// `value` is a v-model so Form/Item.vue can bind it the same way it binds
// any other field (`v-model:value="field.value"`), mirroring how the React
// version's <Item> clones `value`/`onChange` onto the child.
const value = defineModel<string>('value');

function currentOf(v: string | undefined) {
  return v && isValidHex(v) ? v : '#257BF4';
}

const current = ref(currentOf(value.value));
const hsv = ref<HSV>(hexToHsv(current.value));
const hexDraft = ref(current.value);

watch(
  () => value.value,
  (next) => {
    const resolved = currentOf(next);
    current.value = resolved;
    hsv.value = hexToHsv(resolved);
    hexDraft.value = resolved;
  }
);

function commitHsv(next: HSV) {
  hsv.value = next;
  const hex = hsvToHex(next);
  hexDraft.value = hex;
  current.value = hex;
  value.value = hex;
}

function commitHex(next: string) {
  hexDraft.value = next;
  if (isValidHex(next)) {
    hsv.value = hexToHsv(next);
    current.value = next;
    value.value = next;
  }
}

const svRef = ref<HTMLDivElement | null>(null);
const hueRef = ref<HTMLDivElement | null>(null);

function dragSv(event: PointerEvent) {
  const el = svRef.value;
  if (!el) return;
  el.setPointerCapture(event.pointerId);
  const move = (e: PointerEvent) => {
    const rect = el.getBoundingClientRect();
    const s = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width));
    const v = 1 - Math.min(1, Math.max(0, (e.clientY - rect.top) / rect.height));
    commitHsv({ ...hsv.value, s, v });
  };
  move(event);
  const up = () => window.removeEventListener('pointermove', move);
  window.addEventListener('pointermove', move);
  window.addEventListener('pointerup', up, { once: true });
}

function dragHue(event: PointerEvent) {
  const el = hueRef.value;
  if (!el) return;
  el.setPointerCapture(event.pointerId);
  const move = (e: PointerEvent) => {
    const rect = el.getBoundingClientRect();
    const h = Math.min(1, Math.max(0, (e.clientX - rect.left) / rect.width)) * 360;
    commitHsv({ ...hsv.value, h });
  };
  move(event);
  const up = () => window.removeEventListener('pointermove', move);
  window.addEventListener('pointermove', move);
  window.addEventListener('pointerup', up, { once: true });
}
</script>

<template>
  <Popover className="w-64">
    <template #trigger>
      <button
        type="button"
        :disabled="disabled"
        :class="
          cn(
            'flex h-10 w-full items-center gap-2 rounded-md border border-input bg-background px-3 text-sm text-foreground',
            'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
            className
          )
        "
      >
        <span class="h-5 w-5 shrink-0 rounded-full border border-border" :style="{ backgroundColor: current }" aria-hidden="true" />
        <span class="flex-1 text-left font-mono uppercase">{{ current }}</span>
        <ChevronDown class="h-4 w-4 shrink-0 opacity-50" aria-hidden="true" />
      </button>
    </template>
    <template #default>
      <div class="flex flex-col gap-3">
        <!-- Saturation/Value panel -->
        <div
          ref="svRef"
          class="relative h-32 w-full cursor-crosshair touch-none rounded-md"
          :style="{
            backgroundColor: hueToHex(hsv.h),
            backgroundImage: 'linear-gradient(to top, #000, transparent), linear-gradient(to right, #fff, transparent)',
          }"
          @pointerdown="dragSv"
        >
          <span
            class="absolute h-3 w-3 -translate-x-1/2 translate-y-1/2 rounded-full border-2 border-white shadow"
            :style="{ left: `${hsv.s * 100}%`, bottom: `${hsv.v * 100}%`, backgroundColor: current }"
          />
        </div>

        <!-- Hue slider -->
        <div
          ref="hueRef"
          class="relative h-3 w-full cursor-pointer touch-none rounded-full"
          style="background: linear-gradient(to right, #f00, #ff0, #0f0, #0ff, #00f, #f0f, #f00)"
          @pointerdown="dragHue"
        >
          <span
            class="absolute top-1/2 h-4 w-4 -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white shadow"
            :style="{ left: `${(hsv.h / 360) * 100}%`, backgroundColor: hueToHex(hsv.h) }"
          />
        </div>

        <Input :model-value="hexDraft" placeholder="#RRGGBB" className="font-mono uppercase" @update:model-value="commitHex">
          <template #prefix>
            <span
              class="h-4 w-4 rounded-full border border-border"
              :style="{ backgroundColor: isValidHex(hexDraft) ? hexDraft : 'transparent' }"
            />
          </template>
        </Input>

        <div v-if="presets && presets.length > 0" class="flex flex-wrap gap-2 border-t border-border pt-3">
          <button
            v-for="preset in presets"
            :key="preset"
            type="button"
            :aria-label="preset"
            :class="
              cn(
                'h-6 w-6 shrink-0 rounded-full border transition-shadow',
                preset.toLowerCase() === current.toLowerCase()
                  ? 'border-foreground ring-2 ring-ring ring-offset-2'
                  : 'border-border hover:scale-110'
              )
            "
            :style="{ backgroundColor: preset }"
            @click="commitHex(preset)"
          />
        </div>
      </div>
    </template>
  </Popover>
</template>
