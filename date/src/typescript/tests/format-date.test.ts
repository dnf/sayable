import { describe, expect, it } from 'vitest';
import { SayableDate, formatDate, formatRelative } from '../src/index.js';
import { ar } from '../src/locales/ar.js';
import { de } from '../src/locales/de.js';
import { en } from '../src/locales/en.js';
import { es } from '../src/locales/es.js';
import { fr } from '../src/locales/fr.js';
import { ja } from '../src/locales/ja.js';
import { ru } from '../src/locales/ru.js';

// ── Section 1: Null / edge cases ────────────────────────────────────

describe('Null / edge cases', () => {
  // 1.1
  it('format_date null', () => expect(formatDate(null)).toBeNull());
  // 1.2
  it('format_date empty', () => expect(formatDate('')).toBeNull());
  // 1.3
  it('format_date invalid', () => expect(formatDate('invalid')).toBeNull());
  // 1.4
  it('format_relative null as_of', () => expect(formatRelative('2025-03-15', null)).toBeNull());
  // 1.5
  it('format_relative null date', () => expect(formatRelative(null, '2025-03-15')).toBeNull());
});

// ── Section 2: format_date — normal compactness (English) ───────────

describe('format_date — normal (English)', () => {
  const sd = new SayableDate(en);

  // 2.1
  it('March 15th', () => expect(sd.formatDate('2025-03-15')).toBe('March 15th'));
  // 2.2
  it('January 1st', () => expect(sd.formatDate('2025-01-01')).toBe('January 1st'));
  // 2.3
  it('May 22nd', () => expect(sd.formatDate('2025-05-22')).toBe('May 22nd'));
  // 2.4
  it('July 3rd', () => expect(sd.formatDate('2025-07-03')).toBe('July 3rd'));
  // 2.5
  it('December 31st', () => expect(sd.formatDate('2025-12-31')).toBe('December 31st'));
  // 2.6
  it('June 11th', () => expect(sd.formatDate('2025-06-11')).toBe('June 11th'));
  // 2.7
  it('ISO datetime', () => expect(sd.formatDate('2025-03-15T14:30:00')).toBe('March 15th'));
});

// ── Section 3: format_date — short compactness (English) ────────────

describe('format_date — short (English)', () => {
  const sd = new SayableDate(en, 'short');

  // 3.1
  it('Mar 15', () => expect(sd.formatDate('2025-03-15')).toBe('Mar 15'));
  // 3.2
  it('Jan 1', () => expect(sd.formatDate('2025-01-01')).toBe('Jan 1'));
  // 3.3
  it('Dec 25', () => expect(sd.formatDate('2025-12-25')).toBe('Dec 25'));
});

// ── Section 4: format_date — compact (English) ──────────────────────

describe('format_date — compact (English)', () => {
  const sd = new SayableDate(en, 'compact');

  // 4.1
  it('3/15', () => expect(sd.formatDate('2025-03-15')).toBe('3/15'));
  // 4.2
  it('1/1', () => expect(sd.formatDate('2025-01-01')).toBe('1/1'));
});

// ── Section 5: format_relative — proximity tiers (English) ──────────

describe('format_relative — proximity tiers (English)', () => {
  const sd = new SayableDate(en);

  // 5.1
  it('today', () => expect(sd.formatRelative('2025-03-15', '2025-03-15')).toBe('today'));
  // 5.2
  it('tomorrow', () => expect(sd.formatRelative('2025-03-16', '2025-03-15')).toBe('tomorrow'));
  // 5.3
  it('yesterday', () => expect(sd.formatRelative('2025-03-14', '2025-03-15')).toBe('yesterday'));
  // 5.4
  it('day after tomorrow', () => expect(sd.formatRelative('2025-03-17', '2025-03-15')).toBe('the day after tomorrow'));
  // 5.5
  it('day before yesterday', () => expect(sd.formatRelative('2025-03-13', '2025-03-15')).toBe('the day before yesterday'));
  // 5.6
  it('this Wednesday', () => expect(sd.formatRelative('2025-03-19', '2025-03-15')).toBe('this Wednesday'));
  // 5.7
  it('this Thursday', () => expect(sd.formatRelative('2025-03-20', '2025-03-15')).toBe('this Thursday'));
  // 5.8
  it('last Tuesday', () => expect(sd.formatRelative('2025-03-11', '2025-03-15')).toBe('last Tuesday'));
  // 5.9
  it('next Saturday', () => expect(sd.formatRelative('2025-03-22', '2025-03-15')).toBe('next Saturday'));
  // 5.10
  it('next Thursday', () => expect(sd.formatRelative('2025-03-27', '2025-03-15')).toBe('next Thursday'));
  // 5.11
  it('calendar same year past', () => expect(sd.formatRelative('2025-03-01', '2025-03-15')).toBe('March 1st'));
  // 5.12
  it('calendar same year future', () => expect(sd.formatRelative('2025-04-10', '2025-03-15')).toBe('April 10th'));
  // 5.13
  it('different year future', () => expect(sd.formatRelative('2026-01-05', '2025-03-15')).toBe('January 5th, 2026'));
  // 5.14
  it('different year past', () => expect(sd.formatRelative('2024-12-25', '2025-03-15')).toBe('December 25th, 2024'));
});

