<script setup lang="ts">
import { useField } from 'vee-validate';

import { cn } from '@/utils/cn';

// PORT NOTE (React -> Vue divergence): the React version clones the single
// child element and injects `value`/`onChange` onto it directly
// (`cloneElement(children, field)`), which has no Vue equivalent for an
// arbitrary child. The Vue idiom is a scoped default slot exposing a
// `field` object shaped like a v-model binding (`value` + `onUpdate:value`),
// which the consumer spreads onto its input with `v-bind="field"`:
//
//   <Form.Item name="email" label="Email" required>
//     <template #default="{ field }">
//       <Input v-bind="field" />
//     </template>
//   </Form.Item>
//
// This relies on vee-validate's `useField` picking up the form context that
// `useForm()` auto-provides (via Vue's provide/inject) in the component that
// called `Form.useForm(...)` — no explicit `<FormProvider>` wrapper is
// needed in Vue, unlike react-hook-form's `FormProvider`.
export type ItemProps = {
  name: string;
  label?: string;
  required?: boolean;
  className?: string;
};

const props = defineProps<ItemProps>();

const { value, errorMessage, handleChange } = useField<unknown>(() => props.name);
</script>

<template>
  <div :class="cn('flex flex-col gap-1.5', className)">
    <label v-if="label" class="text-sm font-medium text-foreground">
      {{ label }}
      <span v-if="required" class="ml-0.5 text-destructive">*</span>
    </label>
    <slot :field="{ value, 'onUpdate:value': handleChange }" />
    <span v-if="errorMessage" class="text-xs text-destructive">{{ errorMessage }}</span>
  </div>
</template>
