import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it, vi } from 'vitest';

import { Button } from './index';

describe('Button', () => {
  it('renders its children', () => {
    render(Button, { slots: { default: 'Click me' } });
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('renders with the default variant classes', () => {
    render(Button, { slots: { default: 'Default' } });
    expect(screen.getByRole('button', { name: 'Default' })).toHaveClass('border-input');
  });

  it('calls onClick when clicked', async () => {
    const onClick = vi.fn();
    render(Button, { attrs: { onClick }, slots: { default: 'Submit' } });

    await fireEvent.click(screen.getByRole('button', { name: 'Submit' }));

    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled and does not fire onClick when loading', async () => {
    const onClick = vi.fn();
    render(Button, { props: { loading: true }, attrs: { onClick }, slots: { default: 'Saving' } });

    const button = screen.getByRole('button', { name: 'Saving' });
    expect(button).toBeDisabled();

    await fireEvent.click(button);
    expect(onClick).not.toHaveBeenCalled();
  });

  it('applies destructive styling when danger is true', () => {
    render(Button, { props: { type: 'primary', danger: true }, slots: { default: 'Delete' } });
    expect(screen.getByRole('button', { name: 'Delete' })).toHaveClass('bg-destructive');
  });
});
