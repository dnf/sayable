import type { Compactness, CompactnessOverride, DateLocale } from './locale.js';
import { en } from './locale.js';

export const VERSION = '0.5.0';

/** Parse YYYY-MM-DD or ISO datetime to [year, month, day]. Returns null on failure. */
function parseDate(input: string): [number, number, number] | null {
  if (!input) return null;
  const datePart = input.includes('T') ? input.split('T')[0] ?? '' : input;
  const parts = datePart.split('-');
  if (parts.length !== 3) return null;
  const year = Number(parts[0]);
  const month = Number(parts[1]);
  const day = Number(parts[2]);
  if (isNaN(year) || isNaN(month) || isNaN(day)) return null;
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return [year, month, day];
}

/** Convert a date to Julian Day Number for day-difference arithmetic. */
function toJDN(year: number, month: number, day: number): number {
  const a = Math.floor((14 - month) / 12);
  const y = year + 4800 - a;
  const m = month + 12 * a - 3;
  return day + Math.floor((153 * m + 2) / 5) + 365 * y + Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400) - 32045;
}

/** Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday. */
function weekday(year: number, month: number, day: number): number {
  return (toJDN(year, month, day) + 1) % 7;
}

/** Pick override value if defined, else default. */
function pick<T>(ovr: CompactnessOverride | undefined, key: keyof CompactnessOverride, fallback: T): T {
  if (ovr !== undefined) {
    const val = ovr[key];
    if (val !== undefined) return val as T;
  }
  return fallback;
}

/**
 * Locale-aware date formatter.
 *
 * @example
 * ```ts
 * const sd = new SayableDate(en);
 * sd.formatDate('2025-03-15');                          // "March 15th"
 * sd.formatRelative('2025-03-16', '2025-03-15');        // "tomorrow"
 * ```
 */
export class SayableDate {
  private readonly locale: DateLocale;
  private readonly compactness: Compactness;
  private readonly months: string[];
  private readonly monthsInDate: string[] | undefined;
  private readonly weekdays: string[];
  private readonly dayFormat: string;
  private readonly dayFormatExceptions: Record<string, string>;
  private readonly datePattern: string;
  private readonly datePatternWithYear: string;
  private readonly todayStr: string;
  private readonly tomorrowStr: string;
  private readonly yesterdayStr: string;

  constructor(locale: DateLocale, compactness: Compactness = 'normal') {
    this.locale = locale;
    this.compactness = compactness;
    const ovr = compactness === 'short' ? locale.short
      : compactness === 'compact' ? locale.compact
        : undefined;

    this.months = pick(ovr, 'months', locale.months);
    this.monthsInDate = pick(ovr, 'monthsInDate', locale.monthsInDate);
    this.weekdays = pick(ovr, 'weekdays', locale.weekdays);
    this.dayFormat = pick(ovr, 'dayFormat', locale.dayFormat);

    // When override provides dayFormat but not dayFormatExceptions, clear exceptions
    if (ovr?.dayFormat !== undefined && ovr.dayFormatExceptions === undefined) {
      this.dayFormatExceptions = {};
    } else {
      this.dayFormatExceptions = pick(ovr, 'dayFormatExceptions', locale.dayFormatExceptions);
    }

    this.datePattern = pick(ovr, 'datePattern', locale.datePattern);
    this.datePatternWithYear = pick(ovr, 'datePatternWithYear', locale.datePatternWithYear);
    this.todayStr = pick(ovr, 'today', locale.today);
    this.tomorrowStr = pick(ovr, 'tomorrow', locale.tomorrow);
    this.yesterdayStr = pick(ovr, 'yesterday', locale.yesterday);
  }

  /** Format a calendar date in locale-appropriate form. Always absolute — no proximity logic. */
  formatDate(date: string | null | undefined): string | null {
    if (!date) return null;
    const parsed = parseDate(date);
    if (!parsed) return null;
    return this.formatAbsolute(parsed[0], parsed[1], parsed[2], false);
  }

