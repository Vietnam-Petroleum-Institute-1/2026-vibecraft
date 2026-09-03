<script setup lang="ts">
import { ref } from 'vue';

import { Button } from '@/components/common/Button';
import { Input } from '@/components/common/Input';
import { Select, type SelectOptionConfig } from '@/components/common/Select';
import { cn } from '@/utils/cn';

const DEFAULT_PAGE_SIZE_OPTIONS = [10, 20, 50, 100];

type PaginationProps = {
  page: number;
  size: number;
  total: number;
  pageSizeOptions?: number[];
  className?: string;
};

type PageItem = number | 'ellipsis';

// Windows down to first/last + neighbors of the current page once there are
// too many pages to list in full — mirrors db-sync-service's Pagination.
function getPageList(current: number, totalPages: number): PageItem[] {
  if (totalPages <= 7) {
    return Array.from({ length: totalPages }, (_, i) => i + 1);
  }

  const left = Math.max(2, current - 1);
  const right = Math.min(totalPages - 1, current + 1);
  const items: PageItem[] = [1];

  if (left > 2) {
    items.push('ellipsis');
  } else if (left === 3) {
    items.push(2);
  }

  for (let p = left; p <= right; p += 1) {
    items.push(p);
  }

  if (right < totalPages - 1) {
    items.push('ellipsis');
  } else if (right === totalPages - 2) {
    items.push(totalPages - 1);
  }

  items.push(totalPages);
  return items;
}

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
const props = withDefaults(defineProps<PaginationProps>(), {
  pageSizeOptions: () => DEFAULT_PAGE_SIZE_OPTIONS,
  className: undefined,
});

const emit = defineEmits<{
  'page-change': [page: number];
  'size-change': [size: number];
}>();

const goInput = ref('');

function totalPagesOf(total: number, size: number): number {
  return Math.max(1, Math.ceil(total / size));
}

function submitGo() {
  const totalPages = totalPagesOf(props.total, props.size);
  const target = Number(goInput.value);
  if (Number.isInteger(target) && target >= 1 && target <= totalPages) {
    emit('page-change', target);
    goInput.value = '';
  }
}

function handleSizeChange(value: string | undefined) {
  if (value) {
    emit('size-change', Number(value));
  }
}
</script>

<template>
  <div v-if="total === 0" :class="cn('flex items-center justify-end text-sm text-muted-foreground', className)">
    Tổng: 0 bản ghi
  </div>
  <div v-else :class="cn('flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between', className)">
    <span class="text-sm text-muted-foreground">Tổng: {{ total }} bản ghi</span>

    <div class="flex flex-wrap items-center gap-1">
      <Button size="sm" :disabled="page <= 1" @click="emit('page-change', page - 1)">Trước</Button>
      <template v-for="(item, index) in getPageList(page, totalPagesOf(total, size))" :key="item === 'ellipsis' ? `ellipsis-${index}` : item">
        <span v-if="item === 'ellipsis'" class="px-2 text-muted-foreground">…</span>
        <Button v-else :type="item === page ? 'primary' : 'default'" size="sm" @click="emit('page-change', item)">
          {{ item }}
        </Button>
      </template>
      <Button size="sm" :disabled="page >= totalPagesOf(total, size)" @click="emit('page-change', page + 1)">Sau</Button>
    </div>

    <div class="flex flex-wrap items-center gap-2">
      <Input
        size="sm"
        className="w-16"
        v-model="goInput"
        placeholder="Trang"
        @keydown.enter="submitGo"
      />
      <Button size="sm" @click="submitGo">Đi tới</Button>

      <Select
        size="sm"
        className="w-28"
        :options="pageSizeOptions.map((option): SelectOptionConfig => ({ value: String(option), label: `${option} / trang` }))"
        :value="String(size)"
        @update:value="handleSizeChange"
      />
    </div>
  </div>
</template>
