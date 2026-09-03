<script setup lang="ts" generic="T extends Record<string, unknown>">
import type { FormController } from '@/composables/useForm';

export type FormRootProps<T extends Record<string, unknown> = Record<string, unknown>> = {
  form: FormController<T>;
  onFinish?: (values: T) => void;
  onFinishFailed?: (errors: unknown) => void;
  /** Lets an external button submit this form via `<button form={id}>` — e.g. a Modal footer action. */
  id?: string;
  className?: string;
};

const props = defineProps<FormRootProps<T>>();
</script>

<template>
  <form :id="props.id" novalidate :class="props.className" @submit="props.form.handleSubmit(props.onFinish ?? (() => {}), props.onFinishFailed)">
    <slot />
  </form>
</template>
