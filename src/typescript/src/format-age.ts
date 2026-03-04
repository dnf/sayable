import type { AgeLocale, Compactness, Gender, UnitForms } from './locale.js';
import { en, resolveStage, resolveUnit } from './locale.js';

export const VERSION = "0.5.0";

const MAX_AGE_MONTHS = 6000;

/** Parsed date components and derived calendar months / elapsed days. */
interface AgeComponents {
  months: number;
  diffDays: number;
}

/**
 * Parse two YYYY-MM-DD strings into calendar months and elapsed days.
 * Returns null if dateOfBirth is falsy or in the future relative to asOf.
 */
function parseAge(dateOfBirth: string | null | undefined, asOf?: string): AgeComponents | null {
  if (!dateOfBirth) return null;

  // Parse YYYY-MM-DD as integers to avoid timezone/DST issues
  const dobParts = dateOfBirth.split('-').map(Number);
  const dobY = dobParts[0] ?? 0;
  const dobM = dobParts[1] ?? 0;
  const dobD = dobParts[2] ?? 0;
  let refY: number, refM: number, refD: number;
  if (asOf) {
    const refParts = asOf.split('-').map(Number);
    refY = refParts[0] ?? 0;
    refM = refParts[1] ?? 0;
    refD = refParts[2] ?? 0;
  } else {
    const now = new Date();
    refY = now.getFullYear();
    refM = now.getMonth() + 1;
    refD = now.getDate();
  }

  // Total elapsed days (UTC avoids DST shifts)
  const diffDays = Math.round(
    (Date.UTC(refY, refM - 1, refD) - Date.UTC(dobY, dobM - 1, dobD)) / 86_400_000,
  );
  if (diffDays < 0) return null;

  // Calendar months with clamping for short months
  const lastDay = new Date(refY, refM, 0).getDate();
  const clampedBirthday = Math.min(dobD, lastDay);
  let months = (refY - dobY) * 12 + (refM - dobM);
  if (refD < clampedBirthday) months--;
  if (months > MAX_AGE_MONTHS) return null;

  return { months, diffDays };
}

/** Stage key derived from calendar months. */
type StageKey = 'newborn' | 'infant' | 'toddler' | 'child' | 'teenager' | 'adult';

function stageKey(months: number): StageKey {
  if (months < 2) return 'newborn';
  if (months < 12) return 'infant';
  if (months < 36) return 'toddler';
  if (months < 156) return 'child';
  if (months < 216) return 'teenager';
  return 'adult';
}

/** Resolved unit set for a given compactness level. */
interface ResolvedUnits {
  day: UnitForms;
  week: UnitForms;
  month: UnitForms;
  year: UnitForms;
}

/**
 * Locale-aware age formatter.
 *
 * @example
 * ```ts
 * const pt = new ParentTime(en);
 * pt.formatAge('2025-01-01', '2025-07-15');   // "6 months"
 *
 * const ptShort = new ParentTime(en, 'short');
 * ptShort.formatAge('2025-01-01', '2025-07-15'); // "6 mo"
 *
 * const ptCompact = new ParentTime(en, 'compact');
 * ptCompact.formatAge('2025-01-01', '2025-07-15'); // "6m"
 * ```
 */
export class ParentTime {
  private readonly locale: AgeLocale;
  private readonly units: ResolvedUnits;
  private readonly half: string;
  private readonly delimiter: string;
  private readonly justBorn: string;

  constructor(locale: AgeLocale, compactness: Compactness = 'normal') {
    this.locale = locale;
    const ovr = compactness === 'short' ? locale.short
      : compactness === 'compact' ? locale.compact
        : undefined;
    this.units = {
      day:   ovr?.units?.day   ?? locale.units.day,
      week:  ovr?.units?.week  ?? locale.units.week,
      month: ovr?.units?.month ?? locale.units.month,
      year:  ovr?.units?.year  ?? locale.units.year,
    };
    this.half = ovr?.half ?? locale.half;
    this.delimiter = ovr?.delimiter ?? locale.delimiter;
    this.justBorn = ovr?.justBorn ?? locale.justBorn;
  }

  /**
   * Human-friendly age string.
   *
   * @param dateOfBirth - YYYY-MM-DD date string
   * @param asOf - YYYY-MM-DD reference date (defaults to today)
   */
  formatAge(dateOfBirth: string | null | undefined, asOf?: string): string | null {
    const age = parseAge(dateOfBirth, asOf);
    if (!age) return null;
    const { months, diffDays } = age;
    const loc = this.locale;

    // Tier 1: 0–6 days
    if (diffDays === 0) return this.justBorn;
    if (diffDays < 7) return resolveUnit(diffDays, this.units.day, loc);

    // Tier 2: weeks + days until 3 calendar months
    if (months < 3) {
      const weeks = Math.floor(diffDays / 7);
      const days = diffDays % 7;
      let result = resolveUnit(weeks, this.units.week, loc);
      if (days > 0) result += this.delimiter + resolveUnit(days, this.units.day, loc);
      return result;
    }

    // Tier 3: 3–23 months
    if (months < 24) return resolveUnit(months, this.units.month, loc);

    // Tier 4: 24–35 months → years + months
    if (months < 36) {
      const years = Math.floor(months / 12);
      const rem = months % 12;
      if (rem === 0) return resolveUnit(years, this.units.year, loc);
      return resolveUnit(years, this.units.year, loc) + this.delimiter + resolveUnit(rem, this.units.month, loc);
    }

    // Tier 5: 3–6 years → years with half marker
    if (months < 84) {
      const years = Math.floor(months / 12);
      const rem = months % 12;
      return rem >= 6
        ? resolveUnit(years, this.units.year, loc, this.half)
        : resolveUnit(years, this.units.year, loc);
    }

    // Tier 6: 7+ years
    return resolveUnit(Math.floor(months / 12), this.units.year, loc);
  }

  /**
   * Developmental stage label based on age.
   *
   * @param dateOfBirth - YYYY-MM-DD date string
   * @param asOf - YYYY-MM-DD reference date (defaults to today)
   * @param gender - optional grammatical gender ('m' or 'f')
   */
  formatStage(dateOfBirth: string | null | undefined, asOf?: string, gender?: Gender): string | null {
    const age = parseAge(dateOfBirth, asOf);
    if (!age) return null;
    return resolveStage(this.locale.stages[stageKey(age.months)], gender);
  }
}

// Default English instance for bare convenience functions
const _default = new ParentTime(en);

/**
 * Human-friendly age string using the default English locale (normal compactness).
 *
 * @param dateOfBirth - YYYY-MM-DD date string
 * @param asOf - YYYY-MM-DD reference date (defaults to today)
 */
export function formatAge(dateOfBirth: string | null | undefined, asOf?: string): string | null {
  return _default.formatAge(dateOfBirth, asOf);
}

/**
 * Developmental stage label using the default English locale.
 *
 * @param dateOfBirth - YYYY-MM-DD date string
 * @param asOf - YYYY-MM-DD reference date (defaults to today)
 * @param gender - optional grammatical gender ('m' or 'f')
 */
export function formatStage(dateOfBirth: string | null | undefined, asOf?: string, gender?: Gender): string | null {
  return _default.formatStage(dateOfBirth, asOf, gender);
}
