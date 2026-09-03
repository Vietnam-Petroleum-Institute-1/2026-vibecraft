import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it, vi } from 'vitest';

import { ColorPicker } from './index';

describe('ColorPicker', () => {
  it('renders the current value on the trigger', () => {
    render(ColorPicker, { props: { value: '#1DA597' } });
    expect(screen.getByRole('button', { name: /#1DA597/i })).toBeInTheDocument();
  });

  it('shows preset swatches after opening', async () => {
    render(ColorPicker, { props: { value: '#257BF4', presets: ['#257BF4', '#EE862B'] } });

    await fireEvent.click(screen.getByRole('button', { name: /#257BF4/i }));

    expect(await screen.findByRole('button', { name: '#EE862B' })).toBeInTheDocument();
  });

  it('calls onChange with the picked preset', async () => {
    const onChange = vi.fn();
    render(ColorPicker, {
      props: { value: '#257BF4', presets: ['#257BF4', '#EE862B'], 'onUpdate:value': onChange },
    });

    await fireEvent.click(screen.getByRole('button', { name: /#257BF4/i }));
    await fireEvent.click(await screen.findByRole('button', { name: '#EE862B' }));

    expect(onChange).toHaveBeenCalledWith('#EE862B');
  });

  it('calls onChange only once a typed hex value is valid', async () => {
    const onChange = vi.fn();
    render(ColorPicker, { props: { value: '#257BF4', 'onUpdate:value': onChange } });

    await fireEvent.click(screen.getByRole('button', { name: /#257BF4/i }));
    const input = await screen.findByPlaceholderText('#RRGGBB');

    await fireEvent.update(input, '#12');
    expect(onChange).not.toHaveBeenCalled();

    await fireEvent.update(input, '#112233');
    expect(onChange).toHaveBeenCalledWith('#112233');
  });
});
