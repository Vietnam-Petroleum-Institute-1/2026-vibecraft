import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Menu } from './index';

describe('Menu', () => {
  it('renders top-level items', () => {
    render(Menu, { props: { items: [{ key: 'home', label: 'Home' }, { key: 'users', label: 'Users' }] } });
    expect(screen.getByText('Home')).toBeInTheDocument();
    expect(screen.getByText('Users')).toBeInTheDocument();
  });

  it('emits select when a leaf item is clicked', async () => {
    const { emitted } = render(Menu, { props: { items: [{ key: 'home', label: 'Home' }] } });
    await fireEvent.click(screen.getByText('Home'));
    expect(emitted('select')?.[0]).toEqual(['home']);
  });

  it('expands a submenu instead of selecting when it has children', async () => {
    const { emitted } = render(Menu, {
      props: {
        items: [{ key: 'settings', label: 'Settings', children: [{ key: 'profile', label: 'Profile' }] }],
      },
    });

    expect(screen.queryByText('Profile')).not.toBeInTheDocument();

    await fireEvent.click(screen.getByText('Settings'));

    expect(screen.getByText('Profile')).toBeInTheDocument();
    expect(emitted('select')).toBeUndefined();
  });

  it('highlights the selected key', () => {
    render(Menu, { props: { items: [{ key: 'home', label: 'Home' }], selectedKeys: ['home'] } });
    expect(screen.getByText('Home').closest('button')).toHaveClass('text-primary');
  });
});
