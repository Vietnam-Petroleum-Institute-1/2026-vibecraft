import { fireEvent, render, screen } from '@testing-library/vue';
import { describe, expect, it, vi } from 'vitest';

import { Table, type TableColumn } from './index';

type User = { id: number; name: string; age: number };

const columns: TableColumn<User>[] = [
  { key: 'name', title: 'Name', dataIndex: 'name' },
  { key: 'age', title: 'Age', dataIndex: 'age', sorter: (a, b) => a.age - b.age },
];

const dataSource: User[] = [
  { id: 1, name: 'Alice', age: 30 },
  { id: 2, name: 'Bob', age: 25 },
];

describe('Table', () => {
  it('renders rows from dataSource', () => {
    render(Table, { props: { columns, dataSource, rowKey: 'id' } });
    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
  });

  it('shows Empty when dataSource is empty', () => {
    render(Table, { props: { columns, dataSource: [], rowKey: 'id', emptyText: 'No users' } });
    expect(screen.getByText('No users')).toBeInTheDocument();
  });

  it('shows a loading state', () => {
    render(Table, { props: { columns, dataSource, rowKey: 'id', loading: true } });
    expect(screen.getByText('Loading...')).toBeInTheDocument();
    expect(screen.queryByText('Alice')).not.toBeInTheDocument();
  });

  it('sorts rows when clicking a sortable column header', async () => {
    render(Table, { props: { columns, dataSource, rowKey: 'id' } });

    await fireEvent.click(screen.getByText('Age'));

    const rows = screen.getAllByRole('row').slice(1);
    expect(rows[0]).toHaveTextContent('Bob');
    expect(rows[1]).toHaveTextContent('Alice');
  });

  it('calls pagination.onChange when the next page button is clicked', async () => {
    const onChange = vi.fn();
    render(Table, {
      props: { columns, dataSource, rowKey: 'id', pagination: { current: 1, pageSize: 10, total: 20, onChange } },
    });

    await fireEvent.click(screen.getByText('Sau'));

    expect(onChange).toHaveBeenCalledWith(2, 10);
  });

  it('calls onRowClick with the record when a row is clicked', async () => {
    const onRowClick = vi.fn();
    render(Table, { props: { columns, dataSource, rowKey: 'id', onRowClick } });

    await fireEvent.click(screen.getByText('Alice'));

    expect(onRowClick).toHaveBeenCalledWith(dataSource[0]);
  });
});
