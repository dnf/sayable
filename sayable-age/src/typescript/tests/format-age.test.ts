import { describe, it, expect, vi, afterEach } from 'vitest';
import { formatAge, formatStage, SayableAge } from '../src/format-age';
import { en, resolveStage, type AgeLocale, type StageLabel } from '../src/locale';
import { ar } from '../src/locales/ar';
import { es } from '../src/locales/es';
import { he } from '../src/locales/he';
import { mk } from '../src/locales/mk';
import { sw } from '../src/locales/sw';
import { id } from '../src/locales/id';
import { am } from '../src/locales/am';
import { getLocale } from '../src/locales/index';

// All tests use explicit (dob, asOf) pairs for determinism.

describe('formatAge', () => {
  // ================================================================
  // Null / edge cases
  // ================================================================
  // 1.1
  it('returns null for null input', () => {
    expect(formatAge(null, '2025-06-15')).toBeNull();
  });

  // 1.2
  it('returns null for undefined input', () => {
    expect(formatAge(undefined, '2025-06-15')).toBeNull();
  });

  // 1.4
  it('returns null for future date of birth', () => {
    expect(formatAge('2025-07-01', '2025-06-15')).toBeNull();
  });

  // 1.3
  it('returns null for empty string', () => {
    expect(formatAge('', '2025-06-15')).toBeNull();
  });

  // 1.5
  it('exactly 500 years is allowed', () => {
    expect(formatAge('1525-06-15', '2025-06-15')).toBe('500 years');
  });

  // 1.6
  it('501 years exceeds max age', () => {
    expect(formatAge('1524-06-15', '2025-06-15')).toBeNull();
  });

  // 1.7
  it('1000 years exceeds max age', () => {
    expect(formatAge('1025-06-15', '2025-06-15')).toBeNull();
  });

  // ================================================================
  // Days tier: 0–6 days
  // ================================================================
  describe('days tier (0–6)', () => {
    // 2.1
    it('born today → "Newborn"', () => {
      expect(formatAge('2025-06-15', '2025-06-15')).toBe('Newborn');
    });

    // 2.2
    it('born 1 day ago → "1 day" (singular)', () => {
      expect(formatAge('2025-06-14', '2025-06-15')).toBe('1 day');
    });

    // 2.3
    it('born 3 days ago → "3 days"', () => {
      expect(formatAge('2025-06-12', '2025-06-15')).toBe('3 days');
    });

    // 2.4
    it('born 6 days ago → "6 days"', () => {
      expect(formatAge('2025-06-09', '2025-06-15')).toBe('6 days');
    });

    // 2.5
    it('never shows 7+ days', () => {
      expect(formatAge('2025-06-08', '2025-06-15')).toBe('1 week');
    });
  });

  // ================================================================
  // Weeks+days tier: 7 days to <3 calendar months
  // ================================================================
  describe('weeks+days tier (7 days to <3 months)', () => {
    // 3.1
    it('7 days → "1 week"', () => {
      expect(formatAge('2025-06-08', '2025-06-15')).toBe('1 week');
    });

    // 3.2
    it('8 days → "1 week, 1 day"', () => {
      expect(formatAge('2025-06-07', '2025-06-15')).toBe('1 week, 1 day');
    });

    // 3.3
    it('9 days → "1 week, 2 days"', () => {
      expect(formatAge('2025-06-06', '2025-06-15')).toBe('1 week, 2 days');
    });

    // 3.4
    it('13 days → "1 week, 6 days"', () => {
      expect(formatAge('2025-06-02', '2025-06-15')).toBe('1 week, 6 days');
    });

    // 3.5
    it('14 days → "2 weeks"', () => {
      expect(formatAge('2025-06-01', '2025-06-15')).toBe('2 weeks');
    });

    // 3.6
    it('15 days → "2 weeks, 1 day"', () => {
      expect(formatAge('2025-05-31', '2025-06-15')).toBe('2 weeks, 1 day');
    });

    // 3.7
    it('20 days → "2 weeks, 6 days"', () => {
      expect(formatAge('2025-05-26', '2025-06-15')).toBe('2 weeks, 6 days');
    });

    // 3.8
    it('21 days → "3 weeks"', () => {
      expect(formatAge('2025-05-25', '2025-06-15')).toBe('3 weeks');
    });

    // weeks+days continues past 1 month and 2 months
    // 3.9
    it('at 1 calendar month, still shows weeks+days', () => {
      expect(formatAge('2025-05-15', '2025-06-15')).toBe('4 weeks, 3 days');
    });

    // 3.10
    it('at 2 calendar months, still shows weeks+days', () => {
      expect(formatAge('2025-04-15', '2025-06-15')).toBe('8 weeks, 5 days');
    });

    // 3.11
    it('one day before 3-month birthday, still shows weeks+days', () => {
      // Born Mar 15 → 3 months on Jun 15. Jun 14 is still weeks.
      expect(formatAge('2025-03-15', '2025-06-14')).toBe('13 weeks');
    });

    // 3.12
    it('on 3-month birthday, switches to months', () => {
      expect(formatAge('2025-03-15', '2025-06-15')).toBe('3 months');
    });
  });

  // ================================================================
  // Month boundaries — the hard part
  // ================================================================
  describe('month boundary: standard months', () => {
    // 4.1
    it('born Jan 1, check Apr 1 → "3 months"', () => {
      expect(formatAge('2025-01-01', '2025-04-01')).toBe('3 months');
    });

    // 4.2
    it('born Jan 1, check Mar 31 → still weeks+days (not yet 3 months)', () => {
      const result = formatAge('2025-01-01', '2025-03-31');
      expect(result).toMatch(/weeks/);
    });

    // 4.3
    it('born Jun 15, check Sep 15 → "3 months"', () => {
      expect(formatAge('2025-06-15', '2025-09-15')).toBe('3 months');
    });

    // 4.4
    it('born Jun 15, check Sep 14 → still weeks+days', () => {
      const result = formatAge('2025-06-15', '2025-09-14');
      expect(result).toMatch(/weeks/);
    });

    // 4.5
    it('born Jun 15, check Dec 15 → "6 months"', () => {
      expect(formatAge('2025-06-15', '2025-12-15')).toBe('6 months');
    });
  });

  describe('month boundary: short month — February non-leap', () => {
    // 2025 is not a leap year (Feb has 28 days)

    // Born Jan 31 → 1 month on Feb 28 (clamped), 2 months on Mar 31, 3 months on Apr 30 (clamped)
    // All of these are still in weeks+days until 3 months
    // 5.1
    it('born Jan 31, check Feb 28 (non-leap) → still weeks (only 1 cal month)', () => {
      expect(formatAge('2025-01-31', '2025-02-28')).toBe('4 weeks');
    });

    // 5.2
    it('born Jan 31, check Apr 30 → "3 months" (Apr has no 31st, clamp)', () => {
      expect(formatAge('2025-01-31', '2025-04-30')).toBe('3 months');
    });

    // 5.3
    it('born Jan 31, check Apr 29 → still weeks+days', () => {
      const result = formatAge('2025-01-31', '2025-04-29');
      expect(result).toMatch(/weeks/);
    });

    // Born Feb 1 → 3 months on May 1
    // 5.4
    it('born Feb 1, check May 1 → "3 months"', () => {
      expect(formatAge('2025-02-01', '2025-05-01')).toBe('3 months');
    });

    // 5.5
    it('born Feb 1, check Apr 30 → still weeks+days', () => {
      const result = formatAge('2025-02-01', '2025-04-30');
      expect(result).toMatch(/weeks/);
    });
  });

  describe('month boundary: short month — February leap year', () => {
    // 2024 is a leap year (Feb has 29 days)

    // Born Jan 31, leap year → 1 month = Feb 29 (clamped to 29, not 28)
    // 6.1
    it('born Jan 31, check Feb 29 (leap) → still weeks (only 1 cal month)', () => {
      expect(formatAge('2024-01-31', '2024-02-29')).toBe('4 weeks, 1 day');
    });

    // 6.2
    it('born Jan 31, check Feb 28 (leap) → still weeks (Feb 29 exists)', () => {
      expect(formatAge('2024-01-31', '2024-02-28')).toBe('4 weeks');
    });

    // Born Jan 31 → 3 months on Apr 30 (clamped)
    // 6.3
    it('born Jan 31, check Apr 30 (leap year) → "3 months"', () => {
      expect(formatAge('2024-01-31', '2024-04-30')).toBe('3 months');
    });

    // Born Jan 30, leap year → 1 month = Feb 29 (clamped to 29)
    // 6.4
    it('born Jan 30, check Feb 29 (leap) → still weeks (only 1 cal month)', () => {
      const result = formatAge('2024-01-30', '2024-02-29');
      expect(result).toMatch(/weeks/);
    });

    // 6.5
    it('born Jan 30, check Feb 28 (leap) → still weeks', () => {
      const result = formatAge('2024-01-30', '2024-02-28');
      expect(result).toMatch(/weeks/);
    });
  });

  describe('month boundary: 30-day months', () => {
    // Born Mar 31 → Apr 30 (1mo, clamped) → May 31 (2mo) → Jun 30 (3mo, clamped)
    // 7.1
    it('born Mar 31, check Jun 30 → "3 months" (clamped)', () => {
      expect(formatAge('2025-03-31', '2025-06-30')).toBe('3 months');
    });

    // 7.2
    it('born Mar 31, check Jun 29 → still weeks+days', () => {
      const result = formatAge('2025-03-31', '2025-06-29');
      expect(result).toMatch(/weeks/);
    });

    // Born Aug 31 → Sep 30 (1mo) → Oct 31 (2mo) → Nov 30 (3mo, clamped)
    // 7.3
    it('born Aug 31, check Nov 30 → "3 months"', () => {
      expect(formatAge('2025-08-31', '2025-11-30')).toBe('3 months');
    });

    // 7.4
    it('born Aug 31, check Nov 29 → still weeks+days', () => {
      const result = formatAge('2025-08-31', '2025-11-29');
      expect(result).toMatch(/weeks/);
    });
  });

  describe('month boundary: leap year baby (born Feb 29)', () => {
    // Born Feb 29 2024 — the birthday only exists in leap years

    // Still in weeks+days until 3 months: May 29
    // 8.1
    it('born Feb 29, check May 29 → "3 months"', () => {
      expect(formatAge('2024-02-29', '2024-05-29')).toBe('3 months');
    });

    // 8.2
    it('born Feb 29, check May 28 → still weeks+days', () => {
      const result = formatAge('2024-02-29', '2024-05-28');
      expect(result).toMatch(/weeks/);
    });

    // In a non-leap year, Feb 29 baby's birthday clamps to Feb 28
    // 8.3
    it('born Feb 29 2024, check Feb 28 2025 (non-leap) → "12 months" (clamped)', () => {
      expect(formatAge('2024-02-29', '2025-02-28')).toBe('12 months');
    });

    // 8.4
    it('born Feb 29 2024, check Mar 1 2025 → "12 months"', () => {
      expect(formatAge('2024-02-29', '2025-03-01')).toBe('12 months');
    });
  });

  // ================================================================
  // Months tier: 3–23 months
  // ================================================================
  describe('months tier (3–23)', () => {
    // 9.1
    it('"3 months" at transition point', () => {
      expect(formatAge('2025-01-15', '2025-04-15')).toBe('3 months');
    });

    // 9.2
    it('"6 months"', () => {
      expect(formatAge('2025-01-15', '2025-07-15')).toBe('6 months');
    });

    // 9.3
    it('"12 months" (not "1 year")', () => {
      expect(formatAge('2024-06-15', '2025-06-15')).toBe('12 months');
    });

    // 9.4
    it('"23 months" at upper boundary', () => {
      expect(formatAge('2024-01-15', '2025-12-15')).toBe('23 months');
    });

    // 9.5
    it('one day before month boundary stays at previous month count', () => {
      expect(formatAge('2025-01-15', '2025-07-14')).toBe('5 months');
    });

    // 9.6
    it('crossing year boundary counts correctly', () => {
      expect(formatAge('2024-11-10', '2025-04-10')).toBe('5 months');
    });
  });

  // ================================================================
  // Years+months tier: 24–35 months
  // ================================================================
  describe('years+months tier (24–35 months)', () => {
    // 10.1
    it('"2 years" at exactly 24 months', () => {
      expect(formatAge('2023-06-15', '2025-06-15')).toBe('2 years');
    });

    // 10.2
    it('"2 years, 1 month" singular', () => {
      expect(formatAge('2023-06-15', '2025-07-15')).toBe('2 years, 1 month');
    });

    // 10.3
    it('"2 years, 6 months"', () => {
      expect(formatAge('2023-06-15', '2025-12-15')).toBe('2 years, 6 months');
    });

    // 10.4
    it('"2 years, 11 months" at upper boundary', () => {
      expect(formatAge('2023-06-15', '2026-05-15')).toBe('2 years, 11 months');
    });

    // 10.5
    it('one day before 24 months stays in months tier', () => {
      expect(formatAge('2023-06-15', '2025-06-14')).toBe('23 months');
    });
  });

  // ================================================================
  // Half-year tier: 3–6 years
  // ================================================================
  describe('half-year tier (3–6 years)', () => {
    // 11.1
    it('"3 years" at exactly 3 years', () => {
      expect(formatAge('2022-06-15', '2025-06-15')).toBe('3 years');
    });

    // 11.2
    it('"3 years" at 3 years 5 months (just under half)', () => {
      expect(formatAge('2022-06-15', '2025-11-15')).toBe('3 years');
    });

    // 11.3
    it('"3½ years" at 3 years 6 months', () => {
      expect(formatAge('2022-06-15', '2025-12-15')).toBe('3½ years');
    });

    // 11.4
    it('"3½ years" at 3 years 11 months', () => {
      expect(formatAge('2022-06-15', '2026-05-15')).toBe('3½ years');
    });

    // 11.5
    it('"4 years" at exactly 4 years', () => {
      expect(formatAge('2021-06-15', '2025-06-15')).toBe('4 years');
    });

    // 11.6
    it('"4½ years" at 4 years 6 months', () => {
      expect(formatAge('2021-06-15', '2025-12-15')).toBe('4½ years');
    });

    // 11.7
    it('"5 years" at exactly 5 years', () => {
      expect(formatAge('2020-06-15', '2025-06-15')).toBe('5 years');
    });

    // 11.8
    it('"5½ years" at 5 years 8 months', () => {
      expect(formatAge('2020-06-15', '2026-02-15')).toBe('5½ years');
    });

    // 11.9
    it('"6 years" at exactly 6 years', () => {
      expect(formatAge('2019-06-15', '2025-06-15')).toBe('6 years');
    });

    // 11.10
    it('"6½ years" at 6 years 6 months', () => {
      expect(formatAge('2019-06-15', '2025-12-15')).toBe('6½ years');
    });

    // 11.11
    it('"6½ years" at 6 years 11 months (last month before 7)', () => {
      expect(formatAge('2019-06-15', '2026-05-15')).toBe('6½ years');
    });

    // 11.12
    it('one day before 3rd birthday stays in years+months tier', () => {
      expect(formatAge('2022-06-15', '2025-06-14')).toBe('2 years, 11 months');
    });
  });

  // ================================================================
  // Integer tier: 7+ years
  // ================================================================
  describe('integer tier (7+ years)', () => {
    // 12.1
    it('"7 years" at exactly 7 years', () => {
      expect(formatAge('2018-06-15', '2025-06-15')).toBe('7 years');
    });

    // 12.2
    it('"7 years" at 7 years 6 months (no ½ at 7+)', () => {
      expect(formatAge('2018-03-20', '2025-06-15')).toBe('7 years');
    });

    // 12.3
    it('"45 years" for an adult', () => {
      expect(formatAge('1980-01-01', '2025-06-15')).toBe('45 years');
    });
  });

  // ================================================================
  // Cross-year transitions with short months
  // ================================================================
  describe('cross-year month counting with Feb', () => {
    // Born Dec 31 → Jan 31 (1mo) → Feb 28 (2mo, clamped) → Mar 31 (3mo)
    // 13.1
    it('born Dec 31 2024, check Mar 31 2025 → "3 months"', () => {
      expect(formatAge('2024-12-31', '2025-03-31')).toBe('3 months');
    });

    // 13.2
    it('born Dec 31 2024, check Mar 30 2025 → still weeks+days', () => {
      const result = formatAge('2024-12-31', '2025-03-30');
      expect(result).toMatch(/weeks/);
    });

    // Born Nov 30 → Dec 30 (1mo) → Jan 30 (2mo) → Feb 28 (3mo, clamped)
    // 13.3
    it('born Nov 30 2024, check Feb 28 2025 → "3 months" (Feb clamp)', () => {
      expect(formatAge('2024-11-30', '2025-02-28')).toBe('3 months');
    });

    // 13.4
    it('born Nov 30 2024, check Feb 27 2025 → still weeks+days', () => {
      const result = formatAge('2024-11-30', '2025-02-27');
      expect(result).toMatch(/weeks/);
    });
  });

  // ================================================================
  // Regression: born on 31st tracked through multiple months
  // ================================================================
  describe('born-on-31st progression through year', () => {
    // Born Jan 31 2025 (non-leap year)
    // 1 mo = Feb 28, 2 mo = Mar 31, 3 mo = Apr 30 (switch to months here)
    // 4 mo = May 31, 5 mo = Jun 30, 6 mo = Jul 31
    // 14.1
    it('Jan 31 → Apr 30 = "3 months"', () => {
      expect(formatAge('2025-01-31', '2025-04-30')).toBe('3 months');
    });

    // 14.2
    it('Jan 31 → May 31 = "4 months"', () => {
      expect(formatAge('2025-01-31', '2025-05-31')).toBe('4 months');
    });

    // 14.3
    it('Jan 31 → Jun 30 = "5 months" (clamped: Jun has no 31st)', () => {
      expect(formatAge('2025-01-31', '2025-06-30')).toBe('5 months');
    });

    // 14.4
    it('Jan 31 → Jul 1 = "5 months" (still before Jul 31)', () => {
      expect(formatAge('2025-01-31', '2025-07-01')).toBe('5 months');
    });

    // 14.5
    it('Jan 31 → Jul 31 = "6 months"', () => {
      expect(formatAge('2025-01-31', '2025-07-31')).toBe('6 months');
    });
  });

  // ================================================================
  // Default asOf (uses current date)
  // ================================================================
  describe('default asOf uses current date', () => {
    afterEach(() => { vi.useRealTimers(); });

    // 15.1, 15.2
    it('returns correct age when no asOf is provided', () => {
      vi.useFakeTimers();
      vi.setSystemTime(new Date(2025, 5, 15)); // Jun 15 2025
      expect(formatAge('2020-01-01')).toBe('5 years');
      expect(formatAge('2025-06-10')).toBe('5 days');
    });
  });
});

