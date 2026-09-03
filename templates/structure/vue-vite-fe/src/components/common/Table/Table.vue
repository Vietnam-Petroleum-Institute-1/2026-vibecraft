<script setup lang="ts" generic="T extends Record<string, unknown>">
import { computed, ref } from 'vue';
import { ChevronDown, ChevronUp } from 'lucide-vue-next';

import { Empty } from '@/components/common/Empty';
import { Pagination } from '@/components/common/Pagination';
import { cn } from '@/utils/cn';

export type TableColumn<T> = {
  key: string;
  title: string;
  dataIndex?: keyof T;
  render?: (value: unknown, record: T, index: number) => unknown;
  width?: number | string;
  align?: 'left' | 'center' | 'right';
  sorter?: (a: T, b: T) => number;
};

export type TablePagination = {
  current: number;
  pageSize: number;
  total: number;
  onChange: (page: number, pageSize: number) => void;
};

const props = defineProps<{
  columns: TableColumn<T>[];
  dataSource: T[];
  rowKey: keyof T | ((record: T) => string);
  loading?: boolean;
  pagination?: TablePagination;
  emptyText?: string;
  className?: string;
  onRowClick?: (record: T) => void;
}>();

const alignClass: Record<'left' | 'center' | 'right', string> = {
  left: 'text-left',
  center: 'text-center',
  right: 'text-right',
};

function getRowKey(record: T, index: number): string {
  if (typeof props.rowKey === 'function') {
    return props.rowKey(record);
  }
  return String(record[props.rowKey] ?? index);
}

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". React's useState/useMemo sort state becomes a Vue
// ref + computed; onRowClick/pagination.onChange callback props are kept
// as plain function props (unchanged) since they're already callback-style,
// not native DOM events needing an emit/v-model translation.
const sortState = ref<{ key: string; order: 'asc' | 'desc' } | null>(null);

const sortedData = computed(() => {
  if (!sortState.value) {
    return props.dataSource;
  }
  const column = props.columns.find((c) => c.key === sortState.value!.key);
  if (!column?.sorter) {
    return props.dataSource;
  }
  const sorted = [...props.dataSource].sort(column.sorter);
  return sortState.value.order === 'asc' ? sorted : sorted.reverse();
});

function toggleSort(column: TableColumn<T>) {
  if (!column.sorter) {
    return;
  }
  if (sortState.value?.key !== column.key) {
    sortState.value = { key: column.key, order: 'asc' };
    return;
  }
  sortState.value = sortState.value.order === 'asc' ? { key: column.key, order: 'desc' } : null;
}
</script>

<template>
  <div :class="cn('w-full', className)">
    <div class="overflow-x-auto rounded-md border border-border">
      <table class="w-full border-collapse text-sm">
        <thead>
          <tr class="border-b border-border bg-muted/50">
            <th
              v-for="column in columns"
              :key="column.key"
              :style="{ width: column.width }"
              :class="
                cn(
                  'px-3 py-2 font-medium text-muted-foreground',
                  alignClass[column.align ?? 'left'],
                  column.sorter && 'cursor-pointer select-none'
                )
              "
              @click="toggleSort(column)"
            >
              <span class="inline-flex items-center gap-1">
                {{ column.title }}
                <template v-if="column.sorter">
                  <ChevronUp v-if="sortState?.key === column.key && sortState.order === 'asc'" class="h-3.5 w-3.5" aria-hidden="true" />
                  <ChevronDown v-else-if="sortState?.key === column.key && sortState.order === 'desc'" class="h-3.5 w-3.5" aria-hidden="true" />
                  <ChevronDown v-else class="h-3.5 w-3.5 opacity-30" aria-hidden="true" />
                </template>
              </span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td :colspan="columns.length" class="py-10 text-center text-sm text-muted-foreground">Loading...</td>
          </tr>
          <tr v-else-if="sortedData.length === 0">
            <td :colspan="columns.length" class="p-0">
              <Empty :description="emptyText" />
            </td>
          </tr>
          <template v-else>
            <tr
              v-for="(record, index) in sortedData"
              :key="getRowKey(record, index)"
              :class="cn('border-b border-border last:border-0 hover:bg-accent/50', onRowClick && 'cursor-pointer')"
              @click="onRowClick && onRowClick(record)"
            >
              <td
                v-for="column in columns"
                :key="column.key"
                :class="cn('px-3 py-2 text-foreground', alignClass[column.align ?? 'left'])"
              >
                <component
                  v-if="column.render"
                  :is="() => column.render!(column.dataIndex ? record[column.dataIndex] : undefined, record, index)"
                />
                <template v-else>{{ column.dataIndex ? record[column.dataIndex] : undefined }}</template>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
    </div>

    <Pagination
      v-if="pagination"
      :page="pagination.current"
      :size="pagination.pageSize"
      :total="pagination.total"
      class="mt-3"
      @page-change="pagination.onChange($event, pagination.pageSize)"
      @size-change="pagination.onChange(1, $event)"
    />
  </div>
</template>
