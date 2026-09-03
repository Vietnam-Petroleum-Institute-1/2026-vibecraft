<script setup lang="ts">
import { computed, ref } from 'vue';
import { CalendarDate, getLocalTimeZone, type DateValue } from '@internationalized/date';
import { CalendarIcon, ChevronLeft, ChevronRight } from 'lucide-vue-next';
import {
  CalendarCell,
  CalendarCellTrigger,
  CalendarGrid,
  CalendarGridBody,
  CalendarGridHead,
  CalendarGridRow,
  CalendarHeadCell,
  CalendarHeader,
  CalendarHeading,
  CalendarNext,
  CalendarPrev,
  CalendarRoot,
} from 'reka-ui';

import { Popover } from '@/components/common/Popover';
import { cn } from '@/utils/cn';

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics".
//
// PORT NOTE (React -> Vue divergence): the React version pairs Radix Popover
// with `react-day-picker`, which is JS-`Date`-native end to end. There is no
// Vue equivalent of react-day-picker; reka-ui's own Calendar primitive is
// built on `@internationalized/date`'s timezone-less `DateValue`/`CalendarDate`
// instead of `Date`. To keep the PUBLIC prop API unchanged (`value`/`v-model:value`
// as a plain `Date`, `disabledDate(date: Date)`), conversion happens only at
// this component's boundary — see `dateToCalendarDate` / `calendarDateToDate`
// below. Internally, selection state is a `CalendarDate`.
export type DatePickerProps = {
  placeholder?: string;
  format?: string;
  disabledDate?: (date: Date) => boolean;
  disabled?: boolean;
  className?: string;
};

const props = withDefaults(defineProps<DatePickerProps>(), {
  placeholder: 'Select date',
  format: 'dd/MM/yyyy',
  disabled: false,
});

const value = defineModel<Date | undefined>('value');

const open = ref(false);
const timeZone = getLocalTimeZone();

const navButtonClass =
  'inline-flex h-7 w-7 items-center justify-center rounded-md border border-input bg-background p-0 hover:bg-accent disabled:pointer-events-none disabled:opacity-50';

function dateToCalendarDate(date: Date): CalendarDate {
  return new CalendarDate(date.getFullYear(), date.getMonth() + 1, date.getDate());
}

function calendarDateToDate(dateValue: DateValue): Date {
  return dateValue.toDate(timeZone);
}

const calendarValue = computed<CalendarDate | undefined>(() => (value.value ? dateToCalendarDate(value.value) : undefined));

// Minimal dd/MM/yyyy-style formatter — the React version pulls in `date-fns`
// for this; a couple of token substitutions covers the same default format
// without adding a new dependency just for display formatting.
function formatDisplay(date: Date, fmt: string): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return fmt
    .replace(/yyyy/g, String(date.getFullYear()))
    .replace(/MM/g, pad(date.getMonth() + 1))
    .replace(/dd/g, pad(date.getDate()));
}

const displayValue = computed(() => (value.value ? formatDisplay(value.value, props.format) : ''));

function isDateDisabled(dateValue: DateValue) {
  return props.disabledDate ? props.disabledDate(calendarDateToDate(dateValue)) : false;
}

function onSelect(next: DateValue | undefined) {
  value.value = next ? calendarDateToDate(next) : undefined;
  open.value = false;
}

function onOpenChange(next: boolean) {
  if (!props.disabled) open.value = next;
}
</script>

<template>
  <Popover :open="open" placement="bottom" className="w-auto" @update:open="onOpenChange">
    <template #trigger>
      <button
        type="button"
        :disabled="disabled"
        :class="
          cn(
            'flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 text-sm text-foreground',
            'focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
            className
          )
        "
      >
        <span :class="cn(!value && 'text-muted-foreground')">{{ value ? displayValue : placeholder }}</span>
        <CalendarIcon class="h-4 w-4 opacity-50" aria-hidden="true" />
      </button>
    </template>
    <template #default>
      <CalendarRoot
        :model-value="calendarValue"
        weekday-format="short"
        :is-date-disabled="isDateDisabled"
        @update:model-value="onSelect"
      >
        <template #default="{ grid, weekDays }">
          <div v-for="month in grid" :key="month.value.toString()" class="space-y-3">
            <CalendarHeader class="relative flex h-8 items-center justify-center">
              <CalendarHeading class="text-sm font-medium text-foreground" />
              <div class="absolute inset-x-0 top-0 flex items-center justify-between">
                <CalendarPrev :class="navButtonClass">
                  <ChevronLeft class="h-4 w-4" aria-hidden="true" />
                </CalendarPrev>
                <CalendarNext :class="navButtonClass">
                  <ChevronRight class="h-4 w-4" aria-hidden="true" />
                </CalendarNext>
              </div>
            </CalendarHeader>
            <CalendarGrid class="w-full border-collapse">
              <CalendarGridHead>
                <CalendarGridRow class="flex">
                  <CalendarHeadCell
                    v-for="day in weekDays"
                    :key="day"
                    class="w-9 text-center text-xs font-normal text-muted-foreground"
                  >
                    {{ day }}
                  </CalendarHeadCell>
                </CalendarGridRow>
              </CalendarGridHead>
              <CalendarGridBody>
                <CalendarGridRow v-for="(weekDates, weekIndex) in month.rows" :key="weekIndex" class="mt-1 flex w-full">
                  <CalendarCell
                    v-for="weekDate in weekDates"
                    :key="weekDate.toString()"
                    :date="weekDate"
                    class="relative h-9 w-9 p-0 text-center text-sm"
                  >
                    <CalendarCellTrigger
                      :day="weekDate"
                      :month="month.value"
                      class="inline-flex h-9 w-9 items-center justify-center rounded-md p-0 font-normal text-foreground hover:bg-accent data-[selected]:bg-primary data-[selected]:text-primary-foreground data-[selected]:hover:bg-primary data-[today]:font-semibold data-[today]:text-primary data-[outside-view]:text-muted-foreground data-[outside-view]:opacity-50 data-[disabled]:text-muted-foreground data-[disabled]:opacity-30"
                    >
                      {{ weekDate.day }}
                    </CalendarCellTrigger>
                  </CalendarCell>
                </CalendarGridRow>
              </CalendarGridBody>
            </CalendarGrid>
          </div>
        </template>
      </CalendarRoot>
    </template>
  </Popover>
</template>
