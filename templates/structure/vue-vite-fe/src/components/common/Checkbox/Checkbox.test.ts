import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Checkbox } from './index';

describe('Checkbox', () => {
  it('renders unchecked by default', () => {
    render(Checkbox, { props: { label: 'Bật đăng nhập OTP' } });
    expect(screen.getByRole('checkbox', { name: 'Bật đăng nhập OTP' })).not.toBeChecked();
  });

  it('reflects the checked prop', () => {
    render(Checkbox, { props: { label: 'Bật đăng nhập OTP', checked: true } });
    expect(screen.getByRole('checkbox', { name: 'Bật đăng nhập OTP' })).toBeChecked();
  });

  it('falls back to the value prop when checked is not provided (Form.Item compatibility)', () => {
    render(Checkbox, { props: { label: 'Bật đăng nhập OTP', value: true } });
    expect(screen.getByRole('checkbox', { name: 'Bật đăng nhập OTP' })).toBeChecked();
  });

  it('emits update:checked and change with the native event when toggled', async () => {
    const { emitted } = render(Checkbox, { props: { label: 'Bật đăng nhập OTP', checked: false } });

    await fireEvent.click(screen.getByRole('checkbox', { name: 'Bật đăng nhập OTP' }));

    expect(emitted('update:checked')).toBeTruthy();
    expect(emitted('update:checked')?.[0]).toEqual([true]);
    expect(emitted('change')).toHaveLength(1);
  });

  it('is disabled when disabled prop is set', () => {
    render(Checkbox, { props: { label: 'Bật đăng nhập OTP', disabled: true } });
    expect(screen.getByRole('checkbox', { name: 'Bật đăng nhập OTP' })).toBeDisabled();
  });
});
