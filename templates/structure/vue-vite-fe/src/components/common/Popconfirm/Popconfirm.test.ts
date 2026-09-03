import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it, vi } from 'vitest';

import { Popconfirm } from './index';

describe('Popconfirm', () => {
  it('renders the trigger element', () => {
    render(Popconfirm, {
      props: { title: 'Delete this item?' },
      slots: { default: '<button type="button">Delete</button>' },
    });
    expect(screen.getByRole('button', { name: 'Delete' })).toBeInTheDocument();
  });

  it('shows the confirmation title after clicking the trigger', async () => {
    render(Popconfirm, {
      props: { title: 'Delete this item?' },
      slots: { default: '<button type="button">Delete</button>' },
    });

    await fireEvent.click(screen.getByRole('button', { name: 'Delete' }));

    expect(await screen.findByText('Delete this item?')).toBeInTheDocument();
  });

  it('calls onConfirm when the confirm button is clicked', async () => {
    const onConfirm = vi.fn();
    render(Popconfirm, {
      props: { title: 'Delete this item?', onConfirm },
      slots: { default: '<button type="button">Delete</button>' },
    });

    await fireEvent.click(screen.getByRole('button', { name: 'Delete' }));
    await fireEvent.click(await screen.findByRole('button', { name: 'OK' }));

    expect(onConfirm).toHaveBeenCalledTimes(1);
  });

  it('calls onCancel when the cancel button is clicked', async () => {
    const onCancel = vi.fn();
    render(Popconfirm, {
      props: { title: 'Delete this item?', onCancel },
      slots: { default: '<button type="button">Delete</button>' },
    });

    await fireEvent.click(screen.getByRole('button', { name: 'Delete' }));
    await fireEvent.click(await screen.findByRole('button', { name: 'Cancel' }));

    expect(onCancel).toHaveBeenCalledTimes(1);
  });
});
