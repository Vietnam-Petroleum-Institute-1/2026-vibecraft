import { fireEvent, render, screen, waitFor } from '@testing-library/vue';
import { defineComponent, h } from 'vue';
import { describe, expect, it, vi } from 'vitest';
import { z } from 'zod';

import { Input } from '@/components/common/Input';

import { Form } from './index';

const schema = z.object({
  email: z.string().min(1, 'Email is required').email('Invalid email'),
});

type FormValues = z.infer<typeof schema>;

const TestForm = defineComponent({
  name: 'TestForm',
  props: {
    onFinish: { type: Function as unknown as () => (values: FormValues) => void, required: true },
  },
  setup(props) {
    const [form] = Form.useForm(schema, { defaultValues: { email: '' } });

    return () =>
      h(
        Form,
        { form, onFinish: props.onFinish },
        {
          default: () => [
            h(
              Form.Item,
              { name: 'email', label: 'Email', required: true },
              {
                default: ({ field }: { field: Record<string, unknown> }) =>
                  h(Input, { ...field, placeholder: 'you@example.com' }),
              }
            ),
            h('button', { type: 'submit' }, 'Submit'),
          ],
        }
      );
  },
});

describe('Form', () => {
  it('renders the label and field', () => {
    render(TestForm, { props: { onFinish: vi.fn() } });
    expect(screen.getByText('Email')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('you@example.com')).toBeInTheDocument();
  });

  it('calls onFinish with the field values when valid', async () => {
    const onFinish = vi.fn();
    render(TestForm, { props: { onFinish } });

    await fireEvent.update(screen.getByPlaceholderText('you@example.com'), 'a@b.com');
    await fireEvent.click(screen.getByRole('button', { name: 'Submit' }));

    await waitFor(() => expect(onFinish).toHaveBeenCalledTimes(1));
    expect(onFinish.mock.calls[0][0]).toEqual({ email: 'a@b.com' });
  });

  it('shows a validation error and does not call onFinish when invalid', async () => {
    const onFinish = vi.fn();
    render(TestForm, { props: { onFinish } });

    await fireEvent.update(screen.getByPlaceholderText('you@example.com'), 'not-an-email');
    await fireEvent.click(screen.getByRole('button', { name: 'Submit' }));

    expect(await screen.findByText('Invalid email')).toBeInTheDocument();
    expect(onFinish).not.toHaveBeenCalled();
  });
});
