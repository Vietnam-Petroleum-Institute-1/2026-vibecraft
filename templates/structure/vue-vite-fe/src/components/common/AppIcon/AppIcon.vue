<script setup lang="ts">
import { computed } from 'vue';

import { getIcon } from '@/utils/icon-registry';

export type AppIconProps = {
  name?: string | null;
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". Renders an icon by (kebab-case) key from a
// statically-imported, curated set (utils/icon-registry.ts) — falls back
// to a fixed default for an unknown/missing key.
const props = defineProps<AppIconProps>();

const Icon = computed(() => getIcon(props.name));
</script>

<template>
  <component :is="Icon" :class="className" />
</template>
