<script setup lang="ts">
import { computed, ref } from 'vue';
import { ChevronDown, Search } from 'lucide-vue-next';

import { AppIcon } from '@/components/common/AppIcon';
import { Input } from '@/components/common/Input';
import { Popover } from '@/components/common/Popover';
import { cn } from '@/utils/cn';
import { DEFAULT_ICON_NAME, ICON_KEYS, SUGGESTED_ICON_NAMES } from '@/utils/icon-registry';

export type IconPickerFieldProps = {
  disabled?: boolean;
};

defineProps<IconPickerFieldProps>();

// `value` is a v-model so Form/Item.vue can bind it the same way it binds
// any other field, mirroring the React version's cloneElement(children, field).
const value = defineModel<string>('value');

const current = computed(() => (value.value && ICON_KEYS.includes(value.value) ? value.value : DEFAULT_ICON_NAME));
const query = ref('');

// Static curated list (~160 icons) — filtering is instant, no
// network/lazy-load involved, so no debounce needed.
const results = computed(() => {
  const q = query.value.trim().toLowerCase();
  if (!q) return SUGGESTED_ICON_NAMES;
  return ICON_KEYS.filter((name) => name.includes(q));
});

function pick(name: string) {
  value.value = name;
}
</script>

<template>
  <Popover className="w-72">
    <template #trigger>
      <button
        type="button"
        :disabled="disabled"
        :class="
          cn(
            'flex h-10 w-full items-center gap-2 rounded-md border border-input bg-background px-3 text-sm text-foreground',
            'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50'
          )
        "
      >
        <AppIcon :name="current" className="h-4 w-4 shrink-0 text-muted-foreground" />
        <span class="flex-1 text-left">{{ current }}</span>
        <ChevronDown class="h-4 w-4 shrink-0 opacity-50" aria-hidden="true" />
      </button>
    </template>
    <template #default>
      <div class="flex flex-col gap-2">
        <Input :model-value="query" placeholder="Tìm icon (vd: chart, ship, factory...)" @update:model-value="query = $event">
          <template #prefix>
            <Search class="h-4 w-4" aria-hidden="true" />
          </template>
        </Input>
        <div class="grid max-h-56 grid-cols-6 gap-1 overflow-y-auto">
          <button
            v-for="name in results"
            :key="name"
            type="button"
            :title="name"
            :aria-label="name"
            :class="
              cn(
                'flex h-9 w-9 items-center justify-center rounded-md border transition-colors',
                name === current ? 'border-primary bg-primary/5 text-primary' : 'border-border text-muted-foreground hover:bg-accent'
              )
            "
            @click="pick(name)"
          >
            <AppIcon :name="name" className="h-4 w-4" />
          </button>
          <p v-if="results.length === 0" class="col-span-6 py-4 text-center text-xs text-muted-foreground">
            Không tìm thấy icon phù hợp.
          </p>
        </div>
      </div>
    </template>
  </Popover>
</template>
