<script setup lang="ts">
import { ref } from 'vue';
import { Eye, EyeOff } from 'lucide-vue-next';

import Input, { type InputProps } from './Input.vue';

export type PasswordProps = Omit<InputProps, 'type'>;

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
defineProps<PasswordProps>();
defineEmits<{
  'update:modelValue': [value: string];
}>();

const visible = ref(false);
</script>

<template>
  <Input v-bind="$props" :type="visible ? 'text' : 'password'" @update:model-value="$emit('update:modelValue', $event)">
    <template #suffix>
      <button
        type="button"
        tabindex="-1"
        :aria-label="visible ? 'Hide password' : 'Show password'"
        class="flex items-center text-muted-foreground hover:text-foreground"
        @click="visible = !visible"
      >
        <EyeOff v-if="visible" class="h-4 w-4" aria-hidden="true" />
        <Eye v-else class="h-4 w-4" aria-hidden="true" />
      </button>
    </template>
  </Input>
</template>