  /** Format a calendar date with year in locale-appropriate form. */
  formatDateWithYear(date: string | null | undefined): string | null {
    if (!date) return null;
    const parsed = parseDate(date);
    if (!parsed) return null;
    return this.formatAbsolute(parsed[0], parsed[1], parsed[2], true);
  }

  /** Format a date relative to asOf, picking the most natural reference. */
  formatRelative(date: string | null | undefined, asOf: string | null | undefined): string | null {
    if (!date || !asOf) return null;
    const parsedDate = parseDate(date);
    const parsedAsOf = parseDate(asOf);
    if (!parsedDate || !parsedAsOf) return null;

    const [dy, dm, dd] = parsedDate;
    const [ay, , ] = parsedAsOf;

    const dateJDN = toJDN(dy, dm, dd);
    const asofJDN = toJDN(parsedAsOf[0], parsedAsOf[1], parsedAsOf[2]);
    const diff = dateJDN - asofJDN;

    // Today
    if (diff === 0) return this.todayStr;

    // Tomorrow
    if (diff === 1) return this.tomorrowStr;

    // Yesterday
    if (diff === -1) return this.yesterdayStr;

    const loc = this.locale;
    const isCompact = this.compactness === 'compact';

    // Day after tomorrow (optional)
    if (diff === 2 && loc.dayAfterTomorrow && !isCompact) {
      return loc.dayAfterTomorrow;
    }

    // Day before yesterday (optional)
    if (diff === -2 && loc.dayBeforeYesterday && !isCompact) {
      return loc.dayBeforeYesterday;
    }

    // Compact mode: skip weekday references, go straight to calendar date
    if (isCompact) {
      return this.formatAbsolute(dy, dm, dd, dy !== ay);
    }

    // This weekday (+2 to +6)
    if (diff >= 2 && diff <= 6 && loc.thisWeekday) {
      const dow = weekday(dy, dm, dd);
      const wdName = this.weekdays[dow] ?? '';
      return loc.thisWeekday.replace('{weekday}', wdName);
    }

    // Last weekday (-2 to -6)
    if (diff >= -6 && diff <= -2 && loc.lastWeekday) {
      const dow = weekday(dy, dm, dd);
      const wdName = this.weekdays[dow] ?? '';
      return loc.lastWeekday.replace('{weekday}', wdName);
    }

    // Next weekday (+7 to +13)
    if (diff >= 7 && diff <= 13 && loc.nextWeekday) {
      const dow = weekday(dy, dm, dd);
      const wdName = this.weekdays[dow] ?? '';
      return loc.nextWeekday.replace('{weekday}', wdName);
    }

    // Calendar fallback
    return this.formatAbsolute(dy, dm, dd, dy !== ay);
  }

  private formatAbsolute(year: number, month: number, day: number, includeYear: boolean): string {
    // Format the day with ordinal
    const dayStr = String(day);
    const fmt = this.dayFormatExceptions[dayStr] ?? this.dayFormat;
    const formattedDay = fmt.replace('{n}', dayStr);

    // Pick month name (genitive form if available)
    const monthNames = this.monthsInDate ?? this.months;
    const monthName = monthNames[month - 1] ?? '';

    const pattern = includeYear ? this.datePatternWithYear : this.datePattern;
    let result = pattern.replace('{month}', monthName);
    result = result.replace('{day}', formattedDay);
    result = result.replace('{d}', String(day));
    result = result.replace('{m}', String(month));
    if (includeYear) {
      result = result.replace('{year}', String(year));
      result = result.replace('{yy}', String(year % 100).padStart(2, '0'));
    }

    return result;
  }
}

// Default English instance
const _default = new SayableDate(en);

/** Format date using the default English locale. */
export function formatDate(date: string | null | undefined): string | null {
  return _default.formatDate(date);
}

/** Format relative date using the default English locale. */
export function formatRelative(date: string | null | undefined, asOf: string | null | undefined): string | null {
  return _default.formatRelative(date, asOf);
}
