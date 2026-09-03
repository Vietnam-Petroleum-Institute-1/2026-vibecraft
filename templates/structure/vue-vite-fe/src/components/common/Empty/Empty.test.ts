import { render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Empty } from './index';

describe('Empty', () => {
  it('renders the default description', () => {
    render(Empty);
    expect(screen.getByText('No data')).toBeInTheDocument();
  });

  it('renders a custom description', () => {
    render(Empty, { props: { description: 'No users found' } });
    expect(screen.getByText('No users found')).toBeInTheDocument();
  });

  it('renders extra children below the description', () => {
    render(Empty, {
      props: { description: 'No users found' },
      slots: { default: '<button type="button">Create user</button>' },
    });
    expect(screen.getByRole('button', { name: 'Create user' })).toBeInTheDocument();
  });
});
