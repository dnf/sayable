/** CLDR-inspired plural categories. */
export type PluralCategory = 'zero' | 'one' | 'two' | 'few' | 'many' | 'other';

/** Grammatical gender for stage labels. */
export type Gender = 'm' | 'f';

/** A stage label: plain string (gender-neutral) or gendered pair. */
export type StageLabel = string | { m: string; f: string };

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
    newborn: StageLabel;
    infant: StageLabel;
    toddler: StageLabel;
    child: StageLabel;
    teenager: StageLabel;
    adult: StageLabel;
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

/** Resolve a StageLabel to a plain string given an optional gender. */
export function resolveStage(label: StageLabel, gender?: Gender): string {
  if (typeof label === 'string') return label;
  return gender === 'f' ? label.f : label.m;
}

export { en } from './locales/en.js';
