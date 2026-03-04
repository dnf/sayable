import type { Compactness, DurationLocale, UnitForms } from './locale.js';
import { en, resolveUnit } from './locale.js';

export const VERSION = '0.1.0';

type UnitKey = 'second' | 'minute' | 'hour' | 'day' | 'week' | 'month' | 'year';

function isLeapYear(year: number): boolean {
  return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
}

function daysInMonth(year: number, month: number): number {
  if ([1, 3, 5, 7, 8, 10, 12].includes(month)) return 31;
  if ([4, 6, 9, 11].includes(month)) return 30;
  return isLeapYear(year) ? 29 : 28;
}

function daysSinceEpoch(year: number, month: number, day: number): number {
  let days = 0;
  if (year >= 2000) {
    for (let y = 2000; y < year; y++) days += isLeapYear(y) ? 366 : 365;
  } else {
    for (let y = year; y < 2000; y++) days -= isLeapYear(y) ? 366 : 365;
  }
  for (let m = 1; m < month; m++) days += daysInMonth(year, m);
  days += day - 1;
  return days;
}

/** Parse ISO datetime string to epoch-ish seconds for diffing. */
function parseIsoToSeconds(iso: string): number | null {
  if (!iso) return null;
  try {
    const [datePart, timePart] = iso.split('T');
    if (!datePart || !timePart) return null;
    const dp = datePart.split('-').map(Number);
    const year = dp[0] ?? 0;
    const month = dp[1] ?? 0;
    const day = dp[2] ?? 0;
    let timeStr = timePart;
    if (timeStr.includes('+')) timeStr = timeStr.split('+')[0] ?? '';
    if (timeStr.includes('Z')) timeStr = timeStr.split('Z')[0] ?? '';
    const tp = timeStr.split(':').map(Number);
    const hour = tp[0] ?? 0;
    const minute = tp[1] ?? 0;
    const rawSec = tp[2] ?? 0;
    const second = Math.floor(rawSec);
    const days = daysSinceEpoch(year, month, day);
    return days * 86400 + hour * 3600 + minute * 60 + second;
  } catch {
    return null;
  }
}

/** Resolved unit set for a given compactness level. */
interface ResolvedUnits {
  second: UnitForms;
  minute: UnitForms;
  hour: UnitForms;
  day: UnitForms;
  week: UnitForms;
  month: UnitForms;
  year: UnitForms;
}

/**
 * Locale-aware duration and relative time formatter.
 *
 * @example
 * ```ts
 * const sd = new SayableDuration(en);
 * sd.formatDuration(3600);                                     // "1 hour"
 * sd.formatDuration('2025-01-15T10:00:00', '2025-01-15T11:30:00'); // "1½ hours"
 * sd.formatSince('2025-01-15T10:00:00', '2025-01-15T10:45:00');    // "45 minutes ago"
 * sd.formatUntil('2025-01-15T15:00:00', '2025-01-15T14:40:00');    // "in 20 minutes"
 * ```
 */
export class SayableDuration {
  private readonly locale: DurationLocale;
  private readonly units: ResolvedUnits;
  private readonly half: string;
  private readonly delimiter: string;
  private readonly justNow: string;
  private readonly ago: string;
  private readonly inFuture: string;

  constructor(locale: DurationLocale, compactness: Compactness = 'normal') {
    this.locale = locale;
    const ovr = compactness === 'short' ? locale.short
      : compactness === 'compact' ? locale.compact
        : undefined;
    this.units = {
      second: ovr?.units?.second ?? locale.units.second,
      minute: ovr?.units?.minute ?? locale.units.minute,
      hour:   ovr?.units?.hour   ?? locale.units.hour,
      day:    ovr?.units?.day    ?? locale.units.day,
      week:   ovr?.units?.week   ?? locale.units.week,
      month:  ovr?.units?.month  ?? locale.units.month,
      year:   ovr?.units?.year   ?? locale.units.year,
    };
    this.half = ovr?.half ?? locale.half;
    this.delimiter = ovr?.delimiter ?? locale.delimiter;
    this.justNow = locale.justNow;
    this.ago = ovr?.ago ?? locale.ago;
    this.inFuture = ovr?.inFuture ?? locale.inFuture;
  }

  /** Format a duration in human-friendly terms. */
  formatDuration(startOrSeconds: string | number | null | undefined, end?: string): string | null {
    if (startOrSeconds == null) return null;

    let totalSeconds: number;
    if (typeof startOrSeconds === 'number') {
      totalSeconds = startOrSeconds;
    } else {
      if (!end) return null;
      const s = parseIsoToSeconds(startOrSeconds);
      const e = parseIsoToSeconds(end);
      if (s == null || e == null) return null;
      totalSeconds = Math.abs(e - s);
    }
    if (totalSeconds < 0) return null;
    return this.formatDurationSeconds(totalSeconds);
  }

