<script setup lang="ts">
import { computed, useId } from 'vue';
import { Check } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

export type CheckboxProps = {
  checked?: boolean;
  /** Alias for `checked` — lets a generic value/onChange field-spread pattern (e.g. a Form.Item) work unmodified. */
  value?: boolean;
  label?: string;
  className?: string;
  disabled?: boolean;
  id?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". React's `onChange` (native ChangeEvent callback prop)
// becomes a Vue `update:checked` + `change` emit pair so this works both as
// a `v-model:checked` binding and as a plain change-event listener.
// Also emits `update:value` (mirroring the `value` alias prop above) so
// Form/Item.vue's generic `{ value, 'onUpdate:value' }` field-spread works
// unmodified here too — every other common/ input-like component treats
// `value`/`update:value` as its field-spread contract, and Checkbox must
// honor it even though `checked`/`update:checked` is its own idiomatic API.
const props = defineProps<CheckboxProps>();
const emit = defineEmits<{
  'update:checked': [checked: boolean];
  'update:value': [checked: boolean];
  change: [event: Event];
}>();

const autoId = useId();
const inputId = computed(() => props.id ?? autoId);
const isChecked = computed(() => props.checked ?? props.value ?? false);

function handleChange(event: Event) {
  const target = event.target as HTMLInputElement;
  emit('update:checked', target.checked);
  emit('update:value', target.checked);
  emit('change', event);
}
</script>

<template>
  <label
    :for="inputId"
    :class="
      cn(
        'inline-flex items-center gap-2 text-sm text-foreground',
        disabled ? 'cursor-not-allowed opacity-50' : 'cursor-pointer',
        className
      )
    "
  >
    <span class="relative flex h-4 w-4 shrink-0 items-center justify-center">
      <input
        :id="inputId"
        type="checkbox"
        :checked="isChecked"
        :disabled="disabled"
        class="peer h-4 w-4 shrink-0 cursor-pointer appearance-none rounded-sm border border-input bg-background transition-colors checked:border-primary checked:bg-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed"
        @change="handleChange"
      />
      <Check
        class="pointer-events-none absolute h-3 w-3 text-primary-foreground opacity-0 peer-checked:opacity-100"
        aria-hidden="true"
      />
    </span>
    <span v-if="label">{{ label }}</span>
  </label>
</template>
