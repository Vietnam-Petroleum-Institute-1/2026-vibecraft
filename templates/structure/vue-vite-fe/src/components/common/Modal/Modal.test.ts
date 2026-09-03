import { fireEvent, render, screen } from '@testing-library/vue';
import { createPinia, setActivePinia } from 'pinia';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { useModalStore } from '@/store/modal.store';

import { Modal, ModalContainer, modal } from './index';

beforeEach(() => {
  setActivePinia(createPinia());
});

afterEach(() => {
  useModalStore().modals.splice(0, useModalStore().modals.length);
});

describe('Modal (controlled)', () => {
  it('renders its content when open', () => {
    render(Modal, {
      props: { open: true, title: 'My Modal' },
      slots: { default: 'Body content' },
    });
    expect(screen.getByText('My Modal')).toBeInTheDocument();
    expect(screen.getByText('Body content')).toBeInTheDocument();
  });

  it('does not render content when closed', () => {
    render(Modal, {
      props: { open: false, title: 'My Modal' },
      slots: { default: 'Body content' },
    });
    expect(screen.queryByText('Body content')).not.toBeInTheDocument();
  });

  it('emits update:open when the close button is clicked', async () => {
    const { emitted } = render(Modal, {
      props: { open: true, title: 'My Modal' },
      slots: { default: 'Body content' },
    });
    await fireEvent.click(screen.getByRole('button', { name: 'Close' }));
    expect(emitted('update:open')?.[0]).toEqual([false]);
  });
});

describe('Modal.confirm (imperative)', () => {
  it('renders a queued confirm modal via ModalContainer and calls onOk', async () => {
    const onOk = vi.fn();
    render(ModalContainer);

    modal.confirm({ title: 'Delete item?', content: 'This cannot be undone.', onOk });

    await fireEvent.click(await screen.findByRole('button', { name: 'OK' }));

    expect(onOk).toHaveBeenCalledTimes(1);
  });
});
