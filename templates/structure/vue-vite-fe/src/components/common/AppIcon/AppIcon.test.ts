import { render } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { AppIcon } from './index';

describe('AppIcon', () => {
  it('renders the icon for a known name', () => {
    const { container } = render(AppIcon, { props: { name: 'database' } });
    expect(container.querySelector('svg')).toBeTruthy();
  });

  it('falls back to the default icon for an unknown name', () => {
    const { container } = render(AppIcon, { props: { name: 'not-a-real-icon' } });
    expect(container.querySelector('svg')).toBeTruthy();
  });

  it('falls back to the default icon when name is null/undefined', () => {
    const { container } = render(AppIcon, { props: {} });
    expect(container.querySelector('svg')).toBeTruthy();
  });

  it('applies the className prop to the rendered svg', () => {
    const { container } = render(AppIcon, { props: { name: 'database', className: 'h-4 w-4' } });
    expect(container.querySelector('svg')).toHaveClass('h-4', 'w-4');
  });
});
