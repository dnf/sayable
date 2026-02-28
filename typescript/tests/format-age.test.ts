import { describe, it, expect, vi, afterEach } from 'vitest';
import { formatAge, formatStage } from '../src/format-age';

// All tests use explicit (dob, asOf) pairs for determinism.

describe('formatAge', () => {
  // ================================================================
  // Null / edge cases
  // ================================================================
  it('returns null for null input', () => {
    expect(formatAge(null, '2025-06-15')).toBeNull();
  });

  it('returns null for undefined input', () => {
    expect(formatAge(undefined, '2025-06-15')).toBeNull();
  });

  it('returns null for future date of birth', () => {
    expect(formatAge('2025-07-01', '2025-06-15')).toBeNull();
  });

  it('returns null for empty string', () => {
    expect(formatAge('', '2025-06-15')).toBeNull();
  });

  // ================================================================
  // Days tier: 0–6 days
  // ================================================================
  describe('days tier (0–6)', () => {
    it('born today → "Newborn"', () => {
      expect(formatAge('2025-06-15', '2025-06-15')).toBe('Newborn');
    });

    it('born 1 day ago → "1 day" (singular)', () => {
      expect(formatAge('2025-06-14', '2025-06-15')).toBe('1 day');
    });

    it('born 3 days ago → "3 days"', () => {
      expect(formatAge('2025-06-12', '2025-06-15')).toBe('3 days');
    });

    it('born 6 days ago → "6 days"', () => {
      expect(formatAge('2025-06-09', '2025-06-15')).toBe('6 days');
    });

    it('never shows 7+ days', () => {
      expect(formatAge('2025-06-08', '2025-06-15')).toBe('1 week');
    });
  });

  // ================================================================
  // Weeks+days tier: 7 days to <3 calendar months
  // ================================================================
  describe('weeks+days tier (7 days to <3 months)', () => {
    it('7 days → "1 week"', () => {
      expect(formatAge('2025-06-08', '2025-06-15')).toBe('1 week');
    });

    it('8 days → "1 week, 1 day"', () => {
      expect(formatAge('2025-06-07', '2025-06-15')).toBe('1 week, 1 day');
    });

    it('9 days → "1 week, 2 days"', () => {
      expect(formatAge('2025-06-06', '2025-06-15')).toBe('1 week, 2 days');
    });

    it('13 days → "1 week, 6 days"', () => {
      expect(formatAge('2025-06-02', '2025-06-15')).toBe('1 week, 6 days');
    });

    it('14 days → "2 weeks"', () => {
      expect(formatAge('2025-06-01', '2025-06-15')).toBe('2 weeks');
    });

    it('15 days → "2 weeks, 1 day"', () => {
      expect(formatAge('2025-05-31', '2025-06-15')).toBe('2 weeks, 1 day');
    });

    it('20 days → "2 weeks, 6 days"', () => {
      expect(formatAge('2025-05-26', '2025-06-15')).toBe('2 weeks, 6 days');
    });

    it('21 days → "3 weeks"', () => {
      expect(formatAge('2025-05-25', '2025-06-15')).toBe('3 weeks');
    });

    // weeks+days continues past 1 month and 2 months
    it('at 1 calendar month, still shows weeks+days', () => {
      expect(formatAge('2025-05-15', '2025-06-15')).toBe('4 weeks, 3 days');
    });

    it('at 2 calendar months, still shows weeks+days', () => {
      expect(formatAge('2025-04-15', '2025-06-15')).toBe('8 weeks, 5 days');
    });

    it('one day before 3-month birthday, still shows weeks+days', () => {
      // Born Mar 15 → 3 months on Jun 15. Jun 14 is still weeks.
      expect(formatAge('2025-03-15', '2025-06-14')).toBe('13 weeks');
    });

    it('on 3-month birthday, switches to months', () => {
      expect(formatAge('2025-03-15', '2025-06-15')).toBe('3 months');
    });
  });

  // ================================================================
  // Month boundaries — the hard part
  // ================================================================
  describe('month boundary: standard months', () => {
    it('born Jan 1, check Apr 1 → "3 months"', () => {
      expect(formatAge('2025-01-01', '2025-04-01')).toBe('3 months');
    });

    it('born Jan 1, check Mar 31 → still weeks+days (not yet 3 months)', () => {
      const result = formatAge('2025-01-01', '2025-03-31');
      expect(result).toMatch(/weeks/);
    });

    it('born Jun 15, check Sep 15 → "3 months"', () => {
      expect(formatAge('2025-06-15', '2025-09-15')).toBe('3 months');
    });

    it('born Jun 15, check Sep 14 → still weeks+days', () => {
      const result = formatAge('2025-06-15', '2025-09-14');
      expect(result).toMatch(/weeks/);
    });

    it('born Jun 15, check Dec 15 → "6 months"', () => {
      expect(formatAge('2025-06-15', '2025-12-15')).toBe('6 months');
    });
  });

  describe('month boundary: short month — February non-leap', () => {
    // 2025 is not a leap year (Feb has 28 days)

    // Born Jan 31 → 1 month on Feb 28 (clamped), 2 months on Mar 31, 3 months on Apr 30 (clamped)
    // All of these are still in weeks+days until 3 months
    it('born Jan 31, check Feb 28 (non-leap) → still weeks (only 1 cal month)', () => {
      expect(formatAge('2025-01-31', '2025-02-28')).toBe('4 weeks');
    });

    it('born Jan 31, check Apr 30 → "3 months" (Apr has no 31st, clamp)', () => {
      expect(formatAge('2025-01-31', '2025-04-30')).toBe('3 months');
    });

    it('born Jan 31, check Apr 29 → still weeks+days', () => {
      const result = formatAge('2025-01-31', '2025-04-29');
      expect(result).toMatch(/weeks/);
    });

    // Born Feb 1 → 3 months on May 1
    it('born Feb 1, check May 1 → "3 months"', () => {
      expect(formatAge('2025-02-01', '2025-05-01')).toBe('3 months');
    });

    it('born Feb 1, check Apr 30 → still weeks+days', () => {
      const result = formatAge('2025-02-01', '2025-04-30');
      expect(result).toMatch(/weeks/);
    });
  });

  describe('month boundary: short month — February leap year', () => {
    // 2024 is a leap year (Feb has 29 days)

    // Born Jan 31, leap year → 1 month = Feb 29 (clamped to 29, not 28)
    it('born Jan 31, check Feb 29 (leap) → still weeks (only 1 cal month)', () => {
      expect(formatAge('2024-01-31', '2024-02-29')).toBe('4 weeks, 1 day');
    });

    it('born Jan 31, check Feb 28 (leap) → still weeks (Feb 29 exists)', () => {
      expect(formatAge('2024-01-31', '2024-02-28')).toBe('4 weeks');
    });

    // Born Jan 31 → 3 months on Apr 30 (clamped)
    it('born Jan 31, check Apr 30 (leap year) → "3 months"', () => {
      expect(formatAge('2024-01-31', '2024-04-30')).toBe('3 months');
    });

    // Born Jan 30, leap year → 1 month = Feb 29 (clamped to 29)
    it('born Jan 30, check Feb 29 (leap) → still weeks (only 1 cal month)', () => {
      const result = formatAge('2024-01-30', '2024-02-29');
      expect(result).toMatch(/weeks/);
    });

    it('born Jan 30, check Feb 28 (leap) → still weeks', () => {
      const result = formatAge('2024-01-30', '2024-02-28');
      expect(result).toMatch(/weeks/);
    });
  });

  describe('month boundary: 30-day months', () => {
    // Born Mar 31 → Apr 30 (1mo, clamped) → May 31 (2mo) → Jun 30 (3mo, clamped)
    it('born Mar 31, check Jun 30 → "3 months" (clamped)', () => {
      expect(formatAge('2025-03-31', '2025-06-30')).toBe('3 months');
    });

    it('born Mar 31, check Jun 29 → still weeks+days', () => {
      const result = formatAge('2025-03-31', '2025-06-29');
      expect(result).toMatch(/weeks/);
    });

    // Born Aug 31 → Sep 30 (1mo) → Oct 31 (2mo) → Nov 30 (3mo, clamped)
    it('born Aug 31, check Nov 30 → "3 months"', () => {
      expect(formatAge('2025-08-31', '2025-11-30')).toBe('3 months');
    });

    it('born Aug 31, check Nov 29 → still weeks+days', () => {
      const result = formatAge('2025-08-31', '2025-11-29');
      expect(result).toMatch(/weeks/);
    });
  });

  describe('month boundary: leap year baby (born Feb 29)', () => {
    // Born Feb 29 2024 — the birthday only exists in leap years

    // Still in weeks+days until 3 months: May 29
    it('born Feb 29, check May 29 → "3 months"', () => {
      expect(formatAge('2024-02-29', '2024-05-29')).toBe('3 months');
    });

    it('born Feb 29, check May 28 → still weeks+days', () => {
      const result = formatAge('2024-02-29', '2024-05-28');
      expect(result).toMatch(/weeks/);
    });

    // In a non-leap year, Feb 29 baby's birthday clamps to Feb 28
    it('born Feb 29 2024, check Feb 28 2025 (non-leap) → "12 months" (clamped)', () => {
      expect(formatAge('2024-02-29', '2025-02-28')).toBe('12 months');
    });

    it('born Feb 29 2024, check Mar 1 2025 → "12 months"', () => {
      expect(formatAge('2024-02-29', '2025-03-01')).toBe('12 months');
    });
  });

  // ================================================================
  // Months tier: 3–23 months
  // ================================================================
  describe('months tier (3–23)', () => {
    it('"3 months" at transition point', () => {
      expect(formatAge('2025-01-15', '2025-04-15')).toBe('3 months');
    });

    it('"6 months"', () => {
      expect(formatAge('2025-01-15', '2025-07-15')).toBe('6 months');
    });

    it('"12 months" (not "1 year")', () => {
      expect(formatAge('2024-06-15', '2025-06-15')).toBe('12 months');
    });

    it('"23 months" at upper boundary', () => {
      expect(formatAge('2024-01-15', '2025-12-15')).toBe('23 months');
    });

    it('one day before month boundary stays at previous month count', () => {
      expect(formatAge('2025-01-15', '2025-07-14')).toBe('5 months');
    });

    it('crossing year boundary counts correctly', () => {
      expect(formatAge('2024-11-10', '2025-04-10')).toBe('5 months');
    });
  });

  // ================================================================
  // Years+months tier: 24–35 months
  // ================================================================
  describe('years+months tier (24–35 months)', () => {
    it('"2 years" at exactly 24 months', () => {
      expect(formatAge('2023-06-15', '2025-06-15')).toBe('2 years');
    });

    it('"2 years, 1 month" singular', () => {
      expect(formatAge('2023-06-15', '2025-07-15')).toBe('2 years, 1 month');
    });

    it('"2 years, 6 months"', () => {
      expect(formatAge('2023-06-15', '2025-12-15')).toBe('2 years, 6 months');
    });

    it('"2 years, 11 months" at upper boundary', () => {
      expect(formatAge('2023-06-15', '2026-05-15')).toBe('2 years, 11 months');
    });

    it('one day before 24 months stays in months tier', () => {
      expect(formatAge('2023-06-15', '2025-06-14')).toBe('23 months');
    });
  });

  // ================================================================
  // Half-year tier: 3–6 years
  // ================================================================
  describe('half-year tier (3–6 years)', () => {
    it('"3 years" at exactly 3 years', () => {
      expect(formatAge('2022-06-15', '2025-06-15')).toBe('3 years');
    });

    it('"3 years" at 3 years 5 months (just under half)', () => {
      expect(formatAge('2022-06-15', '2025-11-15')).toBe('3 years');
    });

    it('"3½ years" at 3 years 6 months', () => {
      expect(formatAge('2022-06-15', '2025-12-15')).toBe('3½ years');
    });

    it('"3½ years" at 3 years 11 months', () => {
      expect(formatAge('2022-06-15', '2026-05-15')).toBe('3½ years');
    });

    it('"4 years" at exactly 4 years', () => {
      expect(formatAge('2021-06-15', '2025-06-15')).toBe('4 years');
    });

    it('"4½ years" at 4 years 6 months', () => {
      expect(formatAge('2021-06-15', '2025-12-15')).toBe('4½ years');
    });

    it('"5 years" at exactly 5 years', () => {
      expect(formatAge('2020-06-15', '2025-06-15')).toBe('5 years');
    });

    it('"5½ years" at 5 years 8 months', () => {
      expect(formatAge('2020-06-15', '2026-02-15')).toBe('5½ years');
    });

    it('"6 years" at exactly 6 years', () => {
      expect(formatAge('2019-06-15', '2025-06-15')).toBe('6 years');
    });

    it('"6½ years" at 6 years 6 months', () => {
      expect(formatAge('2019-06-15', '2025-12-15')).toBe('6½ years');
    });

    it('"6½ years" at 6 years 11 months (last month before 7)', () => {
      expect(formatAge('2019-06-15', '2026-05-15')).toBe('6½ years');
    });

    it('one day before 3rd birthday stays in years+months tier', () => {
      expect(formatAge('2022-06-15', '2025-06-14')).toBe('2 years, 11 months');
    });
  });

  // ================================================================
  // Integer tier: 7+ years
  // ================================================================
  describe('integer tier (7+ years)', () => {
    it('"7 years" at exactly 7 years', () => {
      expect(formatAge('2018-06-15', '2025-06-15')).toBe('7 years');
    });

    it('"7 years" at 7 years 6 months (no ½ at 7+)', () => {
      expect(formatAge('2018-03-20', '2025-06-15')).toBe('7 years');
    });

    it('"45 years" for an adult', () => {
      expect(formatAge('1980-01-01', '2025-06-15')).toBe('45 years');
    });
  });

  // ================================================================
  // Cross-year transitions with short months
  // ================================================================
  describe('cross-year month counting with Feb', () => {
    // Born Dec 31 → Jan 31 (1mo) → Feb 28 (2mo, clamped) → Mar 31 (3mo)
    it('born Dec 31 2024, check Mar 31 2025 → "3 months"', () => {
      expect(formatAge('2024-12-31', '2025-03-31')).toBe('3 months');
    });

    it('born Dec 31 2024, check Mar 30 2025 → still weeks+days', () => {
      const result = formatAge('2024-12-31', '2025-03-30');
      expect(result).toMatch(/weeks/);
    });

    // Born Nov 30 → Dec 30 (1mo) → Jan 30 (2mo) → Feb 28 (3mo, clamped)
    it('born Nov 30 2024, check Feb 28 2025 → "3 months" (Feb clamp)', () => {
      expect(formatAge('2024-11-30', '2025-02-28')).toBe('3 months');
    });

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
    it('Jan 31 → Apr 30 = "3 months"', () => {
      expect(formatAge('2025-01-31', '2025-04-30')).toBe('3 months');
    });

    it('Jan 31 → May 31 = "4 months"', () => {
      expect(formatAge('2025-01-31', '2025-05-31')).toBe('4 months');
    });

    it('Jan 31 → Jun 30 = "5 months" (clamped: Jun has no 31st)', () => {
      expect(formatAge('2025-01-31', '2025-06-30')).toBe('5 months');
    });

    it('Jan 31 → Jul 1 = "5 months" (still before Jul 31)', () => {
      expect(formatAge('2025-01-31', '2025-07-01')).toBe('5 months');
    });

    it('Jan 31 → Jul 31 = "6 months"', () => {
      expect(formatAge('2025-01-31', '2025-07-31')).toBe('6 months');
    });
  });

  // ================================================================
  // Default asOf (uses current date)
  // ================================================================
  describe('default asOf uses current date', () => {
    afterEach(() => { vi.useRealTimers(); });

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
  it('returns null for null input', () => {
    expect(formatStage(null, '2025-06-15')).toBeNull();
  });

  it('returns null for undefined input', () => {
    expect(formatStage(undefined, '2025-06-15')).toBeNull();
  });

  it('returns null for future date of birth', () => {
    expect(formatStage('2025-07-01', '2025-06-15')).toBeNull();
  });

  it('returns null for empty string', () => {
    expect(formatStage('', '2025-06-15')).toBeNull();
  });

  // Newborn: 0–1 months (< 2 calendar months)
  describe('Newborn (0–1 months)', () => {
    it('born today', () => {
      expect(formatStage('2025-06-15', '2025-06-15')).toBe('Newborn');
    });

    it('1 day old', () => {
      expect(formatStage('2025-06-14', '2025-06-15')).toBe('Newborn');
    });

    it('3 weeks old', () => {
      expect(formatStage('2025-05-25', '2025-06-15')).toBe('Newborn');
    });

    it('1 month old', () => {
      expect(formatStage('2025-05-15', '2025-06-15')).toBe('Newborn');
    });

    it('1 month 29 days — still Newborn', () => {
      expect(formatStage('2025-04-16', '2025-06-15')).toBe('Newborn');
    });

    it('exactly 2 months → Infant', () => {
      expect(formatStage('2025-04-15', '2025-06-15')).toBe('Infant');
    });
  });

  // Infant: 2–11 months
  describe('Infant (2–11 months)', () => {
    it('2 months', () => {
      expect(formatStage('2025-04-15', '2025-06-15')).toBe('Infant');
    });

    it('6 months', () => {
      expect(formatStage('2024-12-15', '2025-06-15')).toBe('Infant');
    });

    it('11 months', () => {
      expect(formatStage('2024-07-15', '2025-06-15')).toBe('Infant');
    });

    it('exactly 12 months → Toddler', () => {
      expect(formatStage('2024-06-15', '2025-06-15')).toBe('Toddler');
    });
  });

  // Toddler: 1–2 years (12–35 months)
  describe('Toddler (1–2 years)', () => {
    it('12 months', () => {
      expect(formatStage('2024-06-15', '2025-06-15')).toBe('Toddler');
    });

    it('18 months', () => {
      expect(formatStage('2024-01-15', '2025-07-15')).toBe('Toddler');
    });

    it('2 years (24 months)', () => {
      expect(formatStage('2023-06-15', '2025-06-15')).toBe('Toddler');
    });

    it('35 months — still Toddler', () => {
      expect(formatStage('2023-06-15', '2026-05-15')).toBe('Toddler');
    });

    it('exactly 36 months → Preschooler', () => {
      expect(formatStage('2022-06-15', '2025-06-15')).toBe('Preschooler');
    });
  });

  // Preschooler: 3–5 years (36–71 months)
  describe('Preschooler (3–5 years)', () => {
    it('3 years', () => {
      expect(formatStage('2022-06-15', '2025-06-15')).toBe('Preschooler');
    });

    it('4 years', () => {
      expect(formatStage('2021-06-15', '2025-06-15')).toBe('Preschooler');
    });

    it('5 years 11 months — still Preschooler', () => {
      expect(formatStage('2020-06-15', '2026-05-15')).toBe('Preschooler');
    });

    it('exactly 6 years → School-age', () => {
      expect(formatStage('2019-06-15', '2025-06-15')).toBe('School-age');
    });
  });

  // School-age: 6–12 years (72–155 months)
  describe('School-age (6–12 years)', () => {
    it('6 years', () => {
      expect(formatStage('2019-06-15', '2025-06-15')).toBe('School-age');
    });

    it('9 years', () => {
      expect(formatStage('2016-06-15', '2025-06-15')).toBe('School-age');
    });

    it('12 years 11 months — still School-age', () => {
      expect(formatStage('2013-06-15', '2026-05-15')).toBe('School-age');
    });

    it('exactly 13 years → Teenager', () => {
      expect(formatStage('2012-06-15', '2025-06-15')).toBe('Teenager');
    });
  });

  // Teenager: 13–17 years (156–215 months)
  describe('Teenager (13–17 years)', () => {
    it('13 years', () => {
      expect(formatStage('2012-06-15', '2025-06-15')).toBe('Teenager');
    });

    it('15 years', () => {
      expect(formatStage('2010-06-15', '2025-06-15')).toBe('Teenager');
    });

    it('17 years 11 months — still Teenager', () => {
      expect(formatStage('2008-06-15', '2026-05-15')).toBe('Teenager');
    });

    it('exactly 18 years → Adult', () => {
      expect(formatStage('2007-06-15', '2025-06-15')).toBe('Adult');
    });
  });

  // Adult: 18+ years (216+ months)
  describe('Adult (18+ years)', () => {
    it('18 years', () => {
      expect(formatStage('2007-06-15', '2025-06-15')).toBe('Adult');
    });

    it('25 years', () => {
      expect(formatStage('2000-06-15', '2025-06-15')).toBe('Adult');
    });

    it('45 years', () => {
      expect(formatStage('1980-01-01', '2025-06-15')).toBe('Adult');
    });
  });

  // Default asOf
  describe('default asOf uses current date', () => {
    afterEach(() => { vi.useRealTimers(); });

    it('returns correct stage when no asOf is provided', () => {
      vi.useFakeTimers();
      vi.setSystemTime(new Date(2025, 5, 15)); // Jun 15 2025
      expect(formatStage('2025-06-15')).toBe('Newborn');
      expect(formatStage('2020-01-01')).toBe('Preschooler');
      expect(formatStage('1980-01-01')).toBe('Adult');
    });
  });
});