// ================================================================
// formatStage
// ================================================================
describe('formatStage', () => {
  // Null / edge cases
  // 16.1
  it('returns null for null input', () => {
    expect(formatStage(null, '2025-06-15')).toBeNull();
  });

  // 16.2
  it('returns null for undefined input', () => {
    expect(formatStage(undefined, '2025-06-15')).toBeNull();
  });

  // 16.4
  it('returns null for future date of birth', () => {
    expect(formatStage('2025-07-01', '2025-06-15')).toBeNull();
  });

  // 16.3
  it('returns null for empty string', () => {
    expect(formatStage('', '2025-06-15')).toBeNull();
  });

  // 16.5
  it('exactly 500 years returns Adult', () => {
    expect(formatStage('1525-06-15', '2025-06-15')).toBe('Adult');
  });

  // 16.6
  it('501 years exceeds max age', () => {
    expect(formatStage('1524-06-15', '2025-06-15')).toBeNull();
  });

  // Newborn: 0–1 months (< 2 calendar months)
  describe('Newborn (0–1 months)', () => {
    // 17.1
    it('born today', () => {
      expect(formatStage('2025-06-15', '2025-06-15')).toBe('Newborn');
    });

    // 17.2
    it('1 day old', () => {
      expect(formatStage('2025-06-14', '2025-06-15')).toBe('Newborn');
    });

    // 17.3
    it('3 weeks old', () => {
      expect(formatStage('2025-05-25', '2025-06-15')).toBe('Newborn');
    });

    // 17.4
    it('1 month old', () => {
      expect(formatStage('2025-05-15', '2025-06-15')).toBe('Newborn');
    });

    // 17.5
    it('1 month 29 days — still Newborn', () => {
      expect(formatStage('2025-04-16', '2025-06-15')).toBe('Newborn');
    });

    // 17.6
    it('exactly 2 months → Infant', () => {
      expect(formatStage('2025-04-15', '2025-06-15')).toBe('Infant');
    });
  });

  // Infant: 2–11 months
  describe('Infant (2–11 months)', () => {
    // 18.1
    it('2 months', () => {
      expect(formatStage('2025-04-15', '2025-06-15')).toBe('Infant');
    });

    // 18.2
    it('6 months', () => {
      expect(formatStage('2024-12-15', '2025-06-15')).toBe('Infant');
    });

    // 18.3
    it('11 months', () => {
      expect(formatStage('2024-07-15', '2025-06-15')).toBe('Infant');
    });

    // 18.4
    it('exactly 12 months → Toddler', () => {
      expect(formatStage('2024-06-15', '2025-06-15')).toBe('Toddler');
    });
  });

  // Toddler: 1–2 years (12–35 months)
  describe('Toddler (1–2 years)', () => {
    // 19.1
    it('12 months', () => {
      expect(formatStage('2024-06-15', '2025-06-15')).toBe('Toddler');
    });

    // 19.2
    it('18 months', () => {
      expect(formatStage('2024-01-15', '2025-07-15')).toBe('Toddler');
    });

    // 19.3
    it('2 years (24 months)', () => {
      expect(formatStage('2023-06-15', '2025-06-15')).toBe('Toddler');
    });

    // 19.4
    it('35 months — still Toddler', () => {
      expect(formatStage('2023-06-15', '2026-05-15')).toBe('Toddler');
    });

    // 19.5
    it('exactly 36 months → Child', () => {
      expect(formatStage('2022-06-15', '2025-06-15')).toBe('Child');
    });
  });

  // Child: 3–12 years (36–155 months)
  describe('Child (3–12 years)', () => {
    // 20.1
    it('3 years', () => {
      expect(formatStage('2022-06-15', '2025-06-15')).toBe('Child');
    });

    // 20.2
    it('4 years', () => {
      expect(formatStage('2021-06-15', '2025-06-15')).toBe('Child');
    });

    // 20.3
    it('6 years', () => {
      expect(formatStage('2019-06-15', '2025-06-15')).toBe('Child');
    });

    // 20.4
    it('9 years', () => {
      expect(formatStage('2016-06-15', '2025-06-15')).toBe('Child');
    });

    // 20.5
    it('12 years 11 months — still Child', () => {
      expect(formatStage('2013-06-15', '2026-05-15')).toBe('Child');
    });

    // 20.6
    it('exactly 13 years → Teenager', () => {
      expect(formatStage('2012-06-15', '2025-06-15')).toBe('Teenager');
    });
  });

  // Teenager: 13–17 years (156–215 months)
  describe('Teenager (13–17 years)', () => {
    // 21.1
    it('13 years', () => {
      expect(formatStage('2012-06-15', '2025-06-15')).toBe('Teenager');
    });

    // 21.2
    it('15 years', () => {
      expect(formatStage('2010-06-15', '2025-06-15')).toBe('Teenager');
    });

    // 21.3
    it('17 years 11 months — still Teenager', () => {
      expect(formatStage('2008-06-15', '2026-05-15')).toBe('Teenager');
    });

    // 21.4
    it('exactly 18 years → Adult', () => {
      expect(formatStage('2007-06-15', '2025-06-15')).toBe('Adult');
    });
  });

  // Adult: 18+ years (216+ months)
  describe('Adult (18+ years)', () => {
    // 22.1
    it('18 years', () => {
      expect(formatStage('2007-06-15', '2025-06-15')).toBe('Adult');
    });

    // 22.2
    it('25 years', () => {
      expect(formatStage('2000-06-15', '2025-06-15')).toBe('Adult');
    });

    // 22.3
    it('45 years', () => {
      expect(formatStage('1980-01-01', '2025-06-15')).toBe('Adult');
    });
  });

  // Default asOf
  describe('default asOf uses current date', () => {
    afterEach(() => { vi.useRealTimers(); });

    // 23.1, 23.2, 23.3
    it('returns correct stage when no asOf is provided', () => {
      vi.useFakeTimers();
      vi.setSystemTime(new Date(2025, 5, 15)); // Jun 15 2025
      expect(formatStage('2025-06-15')).toBe('Newborn');
      expect(formatStage('2020-01-01')).toBe('Child');
      expect(formatStage('1980-01-01')).toBe('Adult');
    });
  });
});

