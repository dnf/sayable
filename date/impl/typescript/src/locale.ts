/** Compactness level for date formatting output. */
export type Compactness = 'normal' | 'short' | 'compact';

/** Optional overrides for short/compact display modes. */
export interface CompactnessOverride {
  months?: string[];
  monthsInDate?: string[];
  weekdays?: string[];
  dayFormat?: string;
  dayFormatExceptions?: Record<string, string>;
  datePattern?: string;
  datePatternWithYear?: string;
  today?: string;
  tomorrow?: string;
  yesterday?: string;
}

/** Locale definition for date formatting. */
export interface DateLocale {
  code: string;
  months: string[];
  weekdays: string[];
  dayFormat: string;
  dayFormatExceptions: Record<string, string>;
  datePattern: string;
  datePatternWithYear: string;
  today: string;
  tomorrow: string;
  yesterday: string;
  dayAfterTomorrow?: string;
  dayBeforeYesterday?: string;
  thisWeekday?: string;
  nextWeekday?: string;
  lastWeekday?: string;
  monthsInDate?: string[];
  short?: CompactnessOverride;
  compact?: CompactnessOverride;
}

export { en } from './locales/en.js';
