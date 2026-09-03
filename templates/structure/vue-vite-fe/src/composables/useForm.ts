import { useForm as useVeeForm } from 'vee-validate';
import { toTypedSchema } from '@vee-validate/zod';
import type { ZodType } from 'zod';

type VeeFormOptions<T extends Record<string, unknown>> = Parameters<typeof useVeeForm<T>>[0];
type VeeFormReturn<T extends Record<string, unknown>> = ReturnType<typeof useVeeForm<T>>;

export type FormController<T extends Record<string, unknown>> = VeeFormReturn<T> & {
  getFieldsValue: () => T;
  setFieldsValue: (values: Partial<T>) => void;
  setFieldValue: <K extends keyof T & string>(name: K, value: T[K]) => void;
  resetFields: (values?: Partial<T>) => void;
  validateFields: () => Promise<boolean>;
};

export function useForm<T extends Record<string, unknown>>(
  // Like the React version's `ZodType<T, any, any>`: an abstract `ZodType<T>`
  // doesn't carry enough concrete `_def` info for `toTypedSchema`'s overloads
  // — only a real schema instance (e.g. `z.object({...})`) has a concrete
  // `_def`, so Def/Input are loosened here for compatibility.
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  schema: ZodType<T, any, any>,
  options?: Omit<VeeFormOptions<T>, 'validationSchema'>
): [FormController<T>] {
  const form = useVeeForm<T>({
    ...options,
    validationSchema: toTypedSchema(schema),
  });

  const controller: FormController<T> = {
    ...form,
    getFieldsValue: () => ({ ...form.values }) as T,
    // shouldValidate: false — matches react-hook-form's setValue default
    // (no auto-validate on programmatic writes), which is the behavior
    // FormRoot/Item callers were written against. vee-validate's own
    // default for setFieldValue/setValues is to validate; it is turned
    // off here deliberately, not left implicit.
    setFieldsValue: (values) => form.setValues(values, false),
    setFieldValue: (name, value) => form.setFieldValue(name, value, false),
    resetFields: (values) => form.resetForm(values ? { values } : undefined),
    validateFields: () => form.validate().then((result) => result.valid),
  };

  return [controller];
}
