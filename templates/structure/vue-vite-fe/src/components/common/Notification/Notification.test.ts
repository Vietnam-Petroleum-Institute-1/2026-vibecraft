import { fireEvent, render, screen } from '@testing-library/vue';
import { createPinia, setActivePinia } from 'pinia';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import { useNotificationStore } from '@/store/notification.store';

import { NotificationContainer, notification } from './index';

beforeEach(() => {
  setActivePinia(createPinia());
});

afterEach(() => {
  const store = useNotificationStore();
  store.notifications.splice(0, store.notifications.length);
});

describe('notification (imperative)', () => {
  it('renders a queued success notification', async () => {
    render(NotificationContainer);

    notification.success({ message: 'Saved successfully' });

    expect(await screen.findByText('Saved successfully')).toBeInTheDocument();
  });

  it('renders the description when provided', async () => {
    render(NotificationContainer);

    notification.error({ message: 'Save failed', description: 'Please try again.' });

    expect(await screen.findByText('Save failed')).toBeInTheDocument();
    expect(screen.getByText('Please try again.')).toBeInTheDocument();
  });

  it('removes the notification from the store when closed', async () => {
    render(NotificationContainer);

    notification.info({ message: 'Heads up' });
    await screen.findByText('Heads up');

    await fireEvent.click(screen.getByRole('button', { name: 'Close' }));

    expect(useNotificationStore().notifications).toHaveLength(0);
  });

  it('renders a countdown bar animated over the notification duration, with no numeric label', async () => {
    render(NotificationContainer);

    notification.success({ message: 'Saved', duration: 6000 });
    const toast = (await screen.findByText('Saved')).closest('[data-state]') as HTMLElement;

    const bar = toast.querySelector('[data-testid="notification-countdown-bar"]') as HTMLElement;
    expect(bar).toBeInTheDocument();
    expect(bar.style.animationDuration).toBe('6000ms');
    expect(bar.style.animationName).toBe('toast-countdown');
    // No number/time text anywhere in the toast — purely visual per spec.
    expect(toast.textContent).not.toMatch(/\d/);
  });

  it('pauses the countdown bar animation while the toast is hovered', async () => {
    render(NotificationContainer);

    notification.info({ message: 'Hover me' });
    const toast = (await screen.findByText('Hover me')).closest('[data-state]') as HTMLElement;
    const bar = toast.querySelector('[data-testid="notification-countdown-bar"]') as HTMLElement;

    await fireEvent.pointerMove(toast);
    expect(bar.style.animationPlayState).toBe('paused');

    // reka-ui's pause/resume listeners live on the viewport region (role
    // "region"), not the individual toast — pointerleave doesn't bubble,
    // so it must fire on that exact node to trigger resume.
    await fireEvent.pointerLeave(screen.getByRole('region'));
    expect(bar.style.animationPlayState).toBe('running');
  });
});
