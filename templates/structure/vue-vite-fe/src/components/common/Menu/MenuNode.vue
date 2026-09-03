<script setup lang="ts">
import { computed, type Component } from 'vue';
import { ChevronDown } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

import type { MenuItemConfig } from './Menu.vue';

// Internal recursive renderer for Menu's item tree. Not part of the public
// API — imported only by Menu.vue.
const props = defineProps<{
  item: MenuItemConfig;
  depth: number;
  mode: 'vertical' | 'horizontal';
  selectedKeys: string[];
  openKeys: string[];
}>();

const emit = defineEmits<{
  toggleOpen: [key: string];
  select: [key: string];
}>();

const hasChildren = computed(() => !!props.item.children?.length);
const isSelected = computed(() => props.selectedKeys.includes(props.item.key));
const isOpen = computed(() => props.openKeys.includes(props.item.key));
const icon = computed<Component | undefined>(() => props.item.icon);

function handleClick() {
  if (hasChildren.value) {
    emit('toggleOpen', props.item.key);
    return;
  }
  emit('select', props.item.key);
}
</script>

<template>
  <li>
    <button
      type="button"
      :disabled="item.disabled"
      :style="mode === 'vertical' ? { paddingLeft: `${12 + depth * 16}px` } : undefined"
      :class="
        cn(
          'flex w-full items-center gap-2 rounded-md px-3 py-2 text-left text-sm text-foreground transition-colors',
          'hover:bg-accent hover:text-accent-foreground disabled:pointer-events-none disabled:opacity-50',
          isSelected && !hasChildren && 'bg-primary/10 font-medium text-primary'
        )
      "
      @click="handleClick"
    >
      <component :is="icon" v-if="icon" class="h-4 w-4" aria-hidden="true" />
      <span class="flex-1">{{ item.label }}</span>
      <ChevronDown v-if="hasChildren" :class="cn('h-4 w-4 transition-transform', isOpen && 'rotate-180')" aria-hidden="true" />
    </button>
    <ul
      v-if="hasChildren && isOpen"
      :class="mode === 'vertical' ? undefined : 'absolute mt-1 min-w-[10rem] rounded-md border border-border bg-popover p-1 shadow-md'"
    >
      <MenuNode
        v-for="child in item.children"
        :key="child.key"
        :item="child"
        :depth="depth + 1"
        :mode="mode"
        :selected-keys="selectedKeys"
        :open-keys="openKeys"
        @toggle-open="emit('toggleOpen', $event)"
        @select="emit('select', $event)"
      />
    </ul>
  </li>