// ================================================================
// resolveStage
// ================================================================
describe('resolveStage', () => {
  it('returns plain string unchanged regardless of gender', () => {
    expect(resolveStage('Adult')).toBe('Adult');
    expect(resolveStage('Adult', 'm')).toBe('Adult');
    expect(resolveStage('Adult', 'f')).toBe('Adult');
  });

  it('returns masculine form by default for gendered label', () => {
    const label: StageLabel = { m: 'Adulto', f: 'Adulta' };
    expect(resolveStage(label)).toBe('Adulto');
    expect(resolveStage(label, 'm')).toBe('Adulto');
  });

  it('returns feminine form when gender is f', () => {
    const label: StageLabel = { m: 'Adulto', f: 'Adulta' };
    expect(resolveStage(label, 'f')).toBe('Adulta');
  });
});

// ================================================================
// formatStage with gender
// ================================================================
describe('formatStage with gender', () => {
  it('English locale ignores gender (all stages neutral)', () => {
    expect(formatStage('2007-06-15', '2025-06-15', 'f')).toBe('Adult');
    expect(formatStage('2025-06-15', '2025-06-15', 'f')).toBe('Newborn');
  });

  describe('Arabic locale (all stages gendered)', () => {
    const pt = new SayableAge(ar);

    it('returns masculine by default', () => {
      expect(pt.formatStage('2007-06-15', '2025-06-15')).toBe('بالغ');
      expect(pt.formatStage('2025-06-15', '2025-06-15')).toBe('حديث الولادة');
    });

    it('returns masculine with explicit m', () => {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'm')).toBe('بالغ');
    });

    it('returns feminine with f', () => {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'f')).toBe('حديثة الولادة');
      expect(pt.formatStage('2025-01-15', '2025-06-15', 'f')).toBe('رضيعة');
      expect(pt.formatStage('2024-06-15', '2025-06-15', 'f')).toBe('طفلة صغيرة');
      expect(pt.formatStage('2022-06-15', '2025-06-15', 'f')).toBe('طفلة');
      expect(pt.formatStage('2012-06-15', '2025-06-15', 'f')).toBe('مراهقة');
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'f')).toBe('بالغة');
    });
  });

  describe('Spanish locale (partial gendering)', () => {
    const pt = new SayableAge(es);

    it('gendered stages return feminine with f', () => {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'f')).toBe('Recién nacida');
      expect(pt.formatStage('2022-06-15', '2025-06-15', 'f')).toBe('Niña');
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'f')).toBe('Adulta');
    });

    it('neutral stages return same string regardless of gender', () => {
      expect(pt.formatStage('2025-01-15', '2025-06-15', 'f')).toBe('Bebé');
      expect(pt.formatStage('2012-06-15', '2025-06-15', 'f')).toBe('Adolescente');
    });
  });
});