  private formatDurationSeconds(total: number): string {
    const loc = this.locale;

    // 0 seconds
    if (total === 0) return this.justNow;

    // 1-59 seconds
    if (total < 60) return resolveUnit(total, this.units.second, loc);

    const totalMinutes = Math.floor(total / 60);
    const remainderSeconds = total % 60;

    // 1-4 minutes: min + sec
    if (totalMinutes < 5) {
      let result = resolveUnit(totalMinutes, this.units.minute, loc);
      if (remainderSeconds > 0) {
        result += this.delimiter + resolveUnit(remainderSeconds, this.units.second, loc);
      }
      return result;
    }

    // 5-59 minutes
    if (totalMinutes < 60) return resolveUnit(totalMinutes, this.units.minute, loc);

    const totalHours = Math.floor(total / 3600);
    const remainderMinutes = Math.floor((total % 3600) / 60);

    // 1-5 hours: hr + min (with half marker)
    if (totalHours <= 5) {
      if (remainderMinutes === 30) {
        return resolveUnit(totalHours, this.units.hour, loc, this.half);
      }
      let result = resolveUnit(totalHours, this.units.hour, loc);
      if (remainderMinutes > 0) {
        result += this.delimiter + resolveUnit(remainderMinutes, this.units.minute, loc);
      }
      return result;
    }

    // 6-23 hours
    if (totalHours < 24) return resolveUnit(totalHours, this.units.hour, loc);

    const totalDays = Math.floor(total / 86400);
    const remainderHours = Math.floor((total % 86400) / 3600);

    // 1-2 days: days + hours (with half marker)
    if (totalDays <= 2) {
      if (remainderHours === 12) {
        return resolveUnit(totalDays, this.units.day, loc, this.half);
      }
      let result = resolveUnit(totalDays, this.units.day, loc);
      if (remainderHours > 0) {
        result += this.delimiter + resolveUnit(remainderHours, this.units.hour, loc);
      }
      return result;
    }

    // 3-6 days
    if (totalDays < 7) return resolveUnit(totalDays, this.units.day, loc);

    const totalWeeks = Math.floor(totalDays / 7);
    const remainderDays = totalDays % 7;

    // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
    if (totalDays < 30) {
      let result = resolveUnit(totalWeeks, this.units.week, loc);
      if (remainderDays > 0) {
        result += this.delimiter + resolveUnit(remainderDays, this.units.day, loc);
      }
      return result;
    }

    // Approximate months (30.44 days average)
    let totalMonths = Math.round(totalDays / 30.44);

    // 1-11 months
    if (totalMonths < 12) {
      if (totalMonths === 0) totalMonths = 1;
      return resolveUnit(totalMonths, this.units.month, loc);
    }

    // 12+ months: years + months
    const totalYears = Math.floor(totalMonths / 12);
    const remainderMonths = totalMonths % 12;
    let result = resolveUnit(totalYears, this.units.year, loc);
    if (remainderMonths > 0) {
      result += this.delimiter + resolveUnit(remainderMonths, this.units.month, loc);
    }
    return result;
  }

  /** Format elapsed time as 'X ago'. */
  formatSince(start: string | null | undefined, asOf: string | null | undefined): string | null {
    if (!start || !asOf) return null;
    const s = parseIsoToSeconds(start);
    const a = parseIsoToSeconds(asOf);
    if (s == null || a == null) return null;
    const diff = a - s;
    if (diff < 0) return null;
    if (diff === 0) return this.justNow;
    const dur = this.formatDurationSeconds(diff);
    return this.ago.replace('{0}', dur);
  }

  /** Format time until a future event as 'in X'. */
  formatUntil(target: string | null | undefined, asOf: string | null | undefined): string | null {
    if (!target || !asOf) return null;
    const t = parseIsoToSeconds(target);
    const a = parseIsoToSeconds(asOf);
    if (t == null || a == null) return null;
    const diff = t - a;
    if (diff < 0) return null;
    if (diff === 0) return this.justNow;
    const dur = this.formatDurationSeconds(diff);
    return this.inFuture.replace('{0}', dur);
  }
}

// Default English instance
const _default = new SayableDuration(en);

/** Format duration using the default English locale. */
export function formatDuration(startOrSeconds: string | number | null | undefined, end?: string): string | null {
  return _default.formatDuration(startOrSeconds, end);
}

/** Format elapsed time using the default English locale. */
export function formatSince(start: string | null | undefined, asOf: string | null | undefined): string | null {
  return _default.formatSince(start, asOf);
}

/** Format time until event using the default English locale. */
export function formatUntil(target: string | null | undefined, asOf: string | null | undefined): string | null {
  return _default.formatUntil(target, asOf);
}
