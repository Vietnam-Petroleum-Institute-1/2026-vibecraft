import { render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Popover } from './index';

describe('Popover', () => {
  it('renders the trigger element', () => {
    render(Popover, {
      slots: {
        trigger: '<button type="button">Open</button>',
        default: '<div>Panel content</div>',
      },
    });
    expect(screen.getByRole('button', { name: 'Open' })).toBeInTheDocument();
  });

  it('shows the content after clicking the trigger', async () => {
    const { emitted } = render(Popover, {
      slots: {
        trigger: '<button type="button">Open</button>',
        default: '<div>Panel content</div>',
      },
    });

    await screen.getByRole('button', { name: 'Open' }).click();

    expect(await screen.findByText('Panel content')).toBeInTheDocument();
    expect(emitted('update:open')).toBeTruthy();
  });

  it('respects a controlled open state', async () => {
    render(Popover, {
      props: { open: true },
      slots: {
        trigger: '<button type="button">Open</button>',
        default: '<div>Panel content</div>',
      },
    });
    expect(await screen.findByText('Panel content')).toBeInTheDocument();
  });
});