// ================================================================
// SayableAge class
// ================================================================
describe('SayableAge', () => {
  describe('with English locale', () => {
    const pt = new SayableAge(en);

    // 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
    it('formatAge delegates correctly', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('Newborn');
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3 days');
      expect(pt.formatAge('2025-06-07', '2025-06-15')).toBe('1 week, 1 day');
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6 months');
      expect(pt.formatAge('2023-06-15', '2025-07-15')).toBe('2 years, 1 month');
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3½ years');
      expect(pt.formatAge('2018-06-15', '2025-06-15')).toBe('7 years');
    });

    // 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
    it('formatStage delegates correctly', () => {
      expect(pt.formatStage('2025-06-15', '2025-06-15')).toBe('Newborn');
      expect(pt.formatStage('2025-01-15', '2025-06-15')).toBe('Infant');
      expect(pt.formatStage('2024-06-15', '2025-06-15')).toBe('Toddler');
      expect(pt.formatStage('2022-06-15', '2025-06-15')).toBe('Child');
      expect(pt.formatStage('2012-06-15', '2025-06-15')).toBe('Teenager');
      expect(pt.formatStage('2007-06-15', '2025-06-15')).toBe('Adult');
    });

    // 24.14, 24.15
    it('returns null for invalid input', () => {
      expect(pt.formatAge(null, '2025-06-15')).toBeNull();
      expect(pt.formatStage(undefined, '2025-06-15')).toBeNull();
    });
  });

  describe('with Spanish-like locale', () => {
    const es: AgeLocale = {
      code: 'es',
      plural: (n) => (n === 1 ? 'one' : 'other'),
      units: {
        day:   { one: '{n} día',    other: '{n} días' },
        week:  { one: '{n} semana', other: '{n} semanas' },
        month: { one: '{n} mes',    other: '{n} meses' },
        year:  { one: '{n} año',    other: '{n} años' },
      },
      half: '{n} y medio',
      delimiter: ', ',
      justBorn: 'Recién nacido',
      stages: {
        newborn: 'Recién nacido',
        infant: 'Bebé',
        toddler: 'Niño pequeño',
        child: 'Niño',
        teenager: 'Adolescente',
        adult: 'Adulto',
      },
    };

    const pt = new SayableAge(es);

    // 25.1
    it('justBorn label', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('Recién nacido');
    });

    // 25.2
    it('singular day', () => {
      expect(pt.formatAge('2025-06-14', '2025-06-15')).toBe('1 día');
    });

    // 25.3
    it('plural days', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3 días');
    });

    // 25.4
    it('singular week', () => {
      expect(pt.formatAge('2025-06-08', '2025-06-15')).toBe('1 semana');
    });

    // 25.5
    it('compound weeks+days with delimiter', () => {
      expect(pt.formatAge('2025-06-07', '2025-06-15')).toBe('1 semana, 1 día');
    });

    // 25.6
    it('plural weeks + plural days', () => {
      expect(pt.formatAge('2025-05-26', '2025-06-15')).toBe('2 semanas, 6 días');
    });

    // 25.7
    it('months', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6 meses');
    });

    // 25.8
    it('singular month in compound', () => {
      expect(pt.formatAge('2023-06-15', '2025-07-15')).toBe('2 años, 1 mes');
    });

    // 25.9
    it('years + months compound', () => {
      expect(pt.formatAge('2023-06-15', '2025-12-15')).toBe('2 años, 6 meses');
    });

    // 25.10
    it('half marker', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3 y medio años');
    });

    // 25.11
    it('integer years (no half)', () => {
      expect(pt.formatAge('2022-06-15', '2025-06-15')).toBe('3 años');
    });

    // 25.12
    it('7+ years', () => {
      expect(pt.formatAge('2018-06-15', '2025-06-15')).toBe('7 años');
    });

    // 25.13, 25.14, 25.15, 25.16, 25.17, 25.18
    it('stage labels', () => {
      expect(pt.formatStage('2025-06-15', '2025-06-15')).toBe('Recién nacido');
      expect(pt.formatStage('2025-01-15', '2025-06-15')).toBe('Bebé');
      expect(pt.formatStage('2024-06-15', '2025-06-15')).toBe('Niño pequeño');
      expect(pt.formatStage('2022-06-15', '2025-06-15')).toBe('Niño');
      expect(pt.formatStage('2012-06-15', '2025-06-15')).toBe('Adolescente');
      expect(pt.formatStage('2007-06-15', '2025-06-15')).toBe('Adulto');
    });

    // 25.19, 25.20
    it('null handling', () => {
      expect(pt.formatAge(null, '2025-06-15')).toBeNull();
      expect(pt.formatStage(null, '2025-06-15')).toBeNull();
    });
  });

  // ================================================================
  // Compactness levels
  // ================================================================
  describe('compactness: short', () => {
    const pt = new SayableAge(en, 'short');

    // 26.1
    it('days', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3 d');
    });

    // 26.2
    it('weeks', () => {
      expect(pt.formatAge('2025-06-08', '2025-06-15')).toBe('1 wk');
    });

    // 26.3
    it('weeks + days', () => {
      expect(pt.formatAge('2025-06-07', '2025-06-15')).toBe('1 wk, 1 d');
    });

    // 26.4
    it('months', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6 mo');
    });

    // 26.5
    it('years + months', () => {
      expect(pt.formatAge('2023-06-15', '2025-07-15')).toBe('2 yr, 1 mo');
    });

    // 26.6
    it('half years', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3½ yr');
    });

    // 26.7
    it('integer years', () => {
      expect(pt.formatAge('2018-06-15', '2025-06-15')).toBe('7 yr');
    });

    // 26.8
    it('justBorn unchanged', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('Newborn');
    });

    // 26.9
    it('stages unchanged', () => {
      expect(pt.formatStage('2025-01-15', '2025-06-15')).toBe('Infant');
    });
  });

  describe('compactness: compact', () => {
    const pt = new SayableAge(en, 'compact');

    // 27.1
    it('days', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3d');
    });

    // 27.2
    it('weeks', () => {
      expect(pt.formatAge('2025-06-08', '2025-06-15')).toBe('1w');
    });

    // 27.3
    it('weeks + days (no delimiter)', () => {
      expect(pt.formatAge('2025-06-07', '2025-06-15')).toBe('1w1d');
    });

    // 27.4
    it('months', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6m');
    });

    // 27.5
    it('years + months (no delimiter)', () => {
      expect(pt.formatAge('2023-06-15', '2025-07-15')).toBe('2y1m');
    });

    // 27.6
    it('half years', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3½y');
    });

    // 27.7
    it('integer years', () => {
      expect(pt.formatAge('2018-06-15', '2025-06-15')).toBe('7y');
    });

    // 27.8
    it('justBorn unchanged', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('Newborn');
    });
  });

  // ================================================================
  // Section 29: Locale-specific edge cases — new plural rules
  // ================================================================
  describe('Hebrew locale (he) — dual forms', () => {
    const pt = new SayableAge(he);

    // 29.1
    it('justBorn', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('רק נולד');
    });

    // 29.2
    it('1 day — one form', () => {
      expect(pt.formatAge('2025-06-14', '2025-06-15')).toBe('יום 1');
    });

    // 29.3
    it('3 days — other form', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3 ימים');
    });

    // 29.4
    it('2 weeks — dual form', () => {
      expect(pt.formatAge('2025-06-01', '2025-06-15')).toBe('שבועיים');
    });

    // 29.5
    it('3 weeks — other form', () => {
      expect(pt.formatAge('2025-05-25', '2025-06-15')).toBe('3 שבועות');
    });

    // 29.6
    it('6 months — other', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6 חודשים');
    });

    // 29.7
    it('3 months — other', () => {
      expect(pt.formatAge('2025-03-15', '2025-06-15')).toBe('3 חודשים');
    });

    // 29.8
    it('2y dual + 1m one', () => {
      expect(pt.formatAge('2023-06-15', '2025-07-15')).toBe('שנתיים, חודש 1');
    });

    // 29.9
    it('3½ years — half marker', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3 שנים וחצי');
    });

    // 29.10
    it('7+ years — other', () => {
      expect(pt.formatAge('2018-06-15', '2025-06-15')).toBe('7 שנים');
    });

    // 29.11
    it('masculine newborn stage', () => {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'm')).toBe('רק נולד');
    });

    // 29.12
    it('feminine newborn stage', () => {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'f')).toBe('רק נולדה');
    });

    // 29.13
    it('masculine adult stage', () => {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'm')).toBe('מבוגר');
    });

    // 29.14
    it('feminine adult stage', () => {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'f')).toBe('מבוגרת');
    });
  });

  describe('Macedonian locale (mk) — mod10/mod100 rule', () => {
    const pt = new SayableAge(mk);

    // 29.15
    it('justBorn', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('Новороденче');
    });

    // 29.16
    it('1 day — one', () => {
      expect(pt.formatAge('2025-06-14', '2025-06-15')).toBe('1 ден');
    });

    // 29.17
    it('3 days — other', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3 дена');
    });

    // 29.18
    it('6 months — other', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6 месеци');
    });

    // 29.19
    it('2y1m — one for month', () => {
      expect(pt.formatAge('2023-06-15', '2025-07-15')).toBe('2 години, 1 месец');
    });

    // 29.20
    it('3½ years — half marker', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3 години и пол');
    });

    // 29.21
    it('7+ years — other', () => {
      expect(pt.formatAge('2018-06-15', '2025-06-15')).toBe('7 години');
    });
  });

  describe('Swahili locale (sw) — noun class changes', () => {
    const pt = new SayableAge(sw);

    // 29.22
    it('justBorn', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('Mzaliwa mpya');
    });

    // 29.23
    it('1 day — one', () => {
      expect(pt.formatAge('2025-06-14', '2025-06-15')).toBe('siku 1');
    });

    // 29.24
    it('3 days — other', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('siku 3');
    });

    // 29.25
    it('6 months — other (noun class change)', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('miezi 6');
    });

    // 29.26
    it('2y other + 1m one', () => {
      expect(pt.formatAge('2023-06-15', '2025-07-15')).toBe('miaka 2, mwezi 1');
    });

    // 29.27
    it('3½ years — half marker', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('miaka 3 na nusu');
    });
  });

  describe('Indonesian locale (id) — other_only', () => {
    const pt = new SayableAge(id);

    // 29.28
    it('justBorn', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('Baru lahir');
    });

    // 29.29
    it('1 day', () => {
      expect(pt.formatAge('2025-06-14', '2025-06-15')).toBe('1 hari');
    });

    // 29.30
    it('3 days (same unit)', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3 hari');
    });

    // 29.31
    it('6 months', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6 bulan');
    });

    // 29.32
    it('3½ years — half marker', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3 tahun setengah');
    });

    // 29.33
    it('7+ years', () => {
      expect(pt.formatAge('2018-06-15', '2025-06-15')).toBe('7 tahun');
    });
  });

  describe('Amharic locale (am) — Ethiopic delimiter', () => {
    const pt = new SayableAge(am);

    // 29.34
    it('justBorn', () => {
      expect(pt.formatAge('2025-06-15', '2025-06-15')).toBe('አዲስ የተወለደ');
    });

    // 29.35
    it('1 day — one form', () => {
      expect(pt.formatAge('2025-06-14', '2025-06-15')).toBe('1 ቀን');
    });

    // 29.36
    it('3 days — other form', () => {
      expect(pt.formatAge('2025-06-12', '2025-06-15')).toBe('3 ቀናት');
    });

    // 29.37
    it('1w1d with Ethiopic delimiter', () => {
      expect(pt.formatAge('2025-06-07', '2025-06-15')).toBe('1 ሳምንት፣ 1 ቀን');
    });

    // 29.38
    it('6 months — other form', () => {
      expect(pt.formatAge('2025-01-15', '2025-07-15')).toBe('6 ወራት');
    });

    // 29.39
    it('3½ years — half marker', () => {
      expect(pt.formatAge('2022-06-15', '2025-12-15')).toBe('3 ዓመታት ተኩል');
    });
  });

  // ================================================================
  // Section 30: Locale lookup by code string
  // ================================================================
  describe('getLocale', () => {
    // 30.1
    it('returns en locale for "en"', () => {
      const loc = getLocale('en');
      expect(loc).toBeDefined();
      expect(loc!.code).toBe('en');
    });

    // 30.2
    it('returns fr locale for "fr"', () => {
      const loc = getLocale('fr');
      expect(loc).toBeDefined();
      expect(loc!.code).toBe('fr');
    });

    // 30.3
    it('returns undefined for unknown code', () => {
      expect(getLocale('xx')).toBeUndefined();
    });

    // 30.4
    it('returns undefined for empty string', () => {
      expect(getLocale('')).toBeUndefined();
    });

    // 30.5
    it('returns undefined for uppercase (case-sensitive)', () => {
      expect(getLocale('EN')).toBeUndefined();
    });
  });
});
