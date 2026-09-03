import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it } from 'vitest';

import { Pagination } from './index';

describe('Pagination', () => {
  it('renders the total record count', () => {
    render(Pagination, { props: { page: 1, size: 10, total: 42 } });
    expect(screen.getByText('Tổng: 42 bản ghi')).toBeInTheDocument();
  });

  it('disables the previous button on the first page', () => {
    render(Pagination, { props: { page: 1, size: 10, total: 42 } });
    expect(screen.getByText('Trước').closest('button')).toBeDisabled();
  });

  it('disables the next button on the last page', () => {
    render(Pagination, { props: { page: 5, size: 10, total: 42 } });
    expect(screen.getByText('Sau').closest('button')).toBeDisabled();
  });

  it('emits page-change when a page number is clicked', async () => {
    const { emitted } = render(Pagination, { props: { page: 1, size: 10, total: 42 } });

    await fireEvent.click(screen.getByText('3'));

    expect(emitted('page-change')?.[0]).toEqual([3]);
  });

  it('emits page-change when jumping to a valid page', async () => {
    const { emitted } = render(Pagination, { props: { page: 1, size: 10, total: 42 } });

    await fireEvent.update(screen.getByPlaceholderText('Trang'), '4');
    await fireEvent.click(screen.getByText('Đi tới'));

    expect(emitted('page-change')?.[0]).toEqual([4]);
  });

  it('does not emit page-change when the jump target is out of range', async () => {
    const { emitted } = render(Pagination, { props: { page: 1, size: 10, total: 42 } });

    await fireEvent.update(screen.getByPlaceholderText('Trang'), '99');
    await fireEvent.click(screen.getByText('Đi tới'));

    expect(emitted('page-change')).toBeUndefined();
  });

  it('does not emit page-change when the jump target is not a number', async () => {
    const { emitted } = render(Pagination, { props: { page: 1, size: 10, total: 42 } });

    await fireEvent.update(screen.getByPlaceholderText('Trang'), 'abc');
    await fireEvent.click(screen.getByText('Đi tới'));

    expect(emitted('page-change')).toBeUndefined();
  });

  it('emits size-change when the page size is changed', async () => {
    const { emitted } = render(Pagination, {
      props: { page: 1, size: 10, total: 42, pageSizeOptions: [10, 20] },
    });

    await fireEvent.click(screen.getByRole('combobox'));
    await fireEvent.click(await screen.findByText('20 / trang'));

    expect(emitted('size-change')?.[0]).toEqual([20]);
  });
});
