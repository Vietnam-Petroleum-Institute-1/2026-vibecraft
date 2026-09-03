import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Input } from './index';

describe('Input', () => {
  it('renders and accepts typed input', async () => {
    render(Input, { props: { placeholder: 'Email' } });
    const input = screen.getByPlaceholderText('Email');
    await fireEvent.update(input, 'a@b.com');
    expect(input).toHaveValue('a@b.com');
  });

  it('emits update:modelValue on input', async () => {
    const { emitted } = render(Input, { props: { placeholder: 'Email' } });
    await fireEvent.update(screen.getByPlaceholderText('Email'), 'x');
    expect(emitted('update:modelValue')).toBeTruthy();
  });

  it('renders prefix and suffix', () => {
    render(Input, {
      props: { placeholder: 'Search' },
      slots: { prefix: '<span>P</span>', suffix: '<span>S</span>' },
    });
    expect(screen.getByText('P')).toBeInTheDocument();
    expect(screen.getByText('S')).toBeInTheDocument();
  });

  it('is disabled when disabled prop is set', () => {
    render(Input, { props: { placeholder: 'Email', disabled: true } });
    expect(screen.getByPlaceholderText('Email')).toBeDisabled();
  });

  describe('Input.TextArea', () => {
    it('renders a textarea element', () => {
      render(Input.TextArea, { props: { placeholder: 'Description' } });
      expect(screen.getByPlaceholderText('Description').tagName).toBe('TEXTAREA');
    });
  });

  describe('Input.Password', () => {
    it('masks the value by default and toggles visibility', async () => {
      render(Input.Password, { props: { placeholder: 'Password' } });
      const input = screen.getByPlaceholderText('Password');
      expect(input).toHaveAttribute('type', 'password');

      await fireEvent.click(screen.getByRole('button', { name: 'Show password' }));
      expect(input).toHaveAttribute('type', 'text');
    });
  });
});
