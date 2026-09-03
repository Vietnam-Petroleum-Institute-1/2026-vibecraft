<script setup lang="ts">
import { computed, ref } from 'vue';
import {
  SelectContent,
  SelectIcon,
  SelectItem,
  SelectItemIndicator,
  SelectItemText,
  SelectPortal,
  SelectRoot,
  SelectTrigger,
  SelectValue,
  SelectViewport,
} from 'reka-ui';
import { Check, ChevronDown, X } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

export type SelectOptionConfig = {
  label: string;
  value: string;
  disabled?: boolean;
};

type SelectProps = {
  options: SelectOptionConfig[];
  value?: string;
  placeholder?: string;
  allowClear?: boolean;
  showSearch?: boolean;
  disabled?: boolean;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
};

const SELECT_TRIGGER_SIZE_CLASSES: Record<NonNullable<SelectProps['size']>, string> = {
  sm: 'h-8 pl-2.5 text-sm',
  md: 'h-10 pl-3 text-sm',
  lg: 'h-12 pl-4 text-base',
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
const props = withDefaults(defineProps<SelectProps>(), {
  value: undefined,
  placeholder: 'Select',
  allowClear: false,
  showSearch: false,
  disabled: false,
  size: 'md',
  className: undefined,
});

const emit = defineEmits<{ 'update:value': [value: string | undefined] }>();

const search = ref('');

const filteredOptions = computed(() => {
  if (!props.showSearch || !search.value.trim()) {
    return props.options;
  }
  const query = search.value.trim().toLowerCase();
  return props.options.filter((option) => option.label.toLowerCase().includes(query));
});

const showClear = computed(() => props.allowClear && !!props.value);

function handleUpdateModelValue(next: string) {
  emit('update:value', next || undefined);
}

function handleClear(event: Event) {
  event.stopPropagation();
  emit('update:value', undefined);
}
</script>

<template>
  <SelectRoot :model-value="props.value ?? ''" :disabled="props.disabled" @update:model-value="handleUpdateModelValue">
    <div class="relative">
      <SelectTrigger
        :class="
          cn(
            'flex w-full items-center rounded-md border border-input bg-background text-foreground',
            'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
            '[&>span]:line-clamp-1',
            SELECT_TRIGGER_SIZE_CLASSES[props.size],
            showClear ? 'pr-14' : 'pr-8',
            props.className
          )
        "
      >
        <SelectValue :placeholder="props.placeholder" />
        <SelectIcon as-child>
          <ChevronDown
            class="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground opacity-50"
            aria-hidden="true"
          />
        </SelectIcon>
      </SelectTrigger>
      <button
        v-if="showClear"
        type="button"
        aria-label="Clear selection"
        class="absolute right-8 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
        @pointerdown.stop
        @click="handleClear"
      >
        <X class="h-3.5 w-3.5" aria-hidden="true" />
      </button>
    </div>
    <SelectPortal>
      <SelectContent
        :class="
          cn(
            'z-50 max-h-96 w-[var(--reka-select-trigger-width)] min-w-[8rem] overflow-hidden rounded-md border border-border bg-popover text-popover-foreground shadow-md',
            'animate-in fade-in-0 zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95'
          )
        "
        position="popper"
        :side-offset="4"
      >
        <div v-if="props.showSearch" class="border-b border-border p-2">
          <input
            v-model="search"
            placeholder="Search..."
            class="w-full rounded border border-input bg-background px-2 py-1 text-sm text-foreground outline-none"
            @keydown.stop
          />
        </div>
        <SelectViewport class="p-1">
          <div v-if="filteredOptions.length === 0" class="py-6 text-center text-sm text-muted-foreground">
            No data
          </div>
          <SelectItem
            v-for="option in filteredOptions"
            :key="option.value"
            :value="option.value"
            :disabled="option.disabled"
            :class="
              cn(
                'relative flex cursor-pointer select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none',
                'focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50'
              )
            "
          >
            <span class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
              <SelectItemIndicator>
                <Check class="h-4 w-4" aria-hidden="true" />
              </SelectItemIndicator>
            </span>
            <SelectItemText>{{ option.label }}</SelectItemText>
          </SelectItem>
        </SelectViewport>
      </SelectContent>
    </SelectPortal>
  </SelectRoot>
</template>
