<script setup lang="ts">
import {
  DropdownMenuItem,
  DropdownMenuPortal,
  DropdownMenuSeparator,
  DropdownMenuSub,
  DropdownMenuSubContent,
  DropdownMenuSubTrigger,
} from 'reka-ui';
import { ChevronRight } from 'lucide-vue-next';

import { cn } from '@/utils/cn';

import type { DropdownMenuItemConfig } from './Dropdown.vue';

// Internal recursive renderer for Dropdown's menu tree. Not part of the
// public API — imported only by Dropdown.vue.
defineProps<{ items: DropdownMenuItemConfig[] }>();
</script>

<template>
  <template v-for="item in items" :key="item.key">
    <DropdownMenuSeparator v-if="item.type === 'divider'" class="my-1 h-px bg-border" />

    <DropdownMenuSub v-else-if="item.children && item.children.length > 0">
      <DropdownMenuSubTrigger
        :disabled="item.disabled"
        :class="
          cn(
            'flex cursor-pointer select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none',
            'focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
            item.danger && 'text-destructive focus:text-destructive'
          )
        "
      >
        <component :is="item.icon" v-if="item.icon" class="h-4 w-4" aria-hidden="true" />
        <span class="flex-1">{{ item.label }}</span>
        <ChevronRight class="h-4 w-4" aria-hidden="true" />
      </DropdownMenuSubTrigger>
      <DropdownMenuPortal>
        <DropdownMenuSubContent
          class="z-50 min-w-[8rem] overflow-hidden rounded-md border border-border bg-popover p-1 text-popover-foreground shadow-md"
        >
          <DropdownMenuItems :items="item.children" />
        </DropdownMenuSubContent>
      </DropdownMenuPortal>
    </DropdownMenuSub>

    <DropdownMenuItem
      v-else
      :disabled="item.disabled"
      :class="
        cn(
          'flex cursor-pointer select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none',
          'focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50',
          item.danger && 'text-destructive focus:text-destructive'
        )
      "
      @select="item.onClick?.()"
    >
      <component :is="item.icon" v-if="item.icon" class="h-4 w-4" aria-hidden="true" />
      <span>{{ item.label }}</span>
    </DropdownMenuItem>
  </template>
