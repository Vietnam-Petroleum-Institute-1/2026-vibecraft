<script setup lang="ts">
import { ref, type Component } from 'vue';

import { cn } from '@/utils/cn';

import MenuNode from './MenuNode.vue';

export type MenuItemConfig = {
  key: string;
  label: string;
  icon?: Component;
  disabled?: boolean;
  children?: MenuItemConfig[];
};

type MenuProps = {
  items: MenuItemConfig[];
  mode?: 'vertical' | 'horizontal';
  selectedKeys?: string[];
  defaultOpenKeys?: string[];
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
const props = withDefaults(defineProps<MenuProps>(), {
  mode: 'vertical',
  selectedKeys: () => [],
  defaultOpenKeys: () => [],
  className: undefined,
});

const emit = defineEmits<{ select: [key: string] }>();

const openKeys = ref<string[]>([...props.defaultOpenKeys]);

function toggleOpen(key: string) {
  openKeys.value = openKeys.value.includes(key)
    ? openKeys.value.filter((k) => k !== key)
    : [...openKeys.value, key];
}
</script>

<template>
  <ul
    :class="
      cn(props.mode === 'vertical' ? 'flex flex-col gap-0.5' : 'relative flex items-center gap-1', props.className)
    "
  >
    <MenuNode
      v-for="item in props.items"
      :key="item.key"
      :item="item"
      :depth="0"
      :mode="props.mode"
      :selected-keys="props.selectedKeys"
      :open-keys="openKeys"
      @toggle-open="toggleOpen"
      @select="emit('select', $event)"
    />
  </ul>
