/** CLDR-inspired plural categories. */
export type PluralCategory = 'zero' | 'one' | 'two' | 'few' | 'many' | 'other';

/** A unit's display forms: either a single template or per-plural-category templates. */
export type UnitForms = string | (Record<'other', string> & Partial<Record<PluralCategory, string>>);

/** Compactness level for duration formatting output. */
export type Compactness = 'normal' | 'short' | 'compact';

/** Optional overrides for short/compact display modes. */
export interface CompactnessOverride {
  units?: Partial<{
    second: UnitForms;
    minute: UnitForms;
    hour: UnitForms;
    day: UnitForms;
    week: UnitForms;
    month: UnitForms;
    year: UnitForms;
  }>;
  half?: string;
  delimiter?: string;
  ago?: string;
  inFuture?: string;
}

/** Locale definition for duration formatting. */
export interface DurationLocale {
  code: string;
  plural: (count: number) => PluralCategory;
  units: {
    second: UnitForms;
    minute: UnitForms;
    hour: UnitForms;
    day: UnitForms;
    week: UnitForms;
    month: UnitForms;
    year: UnitForms;
  };
  half: string;
  delimiter: string;
  justNow: string;
  ago: string;
  inFuture: string;
  short?: CompactnessOverride;
  compact?: CompactnessOverride;
  formatNumber?: (n: number) => string;
  formatUnit?: (count: number, label: string) => string;
}

/**
 * Resolve a unit count to its display string using locale rules.
 *
 * When a half marker is applied, the plural category is forced to
 * "other" (e.g. "1½ hours" not "1½ hour").
 */
export function resolveUnit(count: number, unitForms: UnitForms, locale: DurationLocale, half = ''): string {
  const baseN = locale.formatNumber?.(count) ?? String(count);
  const n = (half && half.includes('{n}')) ? half.replace('{n}', baseN) : baseN;
  let template: string;
  if (typeof unitForms === 'string') {
    template = unitForms;
  } else {
    // Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
    const category = half ? 'other' : locale.plural(count);
    template = unitForms[category] ?? unitForms.other;
  }
  let result = template.replace('{n}', n);
  result = locale.formatUnit?.(count, result) ?? result;
  if (half && half.includes('{0}')) {
    result = half.replace('{0}', result);
  }
  return result;
}

export { en } from './locales/en.js';
