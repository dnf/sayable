import type { Compactness, ShortClockConfig, TimeLocale } from './locale.js';
import { en } from './locale.js';

export const VERSION = '0.5.0';

/** Parse HH:MM or ISO datetime to [hour, minute]. Returns null on failure. */
function parseTime(input: string): [number, number] | null {
  if (!input) return null;
  let t = input;
  if (t.includes('T')) t = t.split('T')[1] ?? '';
  if (t.includes('+')) t = t.split('+')[0] ?? '';
  if (t.includes('Z')) t = t.split('Z')[0] ?? '';
  const parts = t.split(':');
  if (parts.length < 2) return null;
  const hour = Number(parts[0]);
  const minute = Number(parts[1]);
  if (isNaN(hour) || isNaN(minute)) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return [hour, minute];
}

/** Round minute to nearest 5. */
function roundTo5(minute: number): number {
  return Math.floor((minute + 2) / 5) * 5;
}

/**
 * Locale-aware clock time formatter.
 *
 * @example
 * ```ts
 * const st = new SayableTime(en);
 * st.formatTime('14:15');          // "a quarter past two"
 * st.formatTime('09:30');          // "half past nine"
 *
 * const stShort = new SayableTime(en, 'short');
 * stShort.formatTime('14:15');     // "2:15 PM"
 * ```
 */
export class SayableTime {
  private readonly locale: TimeLocale;
  private readonly compactness: Compactness;
  private readonly shortClock: ShortClockConfig | undefined;

  constructor(locale: TimeLocale, compactness: Compactness = 'normal') {
    this.locale = locale;
    this.compactness = compactness;
    const ovr = compactness === 'short' ? locale.short
      : compactness === 'compact' ? locale.compact
        : undefined;
    this.shortClock = ovr?.clock;
  }

  /** Format a time as natural language clock reading. */
  formatTime(input: string | null | undefined): string | null {
    if (!input) return null;
    const parsed = parseTime(input);
    if (!parsed) return null;
    const [hour, minute] = parsed;

    if (this.compactness !== 'normal' && this.shortClock) {
      return this.formatDigital(hour, minute);
    }
    return this.formatNatural(hour, minute);
  }

  private formatNatural(hour: number, minute: number): string {
    const clock = this.locale.clock;
    let rounded = roundTo5(minute);
    let h = hour;
    if (rounded === 60) {
      rounded = 0;
      h = (h + 1) % 24;
    }
    if (rounded === 0) {
      if (h === 0) return clock.midnight;
      if (h === 12) return clock.noon;
    }
    const h12 = h % 12;
    const nextH12 = (h + 1) % 12;
    const hName = clock.hours[h12] ?? '';
    const nextHName = clock.hours[nextH12] ?? '';
    const pattern = clock.patterns[rounded] ?? clock.patterns[0] ?? '{h}';
    return pattern.replace('{h}', hName).replace('{next_h}', nextHName);
  }

  private formatDigital(hour: number, minute: number): string {
    const sc = this.shortClock!;
    const fmt = sc.format;
    if (sc.use24h) {
      return fmt.replace('{h}', String(hour)).replace('{mm}', String(minute).padStart(2, '0'));
    }
    let h12 = hour % 12;
    if (h12 === 0) h12 = 12;
    const ampm = sc.amPm ?? ['AM', 'PM'];
    const ampmStr = hour < 12 ? ampm[0] : ampm[1];
    return fmt
      .replace('{h}', String(h12))
      .replace('{mm}', String(minute).padStart(2, '0'))
      .replace('{ampm}', ampmStr ?? '');
  }
}

// Default English instance
const _default = new SayableTime(en);

/** Format clock time using the default English locale. */
export function formatTime(input: string | null | undefined): string | null {
  return _default.formatTime(input);
}
