import { useForm } from '@/composables/useForm';

import FormRoot from './FormRoot.vue';
import Item from './Item.vue';

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". Mirrors antd's Form API: <Form :form="form" @finish="...">
// <Form.Item name="email" label="Email"><template #default="{ field }"><Input v-bind="field" /></template></Form.Item></Form>,
// form built with Form.useForm(schema).
export const Form = Object.assign(FormRoot, { Item, useForm });
export type { FormRootProps } from './FormRoot.vue';
export type { ItemProps } from './Item.vue';
export type { FormController } from '@/composables/useForm';
