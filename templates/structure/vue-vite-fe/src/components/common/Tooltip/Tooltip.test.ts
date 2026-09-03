import { render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Tooltip } from './index';

describe('Tooltip', () => {
  it('renders the trigger element', () => {
    render(Tooltip, {
      slots: {
        default: '<button type="button">Hover me</button>',
        content: 'Helpful hint',
      },
    });
    expect(screen.getByRole('button', { name: 'Hover me' })).toBeInTheDocument();
  });

  it('shows the tooltip content on focus', async () => {
    render(Tooltip, {
      slots: {
        default: '<button type="button">Hover me</button>',
        content: 'Helpful hint',
      },
    });

    (screen.getByRole('button', { name: 'Hover me' }) as HTMLElement).focus();

    expect(await screen.findByText('Helpful hint')).toBeInTheDocument();
  });

  it('renders only the trigger when disabled', () => {
    render(Tooltip, {
      props: { disabled: true },
      slots: {
        default: '<button type="button">Hover me</button>',
        content: 'Helpful hint',
      },
    });
    expect(screen.queryByText('Helpful hint')).not.toBeInTheDocument();
  });
});
