import { describe, expect, it } from 'vitest';
import { SayableTime, formatTime } from '../src/index.js';
import { de } from '../src/locales/de.js';
import { en } from '../src/locales/en.js';
import { fr } from '../src/locales/fr.js';
import { fi } from '../src/locales/fi.js';
import { ja } from '../src/locales/ja.js';

// ── Section 1: Null / edge cases ──────────────────────────────────────

describe('Null / edge cases', () => {
  // 1.1
  it('format_time null', () => expect(formatTime(null)).toBeNull());
  // 1.2
  it('format_time empty', () => expect(formatTime('')).toBeNull());
  // 1.3
  it('format_time invalid', () => expect(formatTime('invalid')).toBeNull());
  // 1.4
  it('format_time out of range', () => expect(formatTime('25:00')).toBeNull());
});

// ── Section 2: Clock time (normal compactness) ────────────────────────

describe('Clock time (normal)', () => {
  const st = new SayableTime(en);

  // 2.1
  it('midnight', () => expect(st.formatTime('00:00')).toBe('midnight'));
  // 2.2
  it('noon', () => expect(st.formatTime('12:00')).toBe('noon'));
  // 2.3
  it("o'clock", () => expect(st.formatTime('15:00')).toBe("three o'clock"));
  // 2.4
  it('quarter past', () => expect(st.formatTime('14:15')).toBe('a quarter past two'));
  // 2.5
  it('half past', () => expect(st.formatTime('09:30')).toBe('half past nine'));
  // 2.6
  it('quarter to', () => expect(st.formatTime('10:45')).toBe('a quarter to eleven'));
  // 2.7
  it('five past', () => expect(st.formatTime('08:05')).toBe('five past eight'));
  // 2.8
  it('five to', () => expect(st.formatTime('16:55')).toBe('five to five'));
  // 2.9
  it('rounds to midnight', () => expect(st.formatTime('23:58')).toBe('midnight'));
  // 2.10
  it('rounds to twenty', () => expect(st.formatTime('07:22')).toBe('twenty past seven'));
  // 2.11
  it('ISO datetime input', () =>
    expect(st.formatTime('2025-01-15T14:15:00')).toBe('a quarter past two'));
});

// ── Section 3: Clock time (short compactness) ─────────────────────────

describe('Clock time (short)', () => {
  const st = new SayableTime(en, 'short');

  // 3.1
  it('PM', () => expect(st.formatTime('14:15')).toBe('2:15 PM'));
  // 3.2
  it('AM', () => expect(st.formatTime('09:30')).toBe('9:30 AM'));
  // 3.3
  it('midnight', () => expect(st.formatTime('00:00')).toBe('12:00 AM'));
  // 3.4
  it('noon', () => expect(st.formatTime('12:00')).toBe('12:00 PM'));
});

// ── Section 4: Clock time (compact) ───────────────────────────────────

describe('Clock time (compact)', () => {
  const st = new SayableTime(en, 'compact');

  // 4.1
  it('PM', () => expect(st.formatTime('14:15')).toBe('2:15p'));
  // 4.2
  it('AM', () => expect(st.formatTime('09:30')).toBe('9:30a'));
});

// ── Section 5: Locale — German ───────────────────────────────────────

describe('Locale — German', () => {
  const st = new SayableTime(de);

  // 5.1
  it('half to pattern', () => expect(st.formatTime('15:30')).toBe('halb vier'));
});

// ── Section 6: Locale — French ───────────────────────────────────────

describe('Locale — French', () => {
  const st = new SayableTime(fr);

  // 6.1
  it('quarter past', () => expect(st.formatTime('15:15')).toBe('trois heures et quart'));

  // 6.2
  it('singular hour', () => expect(st.formatTime('13:00')).toBe('une heure'));

  // 6.3
  it('half past singular hour', () => expect(st.formatTime('13:30')).toBe('une heure et demie'));

  // 6.4
  it('quarter to', () => expect(st.formatTime('14:45')).toBe('trois heures moins le quart'));

  // 6.5
  it('ten to', () => expect(st.formatTime('14:50')).toBe('trois heures moins dix'));
});

// ── Section 7: Locale — Japanese ─────────────────────────────────────

describe('Locale — Japanese', () => {
  const st = new SayableTime(ja);

  // 7.1
  it('half past', () => expect(st.formatTime('15:30')).toBe('三時半'));
});

// ── Section 8: Locale — Finnish (dot separator, short) ────────────────

describe('Locale — Finnish (dot separator, short)', () => {
  const st = new SayableTime(fi, 'short');

  // 8.1
  it('dot separator', () => expect(st.formatTime('14:15')).toBe('14.15'));

  // 8.2
  it('midnight dot', () => expect(st.formatTime('00:00')).toBe('0.00'));
});

// ── Section 9: Minutes in short and compact modes ─────────────────────

describe('Minutes in short and compact modes', () => {
  // 9.1
  it('short keeps the exact minute', () => expect(new SayableTime(en, 'short').formatTime('18:01')).toBe('6:01 PM'));

  // 9.2
  it('compact keeps the exact minute', () => expect(new SayableTime(en, 'compact').formatTime('19:05')).toBe('7:05p'));
});

// ── Section 10: Input validation ──────────────────────────────────────

describe('Input validation', () => {
  // 10.1
  it('one-digit hour', () => expect(formatTime('9:30')).toBe('half past nine'));

  // 10.2
  it('two-digit hour', () => expect(formatTime('09:30')).toBe('half past nine'));

  // 10.3
  it('leading whitespace', () => expect(formatTime(' 9:30')).toBeNull());

  // 10.4
  it('trailing whitespace', () => expect(formatTime('9:30 ')).toBeNull());

  // 10.5
  it('minutes need two digits', () => expect(formatTime('9:5')).toBeNull());

  // 10.6
  it('hour out of range', () => expect(formatTime('24:00')).toBeNull());

  // 10.7
  it('seconds are allowed and ignored', () => expect(formatTime('14:15:30')).toBe('a quarter past two'));

  // 10.8
  it('ISO datetime with zone suffix (ignored)', () =>
    expect(formatTime('2025-01-15T14:15:00Z')).toBe('a quarter past two'));

  // 10.9
  it('ISO datetime with an impossible date', () => expect(formatTime('2025-02-30T14:15:00')).toBeNull());
});