// ── Section 6: format_relative — compact skips weekday tiers ────────

describe('format_relative — compact (English)', () => {
  const sd = new SayableDate(en, 'compact');

  // 6.1
  it('today', () => expect(sd.formatRelative('2025-03-15', '2025-03-15')).toBe('today'));
  // 6.2
  it('tomorrow', () => expect(sd.formatRelative('2025-03-16', '2025-03-15')).toBe('tomorrow'));
  // 6.3
  it('compact numeric', () => expect(sd.formatRelative('2025-03-19', '2025-03-15')).toBe('3/19'));
  // 6.4
  it('compact different year', () => expect(sd.formatRelative('2026-01-05', '2025-03-15')).toBe('1/5/26'));
});

// ── Section 7: Locale — German ──────────────────────────────────────

describe('Locale — German', () => {
  const sd = new SayableDate(de);

  // 7.1
  it('format_date', () => expect(sd.formatDate('2025-03-15')).toBe('15. März'));
  // 7.2
  it('tomorrow', () => expect(sd.formatRelative('2025-03-16', '2025-03-15')).toBe('morgen'));
  // 7.3
  it('day after tomorrow', () => expect(sd.formatRelative('2025-03-17', '2025-03-15')).toBe('übermorgen'));
  // 7.4
  it('this Wednesday', () => expect(sd.formatRelative('2025-03-19', '2025-03-15')).toBe('diesen Mittwoch'));
});

// ── Section 8: Locale — French ──────────────────────────────────────

describe('Locale — French', () => {
  const sd = new SayableDate(fr);

  // 8.1
  it('format_date first', () => expect(sd.formatDate('2025-03-01')).toBe('1er mars'));
  // 8.2
  it('format_date', () => expect(sd.formatDate('2025-03-15')).toBe('15 mars'));
  // 8.3
  it('tomorrow', () => expect(sd.formatRelative('2025-03-16', '2025-03-15')).toBe('demain'));
});

// ── Section 9: Locale — Japanese ────────────────────────────────────

describe('Locale — Japanese', () => {
  const sd = new SayableDate(ja);

  // 9.1
  it('format_date', () => expect(sd.formatDate('2025-03-15')).toBe('3月15日'));
  // 9.2
  it('tomorrow', () => expect(sd.formatRelative('2025-03-16', '2025-03-15')).toBe('明日'));
  // 9.3
  it('this Wednesday', () => expect(sd.formatRelative('2025-03-19', '2025-03-15')).toBe('今度の水曜日'));
});

// ── Section 10: Locale — Russian (genitive months) ──────────────────

describe('Locale — Russian', () => {
  const sd = new SayableDate(ru);

  // 10.1
  it('format_date genitive', () => expect(sd.formatDate('2025-03-15')).toBe('15 марта'));
  // 10.2
  it('tomorrow', () => expect(sd.formatRelative('2025-03-16', '2025-03-15')).toBe('завтра'));
});

// ── Section 11: Locale — Arabic ─────────────────────────────────────

describe('Locale — Arabic', () => {
  const sd = new SayableDate(ar);

  // 11.1
  it('format_date', () => expect(sd.formatDate('2025-03-15')).toBe('15 مارس'));
  // 11.2
  it('tomorrow', () => expect(sd.formatRelative('2025-03-16', '2025-03-15')).toBe('غداً'));
});

// ── Section 12: Locale — Spanish ────────────────────────────────────

describe('Locale — Spanish', () => {
  const sd = new SayableDate(es);

  // 12.1
  it('format_date', () => expect(sd.formatDate('2025-03-15')).toBe('15 de marzo'));
  // 12.2
  it('day after tomorrow', () => expect(sd.formatRelative('2025-03-17', '2025-03-15')).toBe('pasado mañana'));
});
