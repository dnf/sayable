/** Compactness level for time formatting output. */
export type Compactness = 'normal' | 'short' | 'compact';

/** Natural language clock reading configuration. */
export interface ClockConfig {
  hours: string[];
  midnight: string;
  noon: string;
  patterns: Record<number, string>;
}

/** Digital clock display configuration for short/compact modes. */
export interface ShortClockConfig {
  use24h: boolean;
  amPm?: [string, string];
  format: string;
}

/** Optional overrides for short/compact display modes. */
export interface CompactnessOverride {
  clock?: ShortClockConfig;
}

/** Locale definition for clock time formatting. */
export interface TimeLocale {
  code: string;
  clock: ClockConfig;
  short?: CompactnessOverride;
  compact?: CompactnessOverride;
}

export { en } from './locales/en.js';
