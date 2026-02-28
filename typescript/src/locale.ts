/** CLDR-inspired plural categories. */
export type PluralCategory = 'zero' | 'one' | 'two' | 'few' | 'many' | 'other';

/** A unit's display forms: either a single template or per-plural-category templates. */
export type UnitForms = string | (Record<'other', string> & Partial<Record<PluralCategory, string>>);

/** Compactness level for age formatting output. */
export type Compactness = 'normal' | 'short' | 'compact';

/** Optional overrides for short/compact display modes. */
export interface CompactnessOverride {
  units?: Partial<{
    day: UnitForms;
    week: UnitForms;
    month: UnitForms;
    year: UnitForms;
  }>;
  half?: string;
  delimiter?: string;
  justBorn?: string;
}

/** Locale definition for age formatting. */
export interface AgeLocale {
  code: string;
  plural: (count: number) => PluralCategory;
  units: {
    day: UnitForms;
    week: UnitForms;
    month: UnitForms;
    year: UnitForms;
  };
  half: string;
  delimiter: string;
  justBorn: string;
  stages: {
    newborn: string;
    infant: string;
    toddler: string;
    child: string;
    teenager: string;
    adult: string;
  };
  short?: CompactnessOverride;
  compact?: CompactnessOverride;
  formatNumber?: (n: number) => string;
  formatUnit?: (count: number, label: string) => string;
}

/**
 * Resolve a unit count to its display string using locale rules.
 *
 * The `half` template supports two placeholders:
 * - `{n}` — replaces the formatted number *before* unit substitution
 *   (e.g. `"{n}½"` → "3½ years", `"साढ़े {n}"` → "साढ़े 3 साल")
 * - `{0}` — wraps the fully resolved expression *after* unit substitution
 *   (e.g. `"{0}半"` → "3歳半", `"{0} et demi"` → "3 ans et demi")
 */
export function resolveUnit(count: number, unitForms: UnitForms, locale: AgeLocale, half = ''): string {
  const baseN = locale.formatNumber?.(count) ?? String(count);
  const n = (half && half.includes('{n}')) ? half.replace('{n}', baseN) : baseN;
  const template = typeof unitForms === 'string'
    ? unitForms
    : (unitForms[locale.plural(count)] ?? unitForms.other);
  let result = template.replace('{n}', n);
  result = locale.formatUnit?.(count, result) ?? result;
  if (half && half.includes('{0}')) {
    result = half.replace('{0}', result);
  }
  return result;
}

/** English locale. */
export const en: AgeLocale = {
  code: 'en',
  plural: (n) => (n === 1 ? 'one' : 'other'),
  units: {
    day:   { one: '{n} day',   other: '{n} days' },
    week:  { one: '{n} week',  other: '{n} weeks' },
    month: { one: '{n} month', other: '{n} months' },
    year:  { one: '{n} year',  other: '{n} years' },
  },
  half: '{n}\u00BD',
  delimiter: ', ',
  justBorn: 'Newborn',
  stages: {
    newborn: 'Newborn',
    infant: 'Infant',
    toddler: 'Toddler',
    child: 'Child',
    teenager: 'Teenager',
    adult: 'Adult',
  },
  short: {
    units: {
      day:   '{n} d',
      week:  '{n} wk',
      month: '{n} mo',
      year:  '{n} yr',
    },
  },
  compact: {
    units: {
      day:   '{n}d',
      week:  '{n}w',
      month: '{n}m',
      year:  '{n}y',
    },
    delimiter: '',
  },
};
