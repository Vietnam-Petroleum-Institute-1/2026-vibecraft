import { render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Card } from './index';

describe('Card', () => {
  it('renders its children', () => {
    render(Card, { slots: { default: 'Body content' } });
    expect(screen.getByText('Body content')).toBeInTheDocument();
  });

  it('renders title and extra when provided', () => {
    render(Card, {
      props: { title: 'My Card' },
      slots: { extra: '<span>More</span>', default: 'Body' },
    });
    expect(screen.getByText('My Card')).toBeInTheDocument();
    expect(screen.getByText('More')).toBeInTheDocument();
  });

  it('does not render a header when title and extra are absent', () => {
    render(Card, { slots: { default: 'Body' } });
    expect(screen.queryByText('My Card')).not.toBeInTheDocument();
  });

  it('renders actions in the footer', () => {
    render(Card, {
      slots: {
        default: 'Body',
        actions: '<span>Edit</span><span>Delete</span>',
      },
    });
    expect(screen.getByText('Edit')).toBeInTheDocument();
    expect(screen.getByText('Delete')).toBeInTheDocument();
  });
});
