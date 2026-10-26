import { describe, expect, it } from 'vitest';
import { SayableDate, formatDate, formatRelative } from '../src/index.js';
import { ar } from '../src/locales/ar.js';
import { cs } from '../src/locales/cs.js';
import { de } from '../src/locales/de.js';
import { en } from '../src/locales/en.js';
import { es } from '../src/locales/es.js';
import { fi } from '../src/locales/fi.js';
import { fr } from '../src/locales/fr.js';
import { ja } from '../src/locales/ja.js';
import { kek } from '../src/locales/kek.js';
import { kw } from '../src/locales/kw.js';
import { mam } from '../src/locales/mam.js';
import { ru } from '../src/locales/ru.js';
import { sk } from '../src/locales/sk.js';
import { tg } from '../src/locales/tg.js';
import { uk } from '../src/locales/uk.js';

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

// ── Section 13: format_date_with_year ───────────────────────────────

describe('format_date_with_year', () => {
  // 13.1
  it('normal', () => expect(new SayableDate(en).formatDateWithYear('2018-02-04')).toBe('February 4th, 2018'));
  // 13.2
  it('short', () => expect(new SayableDate(en, 'short').formatDateWithYear('2025-03-15')).toBe('Mar 15, 2025'));
  // 13.3
  it('compact', () => expect(new SayableDate(en, 'compact').formatDateWithYear('1997-01-21')).toBe('1/21/97'));
  // 13.4
  it('two-digit year keeps its leading zero', () =>
    expect(new SayableDate(tg, 'compact').formatDateWithYear('2007-05-20')).toBe('20/5/07'));
  // 13.5
  it('Finnish short', () => expect(new SayableDate(fi, 'short').formatDateWithYear('1996-06-21')).toBe('21. kesäkuuta 1996'));
});

// ── Section 14: Short month names (locales that keep the full genitive) ──

describe('Short month names (full genitive)', () => {
  // 14.1
  it('Slovak', () => expect(new SayableDate(sk, 'short').formatDate('2031-02-15')).toBe('15. februára'));
  // 14.2
  it('Czech', () => expect(new SayableDate(cs, 'short').formatDate('2025-12-10')).toBe('10. prosince'));
  // 14.3
  it('Ukrainian', () => expect(new SayableDate(uk, 'short').formatDate('2025-11-05')).toBe('5 листопада'));
  // 14.4
  it('Finnish relative', () =>
    expect(new SayableDate(fi, 'short').formatRelative('1998-08-08', '1998-08-15')).toBe('8. elokuuta'));
});

// ── Section 15: format_relative — short phrases ─────────────────────

describe('format_relative — short phrases', () => {
  // 15.1
  it('Cornish day after tomorrow', () =>
    expect(new SayableDate(kw, 'short').formatRelative('2035-12-04', '2035-12-02')).toBe('an Mth ma'));
  // 15.2
  it('Mam day before yesterday', () =>
    expect(new SayableDate(mam, 'short').formatRelative('2000-01-23', '2000-01-25')).toBe("Dom nchi'j"));
  // 15.3
  it("Q'eqchi' day after tomorrow", () =>
    expect(new SayableDate(kek, 'short').formatRelative('2014-10-24', '2014-10-22')).toBe("a'in Vie"));
});

// ── Section 16: Input validation ────────────────────────────────────

describe('Input validation', () => {
  // 16.1
  it('February 30 does not exist', () => expect(formatDate('2025-02-30')).toBeNull());
  // 16.2
  it('month 13', () => expect(formatDate('2025-13-01')).toBeNull());
  // 16.3
  it('unpadded month and day', () => expect(formatDate('2025-6-1')).toBeNull());
  // 16.4
  it('surrounding whitespace', () => expect(formatDate(' 2025-06-01')).toBeNull());
  // 16.5
  it('ISO datetime uses only the date part', () => expect(formatDate('2025-06-01T10:00:00')).toBe('June 1st'));
  // 16.6
  it('February 29 in a non-leap year', () => expect(new SayableDate(en).formatDateWithYear('2023-02-29')).toBeNull());
  // 16.7
  it('invalid asOf', () => expect(formatRelative('2025-03-16', '2025-04-31')).toBeNull());
});
