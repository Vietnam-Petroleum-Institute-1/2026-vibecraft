import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Select } from './index';

const options = [
  { label: 'Apple', value: 'apple' },
  { label: 'Banana', value: 'banana' },
];

describe('Select', () => {
  it('renders the placeholder when no value is selected', () => {
    render(Select, { props: { options, placeholder: 'Pick a fruit' } });
    expect(screen.getByText('Pick a fruit')).toBeInTheDocument();
  });

  it('shows the options after opening the trigger', async () => {
    render(Select, { props: { options } });

    await fireEvent.click(screen.getByRole('combobox'));

    expect(await screen.findByText('Apple')).toBeInTheDocument();
    expect(screen.getByText('Banana')).toBeInTheDocument();
  });

  it('emits update:value when an option is selected', async () => {
    const { emitted } = render(Select, { props: { options } });

    await fireEvent.click(screen.getByRole('combobox'));
    await fireEvent.click(await screen.findByText('Apple'));

    expect(emitted('update:value')?.[0]).toEqual(['apple']);
  });

  it('shows the clear button and clears the value when allowClear is set', async () => {
    const { emitted } = render(Select, { props: { options, value: 'apple', allowClear: true } });

    await fireEvent.click(screen.getByRole('button', { name: 'Clear selection' }));

    expect(emitted('update:value')?.[0]).toEqual([undefined]);
  });
});
