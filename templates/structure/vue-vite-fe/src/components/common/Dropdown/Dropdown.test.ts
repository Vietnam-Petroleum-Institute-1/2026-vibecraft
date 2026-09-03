import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it, vi } from 'vitest';

import { Dropdown } from './index';

describe('Dropdown', () => {
  it('renders the trigger element', () => {
    render(Dropdown, {
      props: { menu: { items: [{ key: 'edit', label: 'Edit' }] } },
      slots: { default: '<button type="button">Actions</button>' },
    });
    expect(screen.getByRole('button', { name: 'Actions' })).toBeInTheDocument();
  });

  it('shows menu items after clicking the trigger', async () => {
    render(Dropdown, {
      props: {
        menu: { items: [{ key: 'edit', label: 'Edit' }, { key: 'delete', label: 'Delete', danger: true }] },
      },
      slots: { default: '<button type="button">Actions</button>' },
    });

    await fireEvent.pointerDown(screen.getByRole('button', { name: 'Actions' }), { button: 0 });

    expect(await screen.findByText('Edit')).toBeInTheDocument();
    expect(screen.getByText('Delete')).toBeInTheDocument();
  });

  it('calls the item onClick when selected', async () => {
    const onClick = vi.fn();
    render(Dropdown, {
      props: { menu: { items: [{ key: 'edit', label: 'Edit', onClick }] } },
      slots: { default: '<button type="button">Actions</button>' },
    });

    await fireEvent.pointerDown(screen.getByRole('button', { name: 'Actions' }), { button: 0 });
    await fireEvent.click(await screen.findByText('Edit'));

    expect(onClick).toHaveBeenCalledTimes(1);
  });
});
